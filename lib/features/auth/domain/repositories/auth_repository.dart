// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For Provider enum
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Abstract interface for authentication operations.
/// This defines the contract that the data layer must fulfill.
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signInWithOAuth({
    required OAuthProvider provider,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> resetPasswordForEmail({
    required String email,
  });

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Stream<UserEntity?> onAuthStateChange(); // Stream for auth state changes
}