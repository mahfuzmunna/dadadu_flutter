// lib/features/auth/presentation/bloc/auth_state.dart

part of 'auth_bloc.dart'; // <--- Ensure this line is correct

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user; // <--- This field should exist

  const Authenticated({required this.user}); // <--- This named parameter 'user' should be required

  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {
  final String? message;

  const Unauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}