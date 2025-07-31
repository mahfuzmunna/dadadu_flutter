// lib/features/auth/domain/usecases/sign_up_usecase.dart

import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUp(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
      // Pass new fields
      username: params.username,
      referralId: params.referralId,
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String? fullName; // NEW
  final String? username; // NEW
  final String? referralId; // NEW

  const SignUpParams({
    required this.email,
    required this.password,
    this.fullName,
    this.username,
    this.referralId,
  });

  @override
  List<Object?> get props => [email, password, fullName, username, referralId];
}