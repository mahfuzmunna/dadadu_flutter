// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // For @immutable

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart'; // For NoParams
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/send_password_reset_email_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase;

  AuthBloc({
    required this.authRepository,
    required this.getCurrentUserUseCase,
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.sendPasswordResetEmailUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthResetPasswordRequested>(_onAuthResetPasswordRequested);
    on<AuthRefreshCurrentUser>(_onAuthRefreshCurrentUser); // NEW HANDLER
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      // Failure means unauthenticated
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onAuthSignInRequested(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signInUseCase(SignInParams(
      email: event.email,
      password: event.password,
    ));
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onAuthSignUpRequested(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signUpUseCase(SignUpParams(
      email: event.email,
      password: event.password,
      username: event.username,
      firstName: event.firstName,
      lastName: event.lastName,
    ));
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onAuthSignOutRequested(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signOutUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onAuthResetPasswordRequested(
      AuthResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await sendPasswordResetEmailUseCase(
        SendPasswordResetEmailParams(email: event.email));
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) => emit(const AuthPasswordResetEmailSent()),
    );
  }

  // NEW: Handler for refreshing current user data
  Future<void> _onAuthRefreshCurrentUser(
      AuthRefreshCurrentUser event, Emitter<AuthState> emit) async {
    // Keep existing state but indicate loading if current state is Authenticated
    if (state is AuthAuthenticated) {
      emit(AuthAuthenticated(
          user: (state as AuthAuthenticated).user, isLoading: true));
    } else {
      emit(const AuthLoading());
    }

    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(
        message:
            'Failed to refresh user data: ${_mapFailureToMessage(failure)}',
        user: (state is AuthAuthenticated)
            ? (state as AuthAuthenticated).user
            : null, // Keep old user if available
      )),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          // If for some reason user is null after refresh (e.g., signed out externally)
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return 'Cache Error';
    } else if (failure is CacheFailure) {
      return failure.message;
    }
    return 'Unexpected Error';
  }
}