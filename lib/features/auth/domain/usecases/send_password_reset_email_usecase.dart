// lib/features/auth/domain/usecases/send_password_reset_email_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart'; // Make sure this defines 'NoParams' if you use it elsewhere
import '../repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase
    implements UseCase<void, SendPasswordResetEmailParams> {
  final AuthRepository repository;

  SendPasswordResetEmailUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
      SendPasswordResetEmailParams params) async {
    return await repository.sendPasswordResetEmail(params.email);
  }
}

class SendPasswordResetEmailParams extends Equatable {
  final String email;

  const SendPasswordResetEmailParams({required this.email});

  @override
  List<Object> get props => [email];
}