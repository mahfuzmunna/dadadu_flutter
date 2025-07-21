// lib/features/auth/presentation/bloc/auth_event.dart

part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;
  final String firstName;
  final String lastName;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object> get props => [email, password, username, firstName, lastName];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  const AuthResetPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

// NEW: Event to refresh current user data (e.g., after profile update)
class AuthRefreshCurrentUser extends AuthEvent {
  const AuthRefreshCurrentUser();
}