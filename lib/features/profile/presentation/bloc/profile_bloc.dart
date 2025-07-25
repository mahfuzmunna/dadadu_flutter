// lib/features/profile/presentation/bloc/profile_bloc.dart

import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/profile/domain/usecases/update_user_location_usecase.dart';
import 'package:dadadu_app/features/profile/domain/usecases/update_user_mood_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // For @immutable

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart'; // To get the current authenticated user
// import '../../domain/entities/user_entity.dart'; // Reusing UserEntity from Auth
import '../../../now/domain/entities/post_entity.dart';
import '../../domain/usecases/delete_profile_image_usecase.dart';
import '../../domain/usecases/get_posts_usecase.dart';
import '../../domain/usecases/get_user_profile_data_usecase.dart';
import '../../domain/usecases/update_profile_photo_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileDataUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase _updateProfileUseCase;
  final GetPostsUseCase getPostsUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateProfilePhotoUseCase _updateProfilePhotoUseCase;
  final DeleteProfileImageUseCase deleteProfileImageUseCase;
  final UpdateUserLocationUseCase _updateUserLocationUseCase;
  final UpdateUserMoodUseCase _updateUserMoodUseCase;

  ProfileBloc({
    required this.getUserProfileUseCase,
    required UpdateUserProfileUseCase updateProfileUseCase,
    required this.getPostsUseCase,
    required this.getCurrentUserUseCase,
    required UpdateProfilePhotoUseCase updateProfilePhotoUseCase,
    required this.deleteProfileImageUseCase,
    required UpdateUserLocationUseCase updateUserLocationUseCase,
    required UpdateUserMoodUseCase updateUserMoodUseCase,
  })  : _updateProfilePhotoUseCase = updateProfilePhotoUseCase,
        _updateUserLocationUseCase = updateUserLocationUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _updateUserMoodUseCase = updateUserMoodUseCase,
        super(const ProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfileData>(_onUpdateUserProfileData);
    on<LoadUserPosts>(_onLoadUserPosts);
    on<UpdateProfilePhoto>(_onUpdateProfilePhoto);
    on<DeleteProfileImage>(_onDeleteProfileImage);
    on<UpdateUserLocation>(_onUpdateUserLocation);
    on<UpdateUserMood>(_onUpdateUserMood);
  }

  Future<void> _onLoadUserProfile(
      LoadUserProfile event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    // First, try to get the current authenticated user's UID
    final currentUserResult = await getUserProfileUseCase(
        GetUserProfileParams(userId: event.userId as String));

    currentUserResult.fold(
      (failure) async =>
          emit(ProfileError(message: _mapFailureToMessage(failure))),
      (currentUser) => emit(ProfileLoaded(user: currentUser)),
    );
  }

  Future<void> _onUpdateUserProfileData(
      UpdateUserProfileData event, Emitter<ProfileState> emit) async {
    emit(
        const ProfileUpdating()); // Or ProfileLoaded.copyWith(isUpdating: true) if you want to keep data
    final result = await _updateProfileUseCase(UpdateUserProfileParams(
        event.user)); // event.user is already a UserEntity
    result.fold(
      (failure) => emit(ProfileError(message: _mapFailureToMessage(failure))),
      (_) {
        // After successful update, reload the profile to get the latest data
        emit(ProfileUpdateSuccess());
      },
    );
  }

  Future<void> _onLoadUserPosts(
      LoadUserPosts event, Emitter<ProfileState> emit) async {
    // If we're already loading profile, keep that state, else show loading posts
    if (state is! ProfileLoading && state is! ProfileUpdating) {
      emit(const ProfileLoadingPosts());
    }

    final result = await getPostsUseCase(GetPostsParams(userId: event.userId));
    result.fold(
      (failure) => emit(ProfileError(message: _mapFailureToMessage(failure))),
      (posts) {
        // If profile is already loaded, update it with posts
        if (state is ProfileLoaded) {
          emit((state as ProfileLoaded)
              .copyWith(posts: posts, isLoadingPosts: false));
        } else {
          // Otherwise, just emit the posts state (e.g., if only posts are loaded initially)
          emit(UserPostsLoaded(posts: posts));
        }
      },
    );
  }

  Future<void> _onUpdateProfilePhoto(UpdateProfilePhoto event,
      Emitter<ProfileState> emit,) async {
    emit(ProfileLoading());
    final result = await _updateProfilePhotoUseCase(
      UpdateProfilePhotoParams(
          userId: event.userId, photoFile: event.photoFile),
    );
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (photoUrl) => emit(ProfilePhotoUpdateSuccess(photoUrl)),
    );
  }

  Future<void> _onDeleteProfileImage(
      DeleteProfileImage event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(isDeletingImage: true));
    } else {
      emit(const ProfileLoading());
    }

    final result = await deleteProfileImageUseCase(
        DeleteProfileImageParams(userId: event.userId));

    result.fold(
      (failure) => emit(ProfileError(message: _mapFailureToMessage(failure))),
      (_) {
        // Image deleted, refresh profile to reflect the change (e.g., no profile image)
        add(LoadUserProfile(userId: event.userId));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return 'Cache Error';
    } else if (failure is AuthFailure) {
      return failure.message;
    }
    return 'An unexpected error occurred.';
  }

  Future<void> _onUpdateUserLocation(
    UpdateUserLocation event,
    Emitter<ProfileState> emit,
  ) async {
    // Optionally emit a loading state to show a spinner in the UI
    emit(ProfileLoading());

    // Create the parameters object for the use case
    final params = UpdateUserLocationParams(
      userId: event.userId,
      latitude: event.latitude,
      longitude: event.longitude,
      locationName: event.locationName,
    );

    // Call the use case
    final result = await _updateUserLocationUseCase(params);

    // Handle the result using fold
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (_) => emit(UserLocationUpdateSuccess()),
    );
  }

  Future<void> _onUpdateUserMood(
    UpdateUserMood event,
    Emitter<ProfileState> emit,
  ) async {
    // We don't need a loading state here as it's a quick background update.
    // The UI will update automatically via the real-time stream.
    final result = await _updateUserMoodUseCase(
        UpdateUserMoodParams(userId: event.userId, moodStatus: event.mood));

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (_) {
        // We don't need to emit a success state because the real-time stream
        // will automatically push a new ProfileLoaded state, updating the UI.
      },
    );
  }
}

