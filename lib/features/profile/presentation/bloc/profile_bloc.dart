// lib/features/profile/presentation/bloc/profile_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // For @immutable

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart'; // For NoParams, if applicable
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart'; // To get the current authenticated user
// import '../../domain/entities/user_entity.dart'; // Reusing UserEntity from Auth
import '../../../home/domain/entities/post_entity.dart';
import '../../domain/usecases/delete_profile_image_usecase.dart';
import '../../domain/usecases/get_posts_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_profile_image_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final GetPostsUseCase getPostsUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UploadProfileImageUseCase uploadProfileImageUseCase;
  final DeleteProfileImageUseCase deleteProfileImageUseCase;

  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.updateProfileUseCase,
    required this.getPostsUseCase,
    required this.getCurrentUserUseCase,
    required this.uploadProfileImageUseCase,
    required this.deleteProfileImageUseCase,
  }) : super(ProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<LoadUserPosts>(_onLoadUserPosts);
    on<UploadProfileImage>(_onUploadProfileImage);
    on<DeleteProfileImage>(_onDeleteProfileImage);
  }

  Future<void> _onLoadUserProfile(
      LoadUserProfile event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    // First, try to get the current authenticated user's UID
    final currentUserResult = await getCurrentUserUseCase(NoParams());

    await currentUserResult.fold(
      (failure) async =>
          emit(ProfileError(message: _mapFailureToMessage(failure))),
      (currentUser) async {
        if (currentUser == null) {
          // If no current user, we can't load a profile for the authenticated user.
          // This might indicate an unauthenticated state, or an error.
          emit(const ProfileError(
              message: 'No authenticated user to load profile for.'));
          return;
        }

        // Use the event's userId if provided (for viewing other profiles),
        // otherwise use the current authenticated user's UID.
        final targetUserId = event.userId ?? currentUser.uid;

        final result = await getUserProfileUseCase(
            GetUserProfileParams(userId: targetUserId));
        result.fold(
          (failure) =>
              emit(ProfileError(message: _mapFailureToMessage(failure))),
          (userProfile) => emit(ProfileLoaded(user: userProfile)),
        );
      },
    );
  }

  Future<void> _onUpdateUserProfile(
      UpdateUserProfile event, Emitter<ProfileState> emit) async {
    emit(
        const ProfileUpdating()); // Or ProfileLoaded.copyWith(isUpdating: true) if you want to keep data
    final result = await updateProfileUseCase(
        event.user); // event.user is already a UserEntity
    result.fold(
      (failure) => emit(ProfileError(message: _mapFailureToMessage(failure))),
      (_) {
        // After successful update, reload the profile to get the latest data
        add(LoadUserProfile(userId: event.user.uid));
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

  Future<void> _onUploadProfileImage(
      UploadProfileImage event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(isUploadingImage: true));
    } else {
      emit(const ProfileLoading()); // Or a more specific state
    }

    final result = await uploadProfileImageUseCase(UploadProfileImageParams(
      userId: event.userId,
      imagePath: event.imagePath,
    ));

    result.fold(
      (failure) => emit(ProfileError(message: _mapFailureToMessage(failure))),
      (newImageUrl) {
        // Assuming success means the user profile needs to be refreshed to show the new image
        add(LoadUserProfile(
            userId: event.userId)); // Reload profile to get new image URL
      },
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
}