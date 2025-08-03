// lib/features/now/presentation/bloc/feed_event.dart
part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object> get props => [];
}

class SubscribeToFeed extends FeedEvent {}

class SubscribeToFeedWithTags extends FeedEvent {
  final List<String> tags;

  const SubscribeToFeedWithTags({required this.tags});
  @override
  List<Object> get props => [tags];
}

class RefreshFeed extends FeedEvent {}
