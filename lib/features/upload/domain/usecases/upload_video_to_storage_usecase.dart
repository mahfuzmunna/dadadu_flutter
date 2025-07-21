// lib/features/upload/domain/usecases/upload_video_to_storage_usecase.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/upload/domain/repositories/upload_post_repository.dart';

class UploadVideoToStorageUseCase implements UseCase<String, UploadVideoParams> {
  final UploadPostRepository repository;

  UploadVideoToStorageUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadVideoParams params) async {
    return await repository.uploadVideo(params.videoFile, params.userId, params.postId);
  }
}

class UploadVideoParams extends Equatable {
  final File videoFile;
  final String userId;
  final String postId; // Unique ID for the video/post

  const UploadVideoParams({
    required this.videoFile,
    required this.userId,
    required this.postId,
  });

  @override
  List<Object> get props => [videoFile, userId, postId];
}