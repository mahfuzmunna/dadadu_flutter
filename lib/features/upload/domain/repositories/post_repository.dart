// lib/features/upload/domain/repositories/post_repository.dart
import 'dart:io'; // For the File type (used for video and thumbnail files)

import 'package:dartz/dartz.dart'; // For the Either type (from dartz package)

import '../../../../core/errors/failures.dart'; // For your custom Failure types
import '../entities/post_entity.dart'; // For the PostEntity

/// Abstract interface for the Post Repository.
/// This defines the contract that the data layer's repository implementation
/// must adhere to. It acts as a gateway to the data sources.
abstract class PostRepository {
  /// Uploads a new video post, including its video file and a thumbnail file,
  /// and then creates an entry for it in the database.
  ///
  /// [videoFile] is the actual video file to be uploaded.
  /// [thumbnailFile] is the image file to be used as the video's thumbnail.
  /// [userId] is the ID of the user uploading the post.
  /// [description] is an optional description for the post.
  ///
  /// Returns an [Either] type:
  /// - [Left] containing a [Failure] if the operation fails (e.g., network error, server error).
  /// - [Right] containing a [PostEntity] if the post is successfully uploaded and created.
  Future<Either<Failure, PostEntity>> uploadPost({
    required File videoFile,
    required File thumbnailFile,
    required String userId,
    String? description,
  });
}
