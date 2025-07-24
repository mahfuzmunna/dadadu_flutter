import 'dart:io';

import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/posts/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class UploadPostUseCase implements UseCase<void, UploadPostParams> {
  final PostRepository repository;

  UploadPostUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UploadPostParams params) async {
    return await repository.uploadPost(
      videoFile: params.videoFile,
      thumbnailFile: params.thumbnailFile,
      caption: params.caption,
      intent: params.intent,
      userId: params.userId,
      onUploadProgress: params.onUploadProgress,
    );
  }
}

class UploadPostParams extends Equatable {
  final File videoFile;
  final File thumbnailFile;
  final String caption;
  final String intent;
  final String userId;
  final Function(double progress)? onUploadProgress;

  const UploadPostParams({
    required this.videoFile,
    required this.thumbnailFile,
    required this.caption,
    required this.intent,
    required this.userId,
    this.onUploadProgress,
  });

  @override
  List<Object?> get props =>
      [videoFile, thumbnailFile, caption, intent, userId];
}
