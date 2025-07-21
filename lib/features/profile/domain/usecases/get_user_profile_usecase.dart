// lib/features/profile/domain/usecases/get_user_profile_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart'; // For UseCase and NoParams if needed
import '../../../auth/domain/entities/user_entity.dart'; // Reusing UserEntity
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase implements UseCase<UserEntity, GetUserProfileParams> {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(GetUserProfileParams params) async {
    return await repository.getUserProfile(params.userId);
  }
}

class GetUserProfileParams extends Equatable {
  final String userId;

  const GetUserProfileParams({required this.userId});

  @override
  List<Object> get props => [userId];
}