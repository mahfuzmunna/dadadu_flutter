// lib/features/auth/data/datasources/auth_remote_data_source.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

/// Abstract interface for a remote authentication data source.
abstract class AuthRemoteDataSource {
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserEntity> signInWithOAuth({
    required OAuthProvider provider,
  });

  Future<void> signOut();

  Future<void> resetPasswordForEmail({
    required String email,
  });

  UserEntity? getCurrentUser();

  Stream<UserEntity?> onAuthStateChange();
}