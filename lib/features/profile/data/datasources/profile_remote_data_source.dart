// lib/features/profile/data/datasources/profile_remote_data_source.dart

import 'dart:io';
import 'dart:typed_data'; // Required for Stream<Uint8List> cast

import 'package:mime/mime.dart'; // NEW: For determining MIME types
// Supabase imports (for DB operations)
import 'package:minio/minio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Minio imports (for Wasabi storage)
// Other utilities
import 'package:uuid/uuid.dart'; // For generating unique IDs

import '../../../../core/errors/exceptions.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../upload/data/models/post_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile(String userId);
  Future<void> updateUserProfile(UserModel user);
  Future<List<PostModel>> getUserPosts(String userId);

  Future<String> uploadProfileImage(
      String userId, String imagePath); // Returns URL
  Future<void> deleteProfileImage(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _supabaseClient; // For Supabase DB
  late final Minio _minioClient; // For Wasabi Storage
  final Uuid _uuid;

  // Wasabi/S3 client details
  final String _wasabiAccessKey;
  final String _wasabiSecretKey;
  final String _wasabiEndpoint;
  final String _wasabiBucketName; // The bucket for profile images on Wasabi
  final String _bunnyCdnHostname; // BunnyCDN hostname for profile images

  ProfileRemoteDataSourceImpl({
    required SupabaseClient supabaseClient,
    required Uuid uuid,
    required String wasabiAccessKey,
    required String wasabiSecretKey,
    required String wasabiEndpoint,
    required String wasabiBucketName, // Specific bucket for profile images
    required String bunnyCdnHostname,
  })  : _supabaseClient = supabaseClient,
        _uuid = uuid,
        _wasabiAccessKey = wasabiAccessKey,
        _wasabiSecretKey = wasabiSecretKey,
        _wasabiEndpoint = wasabiEndpoint,
        _wasabiBucketName = wasabiBucketName,
        _bunnyCdnHostname = bunnyCdnHostname {
    _minioClient = Minio(
      endPoint: _wasabiEndpoint,
      accessKey: _wasabiAccessKey,
      secretKey: _wasabiSecretKey,
      useSSL: true, // Always use SSL for production
    );
  }

  @override
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final response = await _supabaseClient
          .from('users') // Your users table
          .select()
          .eq('id', userId)
          .single();

      if (response == null) {
        throw ServerException('User profile not found: No data returned.',
            code: 'USER_NOT_FOUND');
      }

      return UserModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get user profile: ${e.message}',
          code: e.code ?? 'POSTGREST_ERROR');
    } catch (e) {
      throw ServerException('An unexpected error occurred: ${e.toString()}',
          code: 'UNKNOWN_ERROR');
    }
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _supabaseClient
          .from('users') // Your users table
          .update(
              user.toMap()..['updated_at'] = DateTime.now().toIso8601String())
          .eq('id', user.uid);
    } on PostgrestException catch (e) {
      throw ServerException(
        'Failed to update user profile: ${e.message}',
        code: e.code ?? 'POSTGREST_ERROR',
      );
    } catch (e) {
      throw ServerException('An unexpected error occurred: ${e.toString()}',
          code: 'UNKNOWN_ERROR');
    }
  }

  @override
  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      final List<Map<String, dynamic>> response = await _supabaseClient
          .from('posts') // Your posts table
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);

      return response.map((map) => PostModel.fromMap(map)).toList();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get user posts: ${e.message}',
          code: e.code ?? 'POSTGREST_ERROR');
    } catch (e) {
      throw ServerException('An unexpected error occurred: ${e.toString()}',
          code: 'UNKNOWN_ERROR');
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, String imagePath) async {
    try {
      final file = File(imagePath);
      final fileExtension = imagePath.split('.').last;
      // Object key for Wasabi
      final String objectKey =
          'profile_images/$userId/${_uuid.v4()}.$fileExtension';

      // Determine MIME type for Content-Type header
      final String? mimeType = lookupMimeType(file.path);

      // Upload the file to Wasabi using Minio
      await _minioClient.putObject(
        _wasabiBucketName, // Your Wasabi bucket name for profile images
        objectKey, // The path/key for the object in the bucket
        file.openRead().cast<Uint8List>(),
        // Cast Stream<List<int>> to Stream<Uint8List>
        size: file.lengthSync(), // Content length
        metadata: {
          if (mimeType != null) 'Content-Type': mimeType,
        },
      );

      // Construct the public URL using the BunnyCDN hostname
      final String cdnImageUrl = 'https://$_bunnyCdnHostname/$objectKey';

      // Update the user's profile in the Supabase database with the new image URL
      await _supabaseClient.from('users').update({
        'profile_photo_url': cdnImageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return cdnImageUrl;
    }
    // You might catch specific MinioException here if you've extended your exceptions
    // on MinioException catch (e) {
    //   throw ServerException('Minio error during profile image upload: ${e.message}', code: e.statusCode?.toString());
    // }
    on PostgrestException catch (e) {
      throw ServerException(
        'Failed to update profile after image upload: ${e.message}',
        code: e.code ?? 'POSTGREST_ERROR',
      );
    } on ServerException {
      rethrow; // Re-throw custom exceptions from deeper layers
    } catch (e) {
      throw ServerException(
          'An unexpected error occurred during profile image upload: ${e.toString()}',
          code: 'UNKNOWN_UPLOAD_ERROR');
    }
  }

  @override
  Future<void> deleteProfileImage(String userId) async {
    try {
      // 1. Get the current user's profile to retrieve the image URL from Supabase DB
      final response = await _supabaseClient
          .from('users')
          .select('profile_photo_url')
          .eq('id', userId)
          .single();

      if (response == null ||
          response['profile_photo_url'] == null ||
          response['profile_photo_url'].isEmpty) {
        return; // No image to delete or URL not found
      }

      final String currentImageUrl = response['profile_photo_url'] as String;

      // 2. Extract the object key (path) from the BunnyCDN URL for deletion from Wasabi
      // Assumes URL format: https://[bunny_cdn_hostname]/profile_images/[userId]/[uuid.ext]
      final Uri uri = Uri.parse(currentImageUrl);
      // The path segments will be something like ['profile_images', 'userId', 'uuid.ext']
      // We need to reconstruct 'profile_images/userId/uuid.ext'
      final String objectKey = uri.pathSegments.join('/');

      // 3. Delete image from Wasabi Storage using Minio
      await _minioClient.removeObject(_wasabiBucketName, objectKey);

      // 4. Update user profile in Supabase database to remove image URL
      await _supabaseClient.from('users').update({
        'profile_photo_url': null,
        // Set to NULL or an empty string as per your DB schema
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    }
    // You might catch specific MinioException here
    // on MinioException catch (e) {
    //   throw ServerException('Minio error during profile image deletion: ${e.message}', code: e.statusCode?.toString());
    // }
    on PostgrestException catch (e) {
      throw ServerException(
        'Failed to update profile after image deletion: ${e.message}',
        code: e.code ?? 'POSTGREST_ERROR',
      );
    } on ServerException {
      rethrow; // Re-throw custom exceptions from deeper layers
    } catch (e) {
      throw ServerException(
          'An unexpected error occurred during image deletion: ${e.toString()}',
          code: 'UNKNOWN_DELETE_ERROR');
    }
  }
}