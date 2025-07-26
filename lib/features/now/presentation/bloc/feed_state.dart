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
  final List<PostEntity> posts;
  final Map<String, UserEntity> authors;

  const FeedLoaded({required this.posts, required this.authors});

  @override
  List<Object> get props => [posts, authors];
}

class FeedError extends FeedState {
  final String message;

  const FeedError({required this.message});

  @override
  List<Object> get props => [message];
}
