// lib/features/profile/domain/usecases/upload_profile_image_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UploadProfileImageUseCase
    implements UseCase<String, UploadProfileImageParams> {
  final ProfileRepository repository;

  UploadProfileImageUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadProfileImageParams params) async {
    return await repository.uploadProfileImage(params.userId, params.imagePath);
  }
}

class UploadProfileImageParams extends Equatable {
  final String userId;
  final String
      imagePath; // Path to the local image file (e.g., from image_picker)

  const UploadProfileImageParams(
      {required this.userId, required this.imagePath});

  @override
  List<Object> get props => [userId, imagePath];
}
