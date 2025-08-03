// lib/features/now/presentation/bloc/feed_state.dart
part of 'feed_bloc.dart';

abstract class FeedState extends Equatable {
  const FeedState();
  @override
  List<Object> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final FeedData data;
  final bool
      degraded; // true if some authors failed to load but posts are present
  final String? message; // optional warning

  const FeedLoaded({
    required this.data,
    this.degraded = false,
    this.message,
  });
}

class FeedError extends FeedState {
  final String message;
  const FeedError({required this.message});
  @override
  List<Object> get props => [message];
}
