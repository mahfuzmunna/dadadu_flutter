import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:start/core/errors/failures.dart';
import 'package:start/features/auth/domain/entities/user_entity.dart';
import 'package:start/features/auth/domain/usecases/params.dart';
import 'package:start/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:start/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:start/features/auth/domain/repositories/auth_repository.dart'; // Import the repository for authStateChanges

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final AuthRepository authRepository; // Use repository for authStateChanges

  late StreamSubscription<UserEntity?> _userSubscription;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);

    _userSubscription = authRepository.authStateChanges.listen(
          (user) => add(AuthStatusChanged(user)),
    );
  }

  Future<void> _onSignInRequested(
      SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result =
    await signInUseCase(Params(email: event.email, password: event.password));
    result.fold(
          (failure) => emit(AuthError(_mapFailureToMessage(failure))),
          (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignUpRequested(
      SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result =
    await signUpUseCase(Params(email: event.email, password: event.password));
    result.fold(
          (failure) => emit(AuthError(_mapFailureToMessage(failure))),
          (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(
      SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.signOut(); // Call signOut directly from repository
    result.fold(
          (failure) => emit(AuthError(_mapFailureToMessage(failure))),
          (_) => emit(Unauthenticated()),
    );
  }

  void _onAuthStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(Unauthenticated());
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return 'Cache Error';
    }
    return 'Unexpected Error';
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}