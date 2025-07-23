// lib/features/profile/presentation/bloc/profile_state.dart

part of 'profile_bloc.dart';

@immutable
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

// State for when profile data is loaded
class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final List<PostEntity> posts; // Posts related to this user
  final bool isLoadingPosts; // To indicate if posts are still loading
  final bool isUpdating; // To indicate if profile data is being updated
  final bool isUploadingImage; // To indicate if profile image is being uploaded
  final bool isDeletingImage; // To indicate if profile image is being deleted

  const ProfileLoaded({
    required this.user,
    this.posts = const [],
    this.isLoadingPosts = false,
    this.isUpdating = false,
    this.isUploadingImage = false,
    this.isDeletingImage = false,
  });

  ProfileLoaded copyWith({
    UserEntity? user,
    List<PostEntity>? posts,
    bool? isLoadingPosts,
    bool? isUpdating,
    bool? isUploadingImage,
    bool? isDeletingImage,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      posts: posts ?? this.posts,
      isLoadingPosts: isLoadingPosts ?? this.isLoadingPosts,
      isUpdating: isUpdating ?? this.isUpdating,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      isDeletingImage: isDeletingImage ?? this.isDeletingImage,
    );
  }

  @override
  List<Object?> get props => [
        user,
        posts,
        isLoadingPosts,
        isUpdating,
        isUploadingImage,
        isDeletingImage,
      ];
}

// State specifically for loading posts if the profile is already loaded
class ProfileLoadingPosts extends ProfileState {
  const ProfileLoadingPosts();
}

// State for when only user's posts are loaded (e.g., initial load only for posts)
class UserPostsLoaded extends ProfileState {
  final List<PostEntity> posts;

  const UserPostsLoaded({required this.posts});

  @override
  List<Object> get props => [posts];
}

class ProfileUpdateSuccess extends ProfileState {
  final String photoUrl;

  const ProfileUpdateSuccess(this.photoUrl);

  @override
  List<Object> get props => [photoUrl];
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

// Emitted when the profile (including location) is successfully updated
class UserLocationUpdateSuccess extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}