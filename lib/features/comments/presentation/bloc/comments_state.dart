part of 'comments_bloc.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object> get props => [];
}

/// State emitted when an error occurs while fetching comments.

class CommentPosting extends CommentsState {}

class CommentPosted extends CommentsState {}

// lib/features/comments/presentation/bloc/comments_state.dart

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

/// State when comments are successfully loaded.
/// It holds separate lists for recent and popular comments.
class CommentsLoaded extends CommentsState {
  final List<CommentEntity> recent;
  final List<CommentEntity> popular;

  const CommentsLoaded({this.recent = const [], this.popular = const []});

  @override
  List<Object> get props => [recent, popular];
}

/// State when adding a comment is in progress.
class CommentAdding extends CommentsState {}

/// State when a comment has been successfully added.
/// You can use this to show a confirmation message.
class CommentAdded extends CommentsState {}

/// State for any errors related to loading or adding comments.
class CommentsError extends CommentsState {
  final String message;

  const CommentsError(this.message);

  @override
  List<Object> get props => [message];
}