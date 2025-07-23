// lib/features/profile/domain/usecases/update_user_profile_usecase.dart

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
    // ✅ The use case now simply passes the complete UserEntity to the repository.
    // No need to reconstruct an incomplete object here.
    return await repository.updateUserProfile(params.user);
  }
}

/// Parameters required to update a user's profile.
/// It now wraps the complete UserEntity object containing the new data.
class UpdateUserProfileParams extends Equatable {
  final UserEntity user;

  const UpdateUserProfileParams(this.user);

  @override
  List<Object> get props => [user];
}