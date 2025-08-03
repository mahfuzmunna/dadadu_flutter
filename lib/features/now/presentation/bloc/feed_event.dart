// lib/features/now/presentation/bloc/feed_event.dart
part of 'feed_bloc.dart';

abstract class FeedEvent {}

class SubscribeToFeed extends FeedEvent {}

class RefreshFeed extends FeedEvent {}
