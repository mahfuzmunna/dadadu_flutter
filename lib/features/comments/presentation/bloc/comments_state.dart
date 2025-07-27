part of 'comments_bloc.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object> get props => [];
}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

/// State emitted when comments have been successfully loaded and sorted.
class CommentsLoaded extends CommentsState {
  /// A list of comments sorted by timestamp (newest first).
  final List<CommentEntity> recent;

  /// A list of comments sorted by the number of likes (most liked first).
  final List<CommentEntity> popular;

  const CommentsLoaded({required this.recent, required this.popular});

  @override
  List<Object> get props => [recent, popular];
}

/// State emitted when an error occurs while fetching comments.
class CommentsError extends CommentsState {
  final String message;

  const CommentsError(this.message);

  @override
  List<Object> get props => [message];
}
