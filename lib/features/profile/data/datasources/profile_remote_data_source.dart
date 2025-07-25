// lib/features/profile/data/datasources/profile_remote_data_source.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:minio/minio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../upload/data/models/post_model.dart';
import '../../domain/usecases/update_user_location_usecase.dart';
import '../../domain/usecases/update_user_mood_usecase.dart';

abstract class ProfileRemoteDataSource {
  Stream<UserModel> streamUserProfile(String userId);
  Future<UserModel> getUserProfile(String userId);

  Future<void> updateUserProfile({required UserEntity user, File? photoFile});
  Future<List<PostModel>> getUserPosts(String userId);

  Future<void> deleteProfileImage(String userId);

  Future<void> updateUserLocation(UpdateUserLocationParams user);

  Future<String> updateProfilePhoto({
    required String userId,
    required File photoFile,
  });

  Future<void> updateUserMood(UpdateUserMoodParams params);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _supabaseClient; // For Supabase DB
  final Minio _minioClient; // For Wasabi Storage
  final Uuid _uuid;

  // Wasabi/S3 client details
  final String _wasabiAccessKey;
  final String _wasabiSecretKey;
  final String _wasabiEndpoint;
  final String _wasabiBucketName; // The bucket for profile images on Wasabi
  final String _bunnyCdnHostname; // BunnyCDN hostname for profile images

  ProfileRemoteDataSourceImpl({
    required SupabaseClient supabaseClient,
    required Minio minioClient,
    required Uuid uuid,
    required String wasabiAccessKey,
    required String wasabiSecretKey,
    required String wasabiEndpoint,
    required String wasabiBucketName, // Specific bucket for profile images
    required String bunnyCdnHostname,
  })  : _supabaseClient = supabaseClient,
        _minioClient = minioClient,
        _uuid = uuid,
        _wasabiAccessKey = wasabiAccessKey,
        _wasabiSecretKey = wasabiSecretKey,
        _wasabiEndpoint = wasabiEndpoint,
        _wasabiBucketName = wasabiBucketName,
        _bunnyCdnHostname = bunnyCdnHostname;

  @override
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final response = await _supabaseClient
          .from('profiles') // Your users table
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

  // Separating the updateUserProfile method for clarity
  @override
  Future<void> updateUserProfile(
      {required UserEntity user, File? photoFile}) async {
    try {
      String? newPhotoUrl;

      // Step 1: Upload new photo if it exists
      if (photoFile != null) {
        final fileExtension = photoFile.path.split('.').last;
        final objectKey =
            'profile_images/${user.id}/${_uuid.v4()}.$fileExtension';
        final mimeType = lookupMimeType(photoFile.path);

        await _minioClient.putObject(
          _wasabiBucketName,
          objectKey,
          photoFile.openRead().cast<Uint8List>(),
          size: photoFile.lengthSync(),
          metadata: {if (mimeType != null) 'Content-Type': mimeType},
        );
        newPhotoUrl = 'https://$_bunnyCdnHostname/$objectKey';
      }

      // Step 2: Prepare the data for the database update
      final updateData = {
        'username': user.username,
        'full_name': user.fullName,
        'bio': user.bio,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // If a new photo was uploaded, add its URL to the update payload
      if (newPhotoUrl != null) {
        updateData['profile_photo_url'] = newPhotoUrl;
      }

      // Step 3: Update the 'profiles' table in Supabase
      await _supabaseClient
          .from('profiles')
          .update(updateData)
          .eq('id', user.id);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update profile database: ${e.message}');
    } catch (e) {
      throw ServerException(
          'An unexpected error occurred during profile update: ${e.toString()}');
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

  @override
  Future<void> updateUserLocation(UpdateUserLocationParams params) async {
    try {
      // ✅ Create a map containing ONLY the fields you want to update.
      // This is the key to not overwriting other profile data.
      final updateData = {
        'latitude': params.latitude,
        'longitude': params.longitude,
        'location': params.locationName,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabaseClient
          .from('profiles')
          .update(updateData)
          .eq('id', params.userId); // Target the specific user
    } on PostgrestException catch (e) {
      // Handle potential database errors
      throw ServerException(e.message);
    } catch (e) {
      // Handle other unexpected errors
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> updateProfilePhoto({
    required String userId,
    required File photoFile,
  }) async {
    try {
      final fileExtension = photoFile.path.split('.').last;
      // Define the object path in your Wasabi bucket
      final String objectKey =
          'profile_images/$userId/${_uuid.v4()}.$fileExtension';
      final String? mimeType = lookupMimeType(photoFile.path);

      // 1. Upload the file to Wasabi
      await _minioClient.putObject(
        _wasabiBucketName,
        objectKey,
        photoFile.openRead().cast<Uint8List>(),
        size: photoFile.lengthSync(),
        metadata: {if (mimeType != null) 'Content-Type': mimeType},
      );

      // 2. Construct the public CDN URL
      final String cdnImageUrl = 'https://$_bunnyCdnHostname/$objectKey';

      // 3. Update the 'profiles' table in Supabase
      await _supabaseClient.from('profiles').update({
        'profile_photo_url': cdnImageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // Return the public URL on success
      return cdnImageUrl;
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update profile database: ${e.message}');
    } catch (e) {
      // This will catch Minio errors or other unexpected issues
      throw ServerException(
        'An unexpected error occurred during profile image upload: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateUserMood(UpdateUserMoodParams params) async {
    try {
      await _supabaseClient.from('profiles').update({
        'mood_status': params.moodStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', params.userId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<UserModel> streamUserProfile(String userId) {
    try {
      // Listen to changes on the 'profiles' table for a specific user ID
      final stream = _supabaseClient
          .from('profiles')
          .stream(primaryKey: ['id']).eq('id', userId);

      // The stream returns a List<Map<String, dynamic>>. We need to transform it.
      return stream.map((data) {
        if (data.isEmpty) {
          // You might want to handle the case where the user profile is deleted
          throw ServerException('User profile not found in stream.',
              code: 'USER_NOT_FOUND');
        }
        // Return the first (and only) user profile from the list as a UserModel
        return UserModel.fromMap(data.first);
      });
    } catch (e) {
      throw ServerException('Failed to stream user profile: ${e.toString()}');
    }
  }
}
