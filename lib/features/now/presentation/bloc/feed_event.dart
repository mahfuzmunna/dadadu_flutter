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
  const _FeedUpdated(this.posts);

  @override
  List<Object> get props => [posts];
}
