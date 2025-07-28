part of 'follow_bloc.dart';

abstract class FollowEvent extends Equatable {
  const FollowEvent();

  @override
  List<Object> get props => [];
}

class FollowUser extends FollowEvent {
  final String currentUserId;
  final String profileUserId;

  const FollowUser({required this.currentUserId, required this.profileUserId});
}

class UnfollowUser extends FollowEvent {
  final String currentUserId;
  final String profileUserId;

  const UnfollowUser(
      {required this.currentUserId, required this.profileUserId});
}
