// lib/features/now/presentation/bloc/post_event.dart
part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

/// Dispatched to load and subscribe to a specific post's updates.
class LoadPost extends PostEvent {
  final String postId;

  const LoadPost(this.postId);

  @override
  List<Object> get props => [postId];
}

/// A public event dispatched when a user likes a post.
class IncrementLike extends PostEvent {
  final String postId;

  const IncrementLike(this.postId);

  @override
  List<Object> get props => [postId];
}

/// An internal event used to push updates from the realtime stream into the bloc.
class _PostUpdated extends PostEvent {
  final PostEntity post;

  const _PostUpdated({required this.post});

  @override
  List<Object> get props => [post];
}