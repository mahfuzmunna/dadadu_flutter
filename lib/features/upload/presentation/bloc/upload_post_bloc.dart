// lib/features/upload/presentation/bloc/upload_post_bloc.dart

import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:dadadu_app/features/upload/domain/usecases/create_post_in_firestore_usecase.dart';
import 'package:dadadu_app/features/upload/domain/usecases/update_user_uploaded_videos_usecase.dart';
import 'package:dadadu_app/features/upload/domain/usecases/upload_video_to_storage_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

part 'upload_post_event.dart';
part 'upload_post_state.dart';

class UploadPostBloc extends Bloc<UploadPostEvent, UploadPostState> {
  final UploadVideoToStorageUseCase uploadVideoToStorageUseCase;
  final CreatePostInFirestoreUseCase createPostInFirestoreUseCase;
  final UpdateUserUploadedVideosUseCase updateUserUploadedVideosUseCase;
  final Uuid _uuid; // For generating unique IDs

  UploadPostBloc({
    required this.uploadVideoToStorageUseCase,
    required this.createPostInFirestoreUseCase,
    required this.updateUserUploadedVideosUseCase,
  }) : _uuid = const Uuid(), // Initialize Uuid
        super(UploadPostInitial()) {
    on<UploadVideoAndPost>(_onUploadVideoAndPost);
  }

  Future<void> _onUploadVideoAndPost(
      UploadVideoAndPost event, Emitter<UploadPostState> emit) async {
    emit(const UploadPostLoading(progress: 0.0));

    try {
      // 1. Generate a unique ID for the post
      final String postId = _uuid.v4();

      // 2. Upload video to Firebase Storage
      final videoUploadResult = await uploadVideoToStorageUseCase(
        UploadVideoParams(
          videoFile: event.videoFile,
          userId: event.userId,
          postId: postId,
        ),
      );

      String videoUrl = '';
      await videoUploadResult.fold(
            (failure) {
          emit(UploadPostError(message: _mapFailureToMessage(failure)));
          return; // Stop execution if video upload fails
        },
            (url) {
          videoUrl = url;
          emit(const UploadPostLoading(progress: 0.5)); // Update progress
        },
      );

      if (videoUrl.isEmpty) return; // Ensure video URL is available

      // 3. Create post entry in Cloud Firestore
      final newPost = PostEntity(
        id: postId,
        userId: event.userId,
        videoUrl: videoUrl,
        thumbnailUrl: event.thumbnailUrl,
        description: event.description,
        hashtags: event.tag,
        createdAt: DateTime.now(), // Use current time for post timestamp
      );

      final createPostResult = await createPostInFirestoreUseCase(
        CreatePostParams(post: newPost),
      );

      await createPostResult.fold(
            (failure) {
          emit(UploadPostError(message: _mapFailureToMessage(failure)));
          return; // Stop execution if post creation fails
        },
            (_) {
          emit(const UploadPostLoading(progress: 0.8)); // Update progress
        },
      );

      // 4. Update user's uploaded videos list in their profile
      final updateUserVideosResult = await updateUserUploadedVideosUseCase(
        UpdateUserVideosParams(userId: event.userId, videoUrl: videoUrl),
      );

      await updateUserVideosResult.fold(
            (failure) {
          // Log or handle this error, but don't necessarily fail the whole upload
          // as the video and post are already saved.
          print('Warning: Failed to update user\'s video list: ${_mapFailureToMessage(failure)}');
        },
            (_) {
          // Success, progress is now 1.0
        },
      );

      emit(UploadPostSuccess(postId: postId, videoUrl: videoUrl));
    } catch (e) {
      emit(UploadPostError(message: 'An unexpected error occurred: ${e.toString()}'));
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
}