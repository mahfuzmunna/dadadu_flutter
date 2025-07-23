// lib/features/auth/presentation/bloc/auth_event.dart
part of 'auth_bloc.dart'; // Make sure this is correct for your project structure

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  // FIX: Changed to List<Object?> to allow for nullable properties in some events
  List<Object?> get props => [];
}

class AuthInitialCheckRequested extends AuthEvent {
  // Renamed from AuthCheckRequested for clarity
  const AuthInitialCheckRequested();
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password]; // These are non-nullable
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? fullName; // NEW
  final String? username; // NEW
  final String? bio; // NEW
  final File? profilePhotoFile;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    this.fullName,
    this.username,
    this.bio,
    this.profilePhotoFile,
  });

  @override
  // Updated to List<Object?> because fullName, username, bio are nullable
  List<Object?> get props =>
      [email, password, fullName, username, bio, profilePhotoFile];
}

class AuthSignInWithOAuthRequested extends AuthEvent {
  final OAuthProvider provider;

  const AuthSignInWithOAuthRequested({required this.provider});

  @override
  List<Object> get props => [provider]; // This is non-nullable
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested(); // No props
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

class AuthOnboardingComplete extends AuthEvent {
  final UserEntity user;

  const AuthOnboardingComplete({required this.user});

  @override
  List<Object> get props => [user];
}