// lib/features/home/presentation/bloc/feed_state.dart
part of 'feed_bloc.dart';

abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<PostEntity> posts;

  const FeedLoaded(this.posts);

  @override
  List<Object> get props => [posts];
}

class FeedError extends FeedState {
  final String message;

  const FeedError({required this.message});

  @override
  List<Object> get props => [message];
}
