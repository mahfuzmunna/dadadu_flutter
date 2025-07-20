// lib/features/auth/domain/usecases/sign_up_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:dadadu_app/core/errors/failures.dart'; // Updated package name
import 'package:dadadu_app/core/usecases/usecase.dart'; // Updated package name
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart'; // Updated package name
import 'package:dadadu_app/features/auth/domain/repositories/auth_repository.dart'; // Updated package name

class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUpWithEmailPassword(
      params.email,
      params.password,
      params.firstName, // New parameter
      params.lastName,  // New parameter
      params.username,  // New parameter
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String firstName; // New field
  final String lastName;  // New field
  final String username;  // New field

  const SignUpParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.username,
  });

  @override
  List<Object> get props => [email, password, firstName, lastName, username];
}