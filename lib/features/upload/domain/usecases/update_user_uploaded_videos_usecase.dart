// lib/features/upload/domain/usecases/update_user_uploaded_videos_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/upload/domain/repositories/upload_post_repository.dart';

class UpdateUserUploadedVideosUseCase implements UseCase<void, UpdateUserVideosParams> {
  final UploadPostRepository repository;

  UpdateUserUploadedVideosUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserVideosParams params) async {
    return await repository.updateUserUploadedVideos(params.userId, params.videoUrl);
  }
}

class UpdateUserVideosParams extends Equatable {
  final String userId;
  final String videoUrl;

  const UpdateUserVideosParams({required this.userId, required this.videoUrl});

  @override
  List<Object> get props => [userId, videoUrl];
}