part of 'comments_bloc.dart';

abstract class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object> get props => [];
}

/// Dispatched when the UI needs to load the comments for a specific post.
class LoadComments extends CommentsEvent {
  final String postId;

  const LoadComments(this.postId);

  @override
  List<Object> get props => [postId];
}
