// lib/features/upload/domain/usecases/upload_post_usecase.dart
import 'dart:io'; // For File

import 'package:dartz/dartz.dart'; // For Either
import 'package:equatable/equatable.dart'; // For Equatable

import '../../../../core/errors/failures.dart'; // For Failure
import '../../../../core/usecases/usecase.dart'; // For UseCase abstract class
import '../entities/post_entity.dart'; // For PostEntity
import '../repositories/post_repository.dart'; // For PostRepository

/// UseCase for uploading a new video post, including its thumbnail.
/// It orchestrates the call to the [PostRepository].
class UploadPostUseCase implements UseCase<PostEntity, UploadPostParams> {
  final PostRepository repository;

  UploadPostUseCase(this.repository);

  @override
  Future<Either<Failure, PostEntity>> call(UploadPostParams params) async {
    // Delegates the actual upload and post creation logic to the repository.
    return await repository.uploadPost(
      videoFile: params.videoFile,
      thumbnailFile: params.thumbnailFile, // Pass the thumbnail file
      userId: params.userId,
      description: params.description,
    );
  }
}

/// Parameters required for the [UploadPostUseCase].
/// This class encapsulates all necessary data for uploading a post,
/// making the use case's `call` method cleaner.
class UploadPostParams extends Equatable {
  final File videoFile;
  final File thumbnailFile; // REQUIRED: The file for the video's thumbnail
  final String userId;
  final String? description; // Optional description for the post

  const UploadPostParams({
    required this.videoFile,
    required this.thumbnailFile,
    required this.userId,
    this.description,
  });

  @override
  List<Object?> get props => [videoFile, thumbnailFile, userId, description];
}
