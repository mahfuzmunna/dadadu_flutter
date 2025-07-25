// lib/features/auth/presentation/bloc/auth_event.dart
part of 'auth_bloc.dart'; // Make sure this is correct for your project structure

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  // FIX: Changed to List<Object?> to allow for nullable properties in some events
  List<Object?> get props => [];
}

/// Dispatched once at app startup to check the current session.
class AuthInitialCheckRequested extends AuthEvent {
  const AuthInitialCheckRequested();
}

/// Dispatched from the UI when the user tries to sign in.
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInRequested({required this.email, required this.password});
}

/// Dispatched from the UI when the user tries to sign up.
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String username;

  const AuthSignUpRequested(
      {required this.email,
      required this.password,
      required this.fullName,
      required this.username});
}

/// Dispatched from the photo upload page to finalize the sign-up flow.
class AuthOnboardingComplete extends AuthEvent {
  final UserEntity user;

  const AuthOnboardingComplete({required this.user});
}

/// Dispatched from the UI to sign the user out.
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Internal event triggered by the Supabase auth state listener.
class _AuthUserChanged extends AuthEvent {
  final UserEntity? user;

  const _AuthUserChanged(this.user);
}

// TO_BE_IMPLEMENTED
class AuthSignInWithOAuthRequested extends AuthEvent {
  final OAuthProvider provider;
  const AuthSignInWithOAuthRequested({required this.provider});

}

class AuthPasswordResetRequested extends AuthEvent {
  // Renamed from AuthResetPasswordRequested for clarity
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email]; // This is non-nullable
}

// Event triggered by the underlying Supabase auth listener (from first snippet)
class AuthUserChanged extends AuthEvent {
  final UserEntity? user; // Assuming UserEntity is defined elsewhere

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user]; // This correctly returns List<Object?>
}

class AuthRefreshCurrentUser extends AuthEvent {
  const AuthRefreshCurrentUser(); // No props, it's just a signal
}