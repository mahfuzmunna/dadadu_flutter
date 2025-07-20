// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:dadadu_app/core/errors/failures.dart'; // Updated package name
import 'package:dadadu_app/core/usecases/usecase.dart'; // Updated package name
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart'; // Updated package name
import 'package:dadadu_app/features/auth/domain/usecases/sign_in_usecase.dart'; // Updated package name
import 'package:dadadu_app/features/auth/domain/usecases/sign_up_usecase.dart'; // Updated package name
import 'package:dadadu_app/features/auth/domain/repositories/auth_repository.dart'; // Updated package name

part 'auth_event.dart';
part 'auth_state.dart'; // <--- Ensure this line is correct

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final AuthRepository authRepository;

  late StreamSubscription _authStateChangesSubscription;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    // Listen to Firebase Auth state changes and map them to AuthStatusChanged events
    _authStateChangesSubscription = authRepository.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        // Fetch full UserModel from Firestore if needed
        final result = await authRepository.getCurrentUser();
        result.fold(
              (failure) => add(AuthStatusChanged(null)), // Handle error, treat as unauthenticated
              (userEntity) => add(AuthStatusChanged(userEntity)),
        );
      } else {
        add(AuthStatusChanged(null)); // No user logged in
      }
    });

    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onAuthStatusChanged(
      AuthStatusChanged event, Emitter<AuthState> emit) async {
    if (event.user != null) {
      emit(Authenticated(user: event.user!)); // <--- Correct usage
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInRequested(
      SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signInUseCase(
      SignInParams(email: event.email, password: event.password),
    );
    result.fold(
          (failure) => emit(Unauthenticated(message: _mapFailureToMessage(failure))),
          (user) => emit(Authenticated(user: user)), // <--- Correct usage
    );
  }

  Future<void> _onSignUpRequested(
      SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signUpUseCase(
      SignUpParams(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        username: event.username,
      ),
    );
    result.fold(
          (failure) => emit(Unauthenticated(message: _mapFailureToMessage(failure))),
          (user) => emit(Authenticated(user: user)), // <--- Correct usage
    );
  }

  Future<void> _onSignOutRequested(
      SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.signOut();
    result.fold(
          (failure) => emit(Unauthenticated(message: _mapFailureToMessage(failure))),
          (_) => emit(Unauthenticated()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return 'Cache Error';
    } else if (failure is InvalidCredentialsFailure) {
      return 'Invalid email or password.';
    } else if (failure is WeakPasswordFailure) {
      return 'The password provided is too weak.';
    } else if (failure is EmailAlreadyInUseFailure) {
      return 'The email address is already in use by another account.';
    } else if (failure is UserNotFoundFailure) {
      return 'No user found for that email.';
    } else if (failure is WrongPasswordFailure) {
      return 'Wrong password provided for that user.';
    } else if (failure is UnknownAuthFailure) {
      return 'An unexpected authentication error occurred.';
    }
    return 'An unexpected error occurred.';
  }

  @override
  Future<void> close() {
    _authStateChangesSubscription.cancel();
    return super.close();
  }
}