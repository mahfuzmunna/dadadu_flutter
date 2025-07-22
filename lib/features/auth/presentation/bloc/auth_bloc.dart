// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_in_with_oauth_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignInWithOAuthUseCase signInWithOAuthUseCase;
  final SignOutUseCase signOutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signInWithOAuthUseCase,
    required this.signOutUseCase,
    required this.resetPasswordUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    on<AuthInitialCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignInWithOAuthRequested>(_onAuthSignInWithOAuthRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthPasswordResetRequested>(_onAuthResetPasswordRequested);
    on<AuthUserChanged>(_onAuthUserChanged);

    // Listen to Supabase's auth state changes and dispatch AuthUserChanged
    _authStateSubscription =
        (signInUseCase.repository.onAuthStateChange()).listen((user) {
      add(AuthUserChanged(user));
    });
  }

  Future<void> _onAuthCheckRequested(AuthInitialCheckRequested event,
      Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthUnauthenticated(message: failure.message)),
      (user) => user != null
          ? emit(AuthAuthenticated(user: user))
          : emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onAuthSignInRequested(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signInUseCase(
        SignInParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onAuthSignUpRequested(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signUpUseCase(
        SignUpParams(email: event.email, password: event.password));
    result.fold(
      (failure) {
        if (failure.code == 'EMAIL_CONFIRMATION_REQUIRED') {
          emit(AuthEmailVerificationRequired(email: event.email));
        } else {
          emit(AuthError(message: failure.message));
        }
      },
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onAuthSignInWithOAuthRequested(
      AuthSignInWithOAuthRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // OAuth typically doesn't return the user immediately.
    // The BLoC listener will catch the subsequent session update.
    final result = await signInWithOAuthUseCase(
        SignInWithOAuthParams(provider: event.provider));
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) {
        // If user is returned immediately, it means they are signed in.
        // If not, it means the browser flow has started and we wait for the deep link.
        // For Supabase, the user is null immediately, and the deep link will trigger AuthUserChanged.
        // We emit AuthLoading and let AuthUserChanged handle final state.
        // Or emit a more specific state like OAuthInProgress.
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          // This state can be used to show a message like "Opening browser..."
          emit(AuthLoading());
        }
      },
    );
  }

  Future<void> _onAuthSignOutRequested(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signOutUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onAuthResetPasswordRequested(AuthPasswordResetRequested event,
      Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result =
        await resetPasswordUseCase(ResetPasswordParams(email: event.email));
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthPasswordResetEmailSent(email: event.email)),
    );
  }

  Future<void> _onAuthUserChanged(
      AuthUserChanged event, Emitter<AuthState> emit) async {
    if (event.user != null) {
      emit(AuthAuthenticated(user: event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}