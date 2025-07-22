// lib/features/auth/presentation/bloc/auth_event.dart
part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  // FIX: Changed to List<Object?> to allow for nullable properties
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

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

  const AuthSignUpRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password]; // These are non-nullable
}

class AuthSignInWithOAuthRequested extends AuthEvent {
  final OAuthProvider provider;

  const AuthSignInWithOAuthRequested({required this.provider});

  @override
  List<Object> get props => [provider]; // These are non-nullable
}

class AuthSignOutRequested extends AuthEvent {}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  const AuthResetPasswordRequested({required this.email});

  @override
  List<Object> get props => [email]; // This is non-nullable
}

// Event triggered by the underlying Supabase auth listener
class AuthUserChanged extends AuthEvent {
  final UserEntity? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user]; // This correctly returns List<Object?>
}

class AuthRefreshCurrentUser extends AuthEvent {
  const AuthRefreshCurrentUser(); // No need for props, it's just a signal
}