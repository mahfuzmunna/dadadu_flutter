// lib/features/auth/presentation/bloc/auth_state.dart
part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// The initial state before any checks have been made.
class AuthInitial extends AuthState {}

/// State while an async authentication action is in progress.
class AuthLoading extends AuthState {}

/// State for a fully authenticated user.
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated({required this.user});
  @override
  List<Object> get props => [user];
}

/// State for an unauthenticated user, with an optional message for failed logins.
class AuthUnauthenticated extends AuthState {
  final String? message;
  const AuthUnauthenticated({this.message});
}

/// A special, temporary state for when a user has just signed up
/// and needs to complete the onboarding (e.g., upload a photo).
class AuthSignUpSuccess extends AuthState {
  final UserEntity user;

  const AuthSignUpSuccess({required this.user});
  @override
  List<Object> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthEmailVerificationRequired extends AuthState {
  final String email;

  const AuthEmailVerificationRequired({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthPasswordResetEmailSent extends AuthState {
  final String email;

  const AuthPasswordResetEmailSent({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthSignInSuccess extends AuthState {
  final UserEntity user;

  const AuthSignInSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class FirstRun extends AuthState {
  final UserEntity user;

  const FirstRun({required this.user});

  @override
  List<Object?> get props => [user];
}