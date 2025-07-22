// lib/features/upload/presentation/bloc/upload_bloc.dart
import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// Ensure these imports are correct based on your project structure
import '../../../../core/usecases/usecase.dart'; // For NoParams
import '../../../auth/domain/entities/user_entity.dart'; // To get current user ID
import '../../../auth/domain/usecases/get_current_user_usecase.dart'; // To get current user ID
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/upload_post_usecase.dart';

part 'upload_event.dart'; // Links to upload_event.dart
part 'upload_state.dart'; // Links to upload_state.dart

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final UploadPostUseCase uploadPostUseCase;
  final GetCurrentUserUseCase
      getCurrentUserUseCase; // To get the authenticated user's ID

  UploadBloc({
    required this.uploadPostUseCase,
    required this.getCurrentUserUseCase,
  }) : super(UploadInitial()) {
    // Register the event handler for UploadPostRequested
    on<UploadPostRequested>(_onUploadPostRequested);
  }

  /// Handles the [UploadPostRequested] event.
  /// Orchestrates the process of getting the user, uploading files, and creating the post.
  Future<void> _onUploadPostRequested(
    UploadPostRequested event,
    Emitter<UploadState> emit,
  ) async {
    emit(UploadLoading()); // Emit loading state

    // 1. Get the current authenticated user's ID
    final userResult = await getCurrentUserUseCase(NoParams());
    UserEntity? currentUser;

    userResult.fold(
      (failure) {
        // If getting user fails, emit error and stop
        emit(UploadError(
            message: 'Failed to get current user: ${failure.message}'));
        return;
      },
      (user) {
        currentUser = user; // Set the current user
      },
    );

    // Ensure a valid user ID is available
    if (currentUser == null) {
      emit(const UploadError(
          message:
              'User not authenticated or user ID not found. Cannot upload post.'));
      return;
    }

    final String userId = currentUser!.uid;

    // 2. Call the Use Case to handle file uploads and post creation
    final result = await uploadPostUseCase(
      UploadPostParams(
        videoFile: event.videoFile,
        thumbnailFile: event.thumbnailFile, // Pass the thumbnail file
        userId: userId,
        description: event.description,
        videoUrl: '',
        thumbnailUrl: '',
        tag: '',
        location: '',
      ),
    );

    // 3. Handle the result from the Use Case
    result.fold(
      (failure) => emit(UploadError(message: failure.message)),
      // If use case fails, emit error
      (post) =>
          emit(UploadSuccess(post: post)), // If use case succeeds, emit success
    );
  }
}
