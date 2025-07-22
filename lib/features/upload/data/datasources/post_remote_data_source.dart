// lib/features/upload/data/datasources/post_remote_data_source.dart
import 'dart:io';

import '../../domain/entities/post_entity.dart';
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
  Future<PostEntity> createPostInDatabase({
    required String userId,
    required String videoUrl,
    required String thumbnailUrl,
    String? description,
  });

  Future<PostModel> getPostById(String postId);

  Stream<PostModel> subscribeToPostChanges(String postId); // NEW
}
