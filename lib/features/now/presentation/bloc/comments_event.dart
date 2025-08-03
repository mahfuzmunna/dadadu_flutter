part of 'comments_bloc.dart';

// lib/features/comments/presentation/bloc/comments_event.dart

abstract class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object> get props => [];
}

/// Event to fetch all comments for a specific post.


/// Event to add a new comment to a post.
class AddComment extends CommentsEvent {
  final CommentParams params;
  const AddComment(this.params);

  @override
  List<Object> get props => [params];
}

class SubscribeToComments extends CommentsEvent {
  final String postId;

  const SubscribeToComments({required this.postId});

  @override
  List<Object> get props => [postId];
}

class RefreshComments extends CommentsEvent {
  final String postId;

  const RefreshComments({required this.postId});

  @override
  List<Object> get props => [postId];
}
