import 'dart:io';
import 'dart:typed_data';

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
    // Pass the parameters directly to the repository method
    return await repository.uploadPost(
      videoFile: params.videoFile,
      thumbnailBytes: params.thumbnailBytes,
      // Pass bytes
      caption: params.caption,
      intent: params.intent,
      userId: params.userId,
      onUploadProgress: params.onUploadProgress,
    );
  }
}

class UploadPostParams extends Equatable {
  final File videoFile;
  final Uint8List thumbnailBytes; // ✅ Changed from File to Uint8List
  final String caption;
  final String intent;
  final String userId;
  final Function(double progress)? onUploadProgress;

  const UploadPostParams({
    required this.videoFile,
    required this.thumbnailBytes, // ✅ Updated constructor
    required this.caption,
    required this.intent,
    required this.userId,
    this.onUploadProgress,
  });

  @override
  List<Object?> get props =>
      [videoFile, thumbnailBytes, caption, intent, userId];
}