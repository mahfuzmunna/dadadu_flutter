// lib/features/auth/data/datasources/auth_remote_data_source.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  // Add new parameters to the signUpWithEmailAndPassword method
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? fullName, // NEW
    String? username, // NEW
  });

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> signInWithOAuth({
    required OAuthProvider provider,
  });

  Future<void> resetPassword({
    required String email,
  });

  Future<UserModel> getCurrentUser();

  Stream<UserModel?> onAuthStateChange();
}