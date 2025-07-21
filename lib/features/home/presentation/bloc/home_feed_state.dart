// lib/features/home/presentation/bloc/home_feed_state.dart

// THIS LINE IS CRUCIAL
part of 'home_feed_bloc.dart';

@immutable
abstract class HomeFeedState extends Equatable {
  const HomeFeedState();

  @override
  List<Object?> get props => [];
}

class HomeFeedInitial extends HomeFeedState {}

class HomeFeedLoading extends HomeFeedState {
  final List<PostEntity> oldPosts;
  final bool isFirstFetch;

  const HomeFeedLoading(this.oldPosts, {this.isFirstFetch = false});

  @override
  List<Object?> get props => [oldPosts, isFirstFetch];
}

class HomeFeedLoaded extends HomeFeedState {
  final List<PostEntity> posts;
  final Map<String, UserEntity> userCache;
  final bool hasMore;

  const HomeFeedLoaded({
    required this.posts,
    this.userCache = const {},
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [posts, userCache, hasMore];

  HomeFeedLoaded copyWith({
    List<PostEntity>? posts,
    Map<String, UserEntity>? userCache,
    bool? hasMore,
  }) {
    return HomeFeedLoaded(
      posts: posts ?? this.posts,
      userCache: userCache ?? this.userCache,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class HomeFeedError extends HomeFeedState {
  final String message;

  const HomeFeedError({required this.message});

  @override
  List<Object?> get props => [message];
}