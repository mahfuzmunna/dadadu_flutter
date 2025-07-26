// lib/features/now/presentation/bloc/feed_event.dart
part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object> get props => [];
}

class SubscribeToFeed extends FeedEvent {}

class _FeedUpdated extends FeedEvent {
  final List<PostEntity> posts;
  final Map<String, UserEntity> authors;

  const _FeedUpdated({required this.posts, required this.authors});

  @override
  List<Object> get props => [posts, authors];
}
