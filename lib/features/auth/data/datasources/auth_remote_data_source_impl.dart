// lib/features/auth/data/datasources/auth_remote_data_source_impl.dart
import 'package:supabase_flutter/supabase_flutter.dart'; // Define your own exception class if needed
import '../../domain/entities/user_entity.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  // Helper to convert Supabase User to UserEntity
  UserEntity _toUserEntity(User? user) {
    if (user == null) {
      // This should ideally not be called with null if auth operations succeed
      // Or handle it as a specific error in domain layer
      throw ServerException('Authenticated user is null unexpectedly.');
    }
    return UserEntity(
      uid: user.id,
      email: user.email,
      phoneNumber: user.phone,
      isEmailConfirmed: user.emailConfirmedAt != null,
      createdAt: user.createdAt,
    );
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response =
          await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw ServerException('Sign in failed: No user in response.');
      }
      return _toUserEntity(response.user);
    } on AuthException catch (e) {
      throw ServerException(e.message, code: e.statusCode);
    } catch (e) {
      throw ServerException('An unexpected error occurred during sign in: $e');
    }
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        // You might add redirectTo options here if handling email confirmation/reset via deep link
        // options: AuthOptions(
        //   redirectTo: 'your-app-scheme://login-callback',
        // ),
      );
      if (response.user == null && supabaseClient.auth.currentUser == null) {
        // This typically means email confirmation is required and user not signed in yet
        throw ServerException(
            'Sign up successful, but email confirmation required. User not yet signed in.',
            code: 'EMAIL_CONFIRMATION_REQUIRED');
      }
      return _toUserEntity(response.user ?? supabaseClient.auth.currentUser!);
    } on AuthException catch (e) {
      throw ServerException(e.message, code: e.statusCode);
    } catch (e) {
      throw ServerException('An unexpected error occurred during sign up: $e');
    }
  }

  @override
  Future<UserEntity> signInWithOAuth({required OAuthProvider provider}) async {
    try {
      await supabaseClient.auth.signInWithOAuth(
        provider,
        redirectTo:
            'your-app-scheme://login-callback', // Crucial for app deep linking
        // authScreenLaunchMode: LaunchMode.platformExternalBrowser, // Or .inAppWebView
      );
      // Supabase handles the redirection. The session will be picked up by the auth listener.
      // This method returns *before* the user is fully authenticated via callback.
      // The actual UserEntity will be emitted by the onAuthStateChange stream.
      // For immediate return, we might need a different pattern or expect the listener to update.
      // For simplicity, we'll return the current user (which might be null initially)
      // and rely on the stream for the actual authenticated user.
      // A better pattern for OAuth is often just to *trigger* the sign-in and
      // let the BLoC's listener react to the state change.
      final User? currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw ServerException(
            'OAuth flow initiated, but no immediate user found. Waiting for callback.');
      }
      return _toUserEntity(currentUser);
    } on AuthException catch (e) {
      throw ServerException(e.message, code: e.statusCode);
    } catch (e) {
      throw ServerException(
          'An unexpected error occurred during OAuth sign in: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(e.message, code: e.statusCode);
    } catch (e) {
      throw ServerException('An unexpected error occurred during sign out: $e');
    }
  }

  @override
  Future<void> resetPasswordForEmail({required String email}) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(
        email,
        // options: AuthOptions(
        //   redirectTo: 'your-app-scheme://reset-password-callback',
        // ),
      );
    } on AuthException catch (e) {
      throw ServerException(e.message, code: e.statusCode);
    } catch (e) {
      throw ServerException(
          'An unexpected error occurred during password reset: $e');
    }
  }

  @override
  UserEntity? getCurrentUser() {
    final user = supabaseClient.auth.currentUser;
    return user != null ? _toUserEntity(user) : null;
  }

  @override
  Stream<UserEntity?> onAuthStateChange() {
    return supabaseClient.auth.onAuthStateChange.map((data) {
      final Session? session = data.session;
      if (session != null && session.user != null) {
        return _toUserEntity(session.user);
      }
      return null; // User signed out or no session
    });
  }
}

// Define a simple ServerException class (in lib/core/errors/exceptions.dart)
class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException(this.message, {this.code});

  @override
  String toString() => 'ServerException: $message (Code: ${code ?? 'N/A'})';
}
