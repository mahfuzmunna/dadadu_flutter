// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/profile/domain/usecases/get_user_profile_data_usecase.dart';
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

enum AuthenticationStatus {
  unknown,
  onboarding,
  authenticated,
  unauthenticated
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  // This subscription listens to the aliased Supabase AuthState
  StreamSubscription<supabase.AuthState>? _authStateSubscription;

  final SignInWithOAuthUseCase signInWithOAuthUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final GetUserProfileDataUseCase _getUserProfileDataUseCase;

  final _authStatusController =
      StreamController<AuthenticationStatus>.broadcast();

  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required GetUserProfileDataUseCase getUserProfileDataUseCase,
    required this.signInWithOAuthUseCase,
    required this.resetPasswordUseCase,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _getUserProfileDataUseCase = getUserProfileDataUseCase,
        super(AuthInitial()) {
    _setupAuthListener();

    on<AuthInitialCheckRequested>(_onInitialCheck);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthOnboardingComplete>(_onOnboardingComplete);
    on<AuthSignOutRequested>(_onSignOut);
    on<_AuthUserChanged>(_onUserChanged);

    // on<AuthSignInWithOAuthRequested>(_onAuthSignInWithOAuthRequested);
    // on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    // on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthRefreshCurrentUser>(_onAuthRefreshCurrentUser);
  }

  /// Public stream for GoRouter to listen to for redirection.
  Stream<AuthenticationStatus> get status => _authStatusController.stream;

  void _setupAuthListener() {
    // Now explicitly listen to the aliased supabase.AuthState stream
    _authStateSubscription =
        supabase.Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) async {
        final result = await _getCurrentUserUseCase(NoParams());
        result.fold((_) => add(const _AuthUserChanged(null)),
            (user) => add(_AuthUserChanged(user)));
      },
      onError: (_) => add(const AuthUserChanged(null)),
    );
  }

  Future<void> _onInitialCheck(
      AuthInitialCheckRequested event, Emitter<AuthState> emit) async {
    final result = await _getCurrentUserUseCase(NoParams());
    result.fold(
      (_) => emit(const AuthUnauthenticated()), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user: user));
        _authStatusController.add(AuthenticationStatus.authenticated);
      } else {
        emit(const AuthUnauthenticated());
        _authStatusController.add(AuthenticationStatus.unauthenticated);
      }
    });
  }

  Future<void> _onSignIn(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signInUseCase(
        SignInParams(email: event.email, password: event.password));
    result.fold(
        (failure) => emit(AuthUnauthenticated(message: failure.message)), (_) {}
        // (user) => emit(AuthAuthenticated(user: user)), // Success is handled by the onAuthStateChange listener
        );
  }

  Future<void> _onSignUp(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    _authStateSubscription?.pause();
    final result = await _signUpUseCase(SignUpParams(
      email: event.email,
      password: event.password,
      fullName: event.fullName,
      username: event.username,
    ));
    result.fold(
      (failure) {
        _authStateSubscription?.resume();
        emit(AuthUnauthenticated(message: failure.message));
      }, (user) {
      emit(AuthSignUpSuccess(user: user));
      _authStatusController.add(AuthenticationStatus.onboarding);
    });
  }

  void _onOnboardingComplete(
      AuthOnboardingComplete event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(user: event.user));
    _authStatusController.add(AuthenticationStatus.authenticated);
    _authStateSubscription?.resume();
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _signOutUseCase(NoParams());
    // Success is handled by the onAuthStateChange listener
  }

  void _onUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    if (state is AuthSignUpSuccess)
      return; // Don't interrupt the onboarding flow
    if (event.user != null) {
      emit(AuthAuthenticated(user: event.user!));
      _authStatusController.add(AuthenticationStatus.authenticated);
    } else {
      emit(const AuthUnauthenticated());
      _authStatusController.add(AuthenticationStatus.unauthenticated);
    }
  }

/*  Future<void> _onAuthOnboardingComplete(AuthOnboardingComplete event,
      Emitter<AuthState> emit,) async {
    // The user has finished onboarding (uploaded photo or skipped).
    // Now we can emit the final Authenticated state and resume the listener.
    emit(AuthAuthenticated(user: event.user));
    _authStateSubscription?.resume();
    emit(FirstRun(user: event.user));
  }*/

  Future<void> _onAuthSignInWithOAuthRequested(
      AuthSignInWithOAuthRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // Use the aliased supabase.OAuthProvider
    await signInWithOAuthUseCase(
        SignInWithOAuthParams(provider: event.provider));
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
    final result = await _getUserProfileDataUseCase(
        GetUserProfileParams(userId: event.currentUserId));
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
    _authStatusController.close();
    return super.close();
  }
}
