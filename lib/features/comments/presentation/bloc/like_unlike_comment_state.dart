part of 'like_unlike_comment_bloc.dart';

abstract class LikeUnlikeState extends Equatable {
  const LikeUnlikeState();

  @override
  List<Object> get props => [];
}

class LikeUnlikeInitial extends LikeUnlikeState {}

class LikeUnlikeLoading extends LikeUnlikeState {}

class LikeUnlikeSuccess extends LikeUnlikeState {}

class LikeUnlikeFailure extends LikeUnlikeState {
  final String message;

  const LikeUnlikeFailure(this.message);
}

class LikeUnlikeError extends LikeUnlikeState {
  final String message;

  const LikeUnlikeError(this.message);

  @override
  List<Object> get props => [message];
}
