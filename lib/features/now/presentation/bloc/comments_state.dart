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

class CommentsLoaded extends CommentsState {
  final CommentsData data;
  final bool degraded;
  final String? message;

  const CommentsLoaded({
    required this.data,
    this.degraded = false,
    this.message,
  });
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
