// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
// 🔑 FIX: Import Supabase with an alias to prevent name conflicts.
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
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
part 'auth_state.dart'; // This defines YOUR AuthState

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignInWithOAuthUseCase signInWithOAuthUseCase;
  final SignOutUseCase signOutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  // This subscription listens to the aliased Supabase AuthState
  StreamSubscription<supabase.AuthState>? _authStateSubscription;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signInWithOAuthUseCase,
    required this.signOutUseCase,
    required this.resetPasswordUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    _setupAuthListener();

    on<AuthInitialCheckRequested>(_onAuthInitialCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignInWithOAuthRequested>(_onAuthSignInWithOAuthRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthRefreshCurrentUser>(_onAuthRefreshCurrentUser);
  }

  Future<void> _setupAuthListener() async {
    // Now explicitly listen to the aliased supabase.AuthState stream
    _authStateSubscription =
        supabase.Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        final user = data.session?.user;
        if (user != null) {
          add(const AuthRefreshCurrentUser());
        } else {
          add(const AuthUserChanged(null));
        }
      },
      onError: (error) {
        add(const AuthUserChanged(null));
      },
    );
  }

  Future<void> _onAuthInitialCheckRequested(
      AuthInitialCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
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
      (failure) => emit(AuthUnauthenticated(message: failure.message)),
      (_) {}, // Success is handled by the listener
    );
  }

  Future<void> _onAuthSignUpRequested(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // Note: The SignUpUseCase no longer needs the profilePhotoFile parameter
    final result = await signUpUseCase(SignUpParams(
      email: event.email,
      password: event.password,
      fullName: event.fullName,
      username: event.username,
    ));
    result.fold(
      (failure) {
        if (failure.code == 'EMAIL_CONFIRMATION_REQUIRED') {
          emit(AuthEmailVerificationRequired(email: event.email));
        } else {
          emit(AuthError(message: failure.message));
        }
      },
      // ✅ SUCCESS IMPLEMENTATION:
      // When sign-up is successful, emit the new AuthSignUpSuccess state.
      // This gives the UI a clear signal to navigate to the next step,
      // like the 'Upload Profile Photo' page.
      (user) {
        emit(AuthSignUpSuccess(user: user));
      },
    );
  }

  Future<void> _onAuthSignInWithOAuthRequested(
      AuthSignInWithOAuthRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // Use the aliased supabase.OAuthProvider
    await signInWithOAuthUseCase(
        SignInWithOAuthParams(provider: event.provider));
  }

  Future<void> _onAuthSignOutRequested(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await signOutUseCase(NoParams());
    // Success is handled by the listener
  }

  Future<void> _onAuthPasswordResetRequested(
      AuthPasswordResetRequested event, Emitter<AuthState> emit) async {
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

  Future<void> _onAuthRefreshCurrentUser(
      AuthRefreshCurrentUser event, Emitter<AuthState> emit) async {
    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) => user != null
          ? emit(AuthAuthenticated(user: user))
          : emit(const AuthUnauthenticated()),
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}

// Ensure your events and states are also updated to use the alias where necessary.
// For example, in auth_event.dart:

// class AuthSignInWithOAuthRequested extends AuthEvent {
//   final supabase.OAuthProvider provider; // Explicitly use the aliased type
//   ...
// }
