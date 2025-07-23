// lib/features/profile/presentation/bloc/profile_event.dart

part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  // Change return type to List<Object?> to allow nullable properties in derived events
  List<Object?> get props => [];
}

class LoadUserProfile extends ProfileEvent {
  final String?
      userId; // Optional: to load a specific user's profile, else current user

  const LoadUserProfile({this.userId});

  @override
  // Now this override is valid because ProfileEvent.props returns List<Object?>
  List<Object?> get props => [userId];
}

class UpdateUserProfileData extends ProfileEvent {
  final UserEntity user;

  const UpdateUserProfileData({required this.user});
  @override
  List<Object> get props => [user];
}

class LoadUserPosts extends ProfileEvent {
  final String userId;

  const LoadUserPosts({required this.userId});

  @override
  // This can remain List<Object> as 'userId' is non-nullable
  List<Object> get props => [userId];
}

class UpdateProfilePhoto extends ProfileEvent {
  final String userId;
  final File photoFile; // Path to the local image file

  const UpdateProfilePhoto({required this.userId, required this.photoFile});

  @override
  // This can remain List<Object> as both are non-nullable
  List<Object> get props => [userId, photoFile];
}

class DeleteProfileImage extends ProfileEvent {
  final String userId;

  const DeleteProfileImage({required this.userId});

  @override
  // This can remain List<Object> as 'userId' is non-nullable
  List<Object> get props => [userId];
}

class UpdateUserLocation extends ProfileEvent {
  final String userId;
  final double latitude;
  final double longitude;
  final String locationName;

  const UpdateUserLocation({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  List<Object?> get props => [userId, latitude, longitude, locationName];
}

// Event to start listening to profile updates
class SubscribeToUserProfile extends ProfileEvent {
  final String userId;

  const SubscribeToUserProfile(this.userId);

  @override
  List<Object> get props => [userId];
}

// Internal event to push new data from the stream into the BLoC
class _UserProfileUpdated extends ProfileEvent {
  final UserEntity user;

  const _UserProfileUpdated(this.user);
}

class UpdateProfile extends ProfileEvent {
  final UserEntity user;
  final File? photoFile; // The new photo is optional

  const UpdateProfile({required this.user, this.photoFile});

  @override
  List<Object?> get props => [user, photoFile];
}