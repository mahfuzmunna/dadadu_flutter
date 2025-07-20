// lib/features/auth/presentation/bloc/auth_event.dart

part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStatusChanged extends AuthEvent {
  final UserEntity? user;
  const AuthStatusChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName; // <--- ADD THIS
  final String lastName;  // <--- ADD THIS
  final String username;  // <--- ADD THIS

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.firstName, // <--- AND ADD TO CONSTRUCTOR
    required this.lastName,  // <--- AND ADD TO CONSTRUCTOR
    required this.username,  // <--- AND ADD TO CONSTRUCTOR
  });

  @override
  List<Object> get props => [email, password, firstName, lastName, username]; // <--- AND ADD TO PROPS
}

class SignOutRequested extends AuthEvent {}