// lib/features/profile/domain/usecases/update_profile_photo_usecase.dart

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UpdateProfilePhotoUseCase
    implements UseCase<String, UpdateProfilePhotoParams> {
  final ProfileRepository repository;

  UpdateProfilePhotoUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UpdateProfilePhotoParams params) async {
    return await repository.updateProfilePhoto(
        userId: params.userId, photoFile: params.photoFile);
  }
}

class UpdateProfilePhotoParams extends Equatable {
  final String userId;
  final File
      photoFile; // Path to the local image file (e.g., from image_picker)

  const UpdateProfilePhotoParams(
      {required this.userId, required this.photoFile});

  @override
  List<Object> get props => [userId, photoFile];
}
