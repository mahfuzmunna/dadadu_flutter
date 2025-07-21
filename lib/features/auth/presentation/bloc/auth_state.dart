// lib/features/auth/presentation/bloc/auth_state.dart

part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  // Change return type to List<Object?> to allow nullable properties in derived states
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  final bool isLoading;

  const AuthAuthenticated({
    required this.user,
    this.isLoading = false,
  });

  AuthAuthenticated copyWith({
    UserEntity? user,
    bool? isLoading,
  }) {
    return AuthAuthenticated(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props =>
      [user, isLoading]; // No nullable items here, so List<Object> is fine
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final UserEntity? user; // This is the nullable field causing the issue

  const AuthError({required this.message, this.user});

  @override
  // Now this override is valid because AuthState.props returns List<Object?>
  List<Object?> get props => [message, user];
}

class AuthPasswordResetEmailSent extends AuthState {
  const AuthPasswordResetEmailSent();
}