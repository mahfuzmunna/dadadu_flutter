// lib/features/profile/domain/usecases/update_profile_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<void, UserEntity> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UserEntity user) async {
    return await repository.updateUserProfile(user);
  }
}