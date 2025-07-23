import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileDataUseCase
    implements UseCase<UserEntity, GetUserProfileParams> {
  final ProfileRepository repository;

  GetUserProfileDataUseCase(this.repository);

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