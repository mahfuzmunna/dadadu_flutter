// lib/features/auth/domain/usecases/sign_in_with_oauth_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithOAuthUseCase
    implements UseCase<UserEntity, SignInWithOAuthParams> {
  final AuthRepository repository;

  SignInWithOAuthUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithOAuthParams params) async {
    return await repository.signInWithOAuth(
      provider: params.provider,
    );
  }
}

class SignInWithOAuthParams extends Equatable {
  final OAuthProvider provider;

  const SignInWithOAuthParams({required this.provider});

  @override
  List<Object?> get props => [provider];
}
