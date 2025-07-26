// lib/features/upload/data/datasources/post_remote_data_source.dart
import 'dart:io';
import 'dart:typed_data'; // Import for Uint8List

import 'package:mime/mime.dart'; // NEW: Import for determining MIME types
import 'package:minio/minio.dart';
import 'package:path/path.dart' as p; // For path manipulation
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/post_model.dart';

/// Abstract interface for a remote data source handling post-related operations.
abstract class PostRemoteDataSource {
  /// Uploads a video file to the external storage (Wasabi via Minio).
  /// Returns the CDN URL of the uploaded video.
  Future<String> uploadVideoToStorage({
    required File videoFile,
    required String userId,
  });

  Future<String> uploadThumbnailToStorage({
    required File thumbnailFile,
    required String userId,
  });

  /// Creates a new post entry in the Supabase database.
  /// [videoUrl] should be the CDN URL obtained from [uploadVideoToStorage].
  Future<PostModel> createPostInDatabase({
    required String userId,
    required String videoUrl,
    required String thumbnailUrl,
    required String description,
    required String tag,
    String? location,
  });

  Future<PostModel> getPostById(String postId);

  Stream<PostModel> subscribeToPostChanges(String postId);

  Stream<List<PostModel>> getPostsStream();

  Future<void> sendDiamond({required String postId, required String userId});
}

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

  PostRemoteDataSourceImpl(
    this.supabaseClient, {
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
  Future<PostModel> createPostInDatabase({
    required String userId,
    required String videoUrl,
    required String thumbnailUrl,
    required String description,
    required String tag,
    String? location,
  }) async {
    try {
      final postData = {
        'user_id': userId,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'description': description,
        'tag': tag,
        'location': location,
        // The database should handle defaults for 'id', 'created_at',
        // 'diamonds', 'comments', 'views', 'disabled', 'visibility_level'
        // using 'now()' or default values (e.g., 0) in your table schema.
      };

      final newPostMap = await supabaseClient
          .from('posts')
          .insert(postData)
          .select(
              '*, users(*)') // Fetch the full post and nested author data after insert
          .single();

      // Convert the raw map from Supabase back to a PostModel
      return PostModel.fromMap(newPostMap);
    } on PostgrestException catch (e) {
      // Catch specific Supabase database errors
      throw ServerException(
        'Failed to create post in database: ${e.message}',
      );
    } catch (e) {
      // General catch for any other unexpected errors
      throw ServerException(
        'An unexpected error occurred during post creation: $e',
        code: 'UNKNOWN_DB_ERROR',
      );
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

  @override
  Stream<List<PostModel>> getPostsStream() {
    try {
      // This is the corrected order of operations
      return supabaseClient
          .from('posts')
          .stream(primaryKey: ['id'])
          // 1. ✅ First, define the query with .select() and .order()
          //     .select('*, users(*)')
          .order('created_at', ascending: false)

          // 2. ✅ THEN, convert that query into a real-time stream

          // 3. ✅ Finally, map the stream's output to your data models
          .map((listOfMaps) =>
              listOfMaps.map((postMap) => PostModel.fromMap(postMap)).toList());
    } catch (e) {
      // If setting up the stream fails, throw a ServerException.
      throw ServerException(
          'Failed to connect to the post stream: ${e.toString()}');
    }
  }

  @override
  Future<void> sendDiamond(
      {required String postId, required String userId}) async {
    try {
      // Create a new liked_post table in db
      // check if already liked
      final Map<String, dynamic> updateData = {
        'user_id': userId,
        'post_id': postId,
      };
      final response = await supabaseClient
          .from('liked_posts')
          .select()
          .eq('user_id', userId)
          .eq('post_id', postId)
          .single();

      if (response != null && response.isNotEmpty) {
        await supabaseClient
            .from('liked_posts')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);
      } else {
        await supabaseClient.from('liked_posts').insert(updateData);
      }

      // Step 3: Update the 'profiles' table in Supabase
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update profile database: ${e.message}');
    } catch (e) {
      throw ServerException(
          'An unexpected error occurred during profile update: ${e.toString()}');
    }
  }
}