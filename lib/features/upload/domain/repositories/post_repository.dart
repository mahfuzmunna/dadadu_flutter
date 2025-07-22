// lib/features/upload/domain/repositories/post_repository.dart
import 'dart:io'; // For the File type (used for video and thumbnail files)

import 'package:dartz/dartz.dart'; // For the Either type (from dartz package)

import '../../../../core/errors/failures.dart'; // For your custom Failure types
import '../entities/post_entity.dart'; // For the PostEntity

/// Abstract interface for the Post Repository.
/// This defines the contract that the data layer's repository implementation
/// must adhere to. It acts as a gateway to the data sources.
abstract class PostRepository {
  Future<Either<Failure, PostEntity>> getPostById(String postId);

  Stream<PostEntity> subscribeToPostChanges(String postId); // NEW
  Future<Either<Failure, PostEntity>> createPost({
    required String userId,
    required String videoUrl,
    required String thumbnailUrl,
    required String description,
    required String tag,
    String? location,
    required File videoFile,
    required File thumbnailFile,
  });
}
