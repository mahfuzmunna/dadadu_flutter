import 'dart:io';

import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class UpdateUserProfileUseCase
    implements UseCase<void, UpdateUserProfileParams> {
  final ProfileRepository repository;
  UpdateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserProfileParams params) async {
    return await repository.updateUserProfile(
      user: params.user,
      photoFile: params.photoFile,
    );
  }
}

class UpdateUserProfileParams extends Equatable {
  final UserEntity user;
  final File? photoFile;

  const UpdateUserProfileParams({required this.user, this.photoFile});

  @override
  List<Object?> get props => [user, photoFile];
}