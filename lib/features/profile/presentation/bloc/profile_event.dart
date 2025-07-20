part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends ProfileEvent {
  final String uid;

  const LoadUserProfile({required this.uid});

  @override
  List<Object> get props => [uid];
}

class UpdateUserProfile extends ProfileEvent {
  final UserEntity user;

  const UpdateUserProfile({required this.user});

  @override
  List<Object> get props => [user];
}

class UpdateUserModeEmoji extends ProfileEvent {
  final String uid;
  final String emoji;

  const UpdateUserModeEmoji({required this.uid, required this.emoji});

  @override
  List<Object> get props => [uid, emoji];
}