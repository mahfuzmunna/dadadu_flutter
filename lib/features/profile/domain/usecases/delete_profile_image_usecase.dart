// lib/features/profile/domain/usecases/delete_profile_image_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class DeleteProfileImageUseCase
    implements UseCase<void, DeleteProfileImageParams> {
  final ProfileRepository repository;

  DeleteProfileImageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteProfileImageParams params) async {
    return await repository.deleteProfileImage(params.userId);
  }
}

class DeleteProfileImageParams extends Equatable {
  final String userId;

  const DeleteProfileImageParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
