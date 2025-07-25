// lib/features/auth/presentation/bloc/auth_state.dart
part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  final String?
      message; // Optional message for sign up success (e.g., check email)

  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
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

class AuthSignUpSuccess extends AuthState {
  final UserEntity user;

  const AuthSignUpSuccess({required this.user});

  @override
  List<Object?> get props => [user];
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