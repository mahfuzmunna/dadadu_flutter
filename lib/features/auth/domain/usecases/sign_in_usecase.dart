// lib/features/auth/domain/usecases/sign_in_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:dadadu_app/core/errors/failures.dart'; // Updated package name
import 'package:dadadu_app/core/usecases/usecase.dart'; // Updated package name
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart'; // Updated package name
import 'package:dadadu_app/features/auth/domain/repositories/auth_repository.dart'; // Updated package name

class SignInUseCase implements UseCase<UserEntity, SignInParams> {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    return await repository.signInWithEmailPassword(
      params.email,
      params.password,
    );
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}