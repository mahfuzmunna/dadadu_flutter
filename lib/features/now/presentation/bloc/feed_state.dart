// lib/features/now/presentation/bloc/feed_state.dart
part of 'feed_bloc.dart';

abstract class FeedState {
  const FeedState();
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final FeedData data;
  final bool degraded;
  final String? message;

  const FeedLoaded({
    required this.data,
    this.degraded = false,
    this.message,
  });
}

class FeedError extends FeedState {
  final String message;

  const FeedError(this.message);
}
