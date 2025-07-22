// lib/features/upload/data/datasources/post_remote_data_source_impl.dart
import 'dart:io';
import 'dart:typed_data'; // Import for Uint8List

import 'package:mime/mime.dart'; // NEW: Import for determining MIME types
import 'package:minio/minio.dart';
import 'package:path/path.dart' as p; // For path manipulation
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/post_entity.dart';
import '../models/post_model.dart'; // Assumed from the first snippet
import 'post_remote_data_source.dart';

// Optional: import minio_new/exceptions.dart for specific exception handling
// import 'package:minio_new/exceptions.dart';

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final SupabaseClient supabaseClient;

  // Add Wasabi/S3 client details (from AppConfig or similar)
  final String wasabiAccessKey;
  final String wasabiSecretKey;
  final String wasabiEndpoint; // e.g., 's3.us-east-1.wasabisys.com'
  final String wasabiBucketName; // e.g., 'your-video-bucket'
  final String bunnyCdnHostname; // e.g., 'my-app-videos.b-cdn.net'

  // Minio client instance (initialized in constructor or lazily)
  late final Minio _minioClient;

  PostRemoteDataSourceImpl(this.supabaseClient, {
    required this.wasabiAccessKey,
    required this.wasabiSecretKey,
    required this.wasabiEndpoint, // Changed to endpoint URL
    required this.wasabiBucketName,
    required this.bunnyCdnHostname,
  }) {
    _minioClient = Minio(
      endPoint: wasabiEndpoint,
      accessKey: wasabiAccessKey,
      secretKey: wasabiSecretKey,
      useSSL: true, // Always use SSL for production
    );
  }

  /// Helper method to upload a generic file to Wasabi
  /// This centralizes the Minio upload logic and error handling for files.
  Future<String> _uploadFileToWasabi({
    required File file,
    required String userId,
    required String folder, // e.g., 'user_videos', 'user_thumbnails'
  }) async {
    try {
      final String objectKey =
          '$folder/$userId/${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';

      // Determine MIME type for correct Content-Type header
      final String? mimeType = lookupMimeType(file.path);

      await _minioClient.putObject(
        wasabiBucketName,
        objectKey,
        file.openRead().cast<Uint8List>(),
        // Cast Stream<List<int>> to Stream<Uint8List>
        size: file.lengthSync(), // Content length
        metadata: {
          if (mimeType != null) 'Content-Type': mimeType,
        },
      );

      // Construct the public URL using the BunnyCDN hostname
      // BunnyCDN will fetch from Wasabi based on this objectKey
      final String cdnFileUrl = 'https://$bunnyCdnHostname/$objectKey';

      return cdnFileUrl;
    }
    // Catch specific Minio exceptions if needed for more granular error handling
    // on MinioException catch (e) {
    //   throw ServerException('Minio error during upload: ${e.message}', code: e.statusCode?.toString());
    // }
    on ServerException {
      rethrow; // Re-throw custom exceptions from deeper layers
    } catch (e) {
      // General catch for any other unexpected errors during file upload
      throw ServerException(
          'An unexpected error occurred during file upload to Wasabi in folder "$folder": $e',
          code: 'WASABI_UPLOAD_ERROR');
    }
  }

  @override
  Future<String> uploadVideoToStorage({
    required File videoFile,
    required String userId,
  }) async {
    return _uploadFileToWasabi(
      file: videoFile,
      userId: userId,
      folder: 'user_videos', // Specific folder for videos
    );
  }

  @override
  Future<String> uploadThumbnailToStorage({
    required File thumbnailFile,
    required String userId,
  }) async {
    return _uploadFileToWasabi(
      file: thumbnailFile,
      userId: userId,
      folder: 'user_thumbnails', // Specific folder for thumbnails
    );
  }

  @override
  Future<PostEntity> createPostInDatabase({
    required String userId,
    required String videoUrl, // This `videoUrl` will now be the BunnyCDN URL
    required String thumbnailUrl, // NEW: Required thumbnail URL
    String? description, // Remains nullable
  }) async {
    try {
      final postMap = await supabaseClient
          .from('posts')
          .insert(
            {
              'user_id': userId,
              'video_url': videoUrl,
              // Save the BunnyCDN URL here
              'thumbnail_url': thumbnailUrl,
              // NEW: Save the BunnyCDN thumbnail URL here
              'description': description,
              // Pass nullable description
              'created_at': DateTime.now().toIso8601String(),
              // Ensure this matches your DB column name
            },
          )
          .select()
          .single(); // .single() to get the inserted row back

      if (postMap == null) {
        // This case is unlikely for a successful insert().select().single()
        // as Supabase usually throws a PostgrestException if no data is returned
        // or if an error occurs.
        throw ServerException(
            'Failed to create post: No data returned from insert.',
            code: 'NO_DATA_ON_INSERT');
      }

      // Ensure that the keys match your Supabase table column names exactly
      return PostEntity(
        id: postMap['id'] as String,
        userId: postMap['user_id'] as String,
        videoUrl: postMap['video_url'] as String,
        thumbnailUrl: postMap['thumbnail_url'] as String,
        // Correctly cast as non-nullable String
        description: postMap['description'] as String,
        // FIX: Cast as nullable String to match PostEntity
        createdAt: postMap['createdAt'] as DateTime, // Cast as String
      );
    } on PostgrestException catch (e) {
      // Catch specific Supabase database errors
      throw ServerException(
        'Failed to create post in database: ${e.message}',
        code: e.code as String,
      );
    } catch (e) {
      // General catch for any other unexpected errors during database operation
      throw ServerException(
          'An unexpected error occurred during post creation in Supabase: $e',
          code: 'UNKNOWN_DB_ERROR');
    }
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    try {
      final response = await supabaseClient
          .from('posts') // Your posts table name
          .select()
          .eq('id', postId)
          .single(); // Use single() if you expect one result

      return PostModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, code: e.code as String);
    } catch (e) {
      throw ServerException('Failed to get post: ${e.toString()}');
    }
  }

  @override
  Stream<PostModel> subscribeToPostChanges(String postId) {
    // Use Realtime to listen for updates to a specific post by its ID
    return supabaseClient
        .from('posts')
        .stream(primaryKey: ['id']) // 'id' is your primary key
        .eq('id', postId) // Filter for the specific post
        .map((event) {
          // The event is a List<Map<String, dynamic>>
          if (event.isNotEmpty) {
            return PostModel.fromMap(event.first);
          }
          // If the event list is empty (e.g., due to deletion),
          // you might want to handle it differently, e.g., throw an error
          // or return a special state. For simplicity, we'll throw here.
          throw ServerException('Post data not found in realtime update.');
        });
  }
}