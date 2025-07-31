part of 'like_unlike_comment_bloc.dart';

abstract class LikeUnlikeEvent extends Equatable {
  const LikeUnlikeEvent();

  @override
  List<Object> get props => [];
}

class LikeComment extends LikeUnlikeEvent {
  final String userId;
  final String postId;
  final String commentId;

  const LikeComment(
      {required this.userId, required this.postId, required this.commentId});

  @override
  List<Object> get props => [userId, commentId];
}

class UnlikeComment extends LikeUnlikeEvent {
  final String userId;
  final String postId;
  final String commentId;

  const UnlikeComment(
      {required this.userId, required this.postId, required this.commentId});

  @override
  List<Object> get props => [userId, commentId];
}
