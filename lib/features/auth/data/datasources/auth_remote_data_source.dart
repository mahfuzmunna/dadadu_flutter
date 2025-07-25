// lib/features/auth/data/datasources/auth_remote_data_source.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart' hide AuthException;
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

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  // Helper to construct public URL for Supabase storage
  String _getPublicUrl(String bucketName, String path) {
    return supabaseClient.storage.from(bucketName).getPublicUrl(path);
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? fullName,
    String? username,
  }) async {
    try {
      // 1. Sign up with Supabase Auth (email and password)
      final AuthResponse authResponse = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        // Optionally provide user metadata, but typically profile data goes to a separate table
        data: {
          'full_name': fullName,
          // These might be useful for initial auth.users metadata
          'username': username,
        },
      );

      final User? supabaseUser = authResponse.user;

      if (supabaseUser == null) {
        throw ServerException(
            'User is null after sign up. Email verification might be required.',
            code: 'EMAIL_CONFIRMATION_REQUIRED'); // Custom error code
      }

      final Map<String, dynamic> userProfileData = {
        'id': supabaseUser.id, // Link to auth.users table
        'email': supabaseUser.email,
        'full_name': fullName,
        'username': username,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final List<Map<String, dynamic>> response = await supabaseClient
          .from('profiles') // Replace with your actual profiles table name
          .insert(userProfileData)
          .select(); // Use .select() to get the inserted data back

      if (response.isEmpty) {
        throw ServerException('Failed to create user profile.',
            code: 'PROFILE_CREATION_FAILED');
      }

      // Return a UserModel created from the inserted profile data
      return UserModel.fromMap(response.first);
    } on AuthException catch (e) {
      debugPrint(
          'Supabase Auth Exception during signup: ${e.message} (code: ${e.statusCode})');
      if (e.statusCode == '400' && e.message.contains('Email not confirmed')) {
        throw ServerException('Email confirmation required',
            code: 'EMAIL_CONFIRMATION_REQUIRED');
      }
      throw ServerException(e.message, code: e.statusCode ?? 'AUTH_ERROR');
    } on PostgrestException catch (e) {
      debugPrint(
          'Supabase DB Exception during signup: ${e.message} (code: ${e.code})');
      throw ServerException(e.message, code: e.code ?? 'DB_ERROR');
    } on StorageException catch (e) {
      debugPrint('Supabase Storage Exception during signup: ${e.message}');
      throw ServerException(e.message, code: e.statusCode ?? 'STORAGE_ERROR');
    } catch (e) {
      debugPrint('Unknown error during signup: ${e.toString()}');
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw ServerException(
            'Sign In failed: User not found or invalid credentials.');
      }
      // Fetch user profile from your 'profiles' table after successful auth sign-in
      final profileData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromMap(profileData);
    } on AuthException catch (e) {
      throw ServerException(e.message, code: e.statusCode ?? 'AUTH_ERROR');
    } catch (e) {
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(e.message, code: e.statusCode ?? 'AUTH_ERROR');
    } catch (e) {
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> signInWithOAuth({required OAuthProvider provider}) async {
    try {
      await supabaseClient.auth.signInWithOAuth(
        provider,
        redirectTo: kIsWeb
            ? null
            : 'io.supabase.dadaduapp://login-callback/', // Your deep link scheme
        // You might need to set up a `context` for mobile platforms
        // context: context, // Pass BuildContext if you want to use in-app browser
      );
    } on AuthException catch (e) {
      throw ServerException(e.message, code: e.statusCode ?? 'AUTH_ERROR');
    } catch (e) {
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw ServerException(e.message, code: e.statusCode ?? 'AUTH_ERROR');
    } catch (e) {
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final User? currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw ServerException('No current user', code: 'NO_USER');
      }

      // Fetch user profile from your 'profiles' table
      final profileData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .single();

      return UserModel.fromMap(profileData);
    } on PostgrestException catch (e) {
      // ✅ Handle the specific error for a missing profile
      if (e.code == 'PGRST116') {
        // PGRST116 is the code for "exact one row not found"
        throw ServerException(
            'User profile is missing. Please complete sign-up.',
            code: 'PROFILE_NOT_FOUND');
      }
      // Handle other database errors
      throw ServerException(e.message);
    } on ServerException {
      rethrow; // Re-throw custom server exceptions
    } on AuthException catch (e) {
      throw ServerException(e.message, code: e.statusCode ?? 'AUTH_ERROR');
    } catch (e) {
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> onAuthStateChange() {
    return supabaseClient.auth.onAuthStateChange.asyncMap((data) async {
      if (data.event == AuthChangeEvent.signedIn ||
          data.event == AuthChangeEvent.initialSession) {
        final User? currentUser = data.session?.user;
        if (currentUser != null) {
          // Attempt to fetch full profile data
          try {
            final List<Map<String, dynamic>> profileData = await supabaseClient
                .from('profiles')
                .select()
                .eq('id', currentUser.id)
                .limit(1);

            if (profileData.isNotEmpty) {
              return UserModel.fromMap(profileData.first);
            } else {
              // If profile not found, return a basic UserModel from auth user
              return UserModel(
                id: currentUser.id,
                email: currentUser.email,
                fullName: currentUser.userMetadata?['full_name'] as String?,
                // Or username, if you store it there
                username: currentUser.userMetadata?['username'] as String?,
                bio: currentUser.userMetadata?['bio'] as String?,
                profilePhotoUrl:
                    currentUser.userMetadata?['profile_photo_url'] as String?,
                followersCount: 0,
                followingCount: 0,
                postCount: 0,
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
                rank: 'Leaf',
                referralLink: '',
                moodStatus: '',
                language: '',
                discoverMode: 'Entertainment',
                isEmailConfirmed: false,
                latitude: 0.0,
                longitude: 0.0,
                location: '',
              );
            }
          } catch (e) {
            debugPrint('Error fetching user profile in AuthStateChange: $e');
            // Fallback: return basic user if profile fetch fails
            return UserModel(
              id: currentUser.id,
              email: currentUser.email,
              fullName: currentUser.userMetadata?['full_name'] as String?,
              // Or username, if you store it there
              username: currentUser.userMetadata?['username'] as String?,
              bio: currentUser.userMetadata?['bio'] as String?,
              profilePhotoUrl:
                  currentUser.userMetadata?['profile_photo_url'] as String?,
              followersCount: 0,
              followingCount: 0,
              postCount: 0,
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
              rank: 'Leaf',
              referralLink: '',
              moodStatus: '',
              language: '',
              discoverMode: 'Entertainment',
              isEmailConfirmed: false,
              latitude: 0.0,
              longitude: 0.0,
              location: '',
            );
          }
        }
      }
      return null; // For signedOut, tokenExpired, userDeleted, etc.
    });
  }
}