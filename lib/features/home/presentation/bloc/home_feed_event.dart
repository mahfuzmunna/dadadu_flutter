// lib/features/home/presentation/bloc/home_feed_event.dart

// THIS LINE IS CRUCIAL
part of 'home_feed_bloc.dart';

@immutable
abstract class HomeFeedEvent extends Equatable {
  const HomeFeedEvent();

  @override
  List<Object?> get props => [];
}

class FetchPosts extends HomeFeedEvent {
  final bool isInitialFetch;

  const FetchPosts({this.isInitialFetch = true});

  @override
  List<Object?> get props => [isInitialFetch];
}