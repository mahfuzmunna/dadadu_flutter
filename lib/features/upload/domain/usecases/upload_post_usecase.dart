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
    return await repository.createPost(
      videoFile: params.videoFile,
      thumbnailFile: params.thumbnailFile,
      // Pass the thumbnail file
      userId: params.userId,
      description: params.description,
      videoUrl: '',
      thumbnailUrl: '',
      tag: '',
    );
  }
}

/// Parameters required for the [UploadPostUseCase].
/// This class encapsulates all necessary data for uploading a post,
/// making the use case's `call` method cleaner.
class UploadPostParams extends Equatable {
  final String userId;
  final String videoUrl;
  final String thumbnailUrl;
  final String description;
  final String tag;
  final String? location;
  final File videoFile;
  final File thumbnailFile;

  const UploadPostParams({
    required this.userId,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.description,
    required this.tag,
    required this.location,
    required this.videoFile,
    required this.thumbnailFile,
  });

  @override
  List<Object?> get props => [
        userId,
        videoUrl,
        thumbnailUrl,
        description,
        tag,
        location,
        videoFile,
        thumbnailFile
      ];
}
