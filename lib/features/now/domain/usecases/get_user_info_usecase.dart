// lib/features/now/domain/usecases/get_user_info_usecase.dart

import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/now/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetUserInfoUseCase implements UseCase<UserEntity, GetUserInfoParams> {
  final HomeRepository repository;

  GetUserInfoUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(GetUserInfoParams params) async {
    return await repository.getUserInfo(params.uid);
  }
}

class GetUserInfoParams extends Equatable {
  final String uid;

  const GetUserInfoParams({required this.uid});

  @override
  List<Object> get props => [uid];
}