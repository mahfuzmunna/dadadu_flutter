// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Add new parameters to the signUp method
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    String? fullName, // NEW
    String? username, // NEW
  });

  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> signOut();

  Future<Either<Failure, Unit>> signInWithOAuth({
    required OAuthProvider provider,
  });

  Future<Either<Failure, Unit>> resetPassword({
    required String email,
  });

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Stream<UserEntity?> onAuthStateChange();
}