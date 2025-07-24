// lib/features/now/presentation/bloc/feed_bloc.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:dadadu_app/features/upload/domain/repositories/post_repository.dart';
import 'package:equatable/equatable.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final PostRepository _postRepository;
  StreamSubscription<List<PostEntity>>? _postsSubscription;

  FeedBloc({required PostRepository postRepository})
      : _postRepository = postRepository,
        super(FeedInitial()) {
    on<LoadFeed>(_onLoadFeed);
    on<_FeedUpdated>(_onFeedUpdated);
  }

  Future<void> _onLoadFeed(LoadFeed event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    _postsSubscription?.cancel(); // Cancel any existing subscription
    _postsSubscription = _postRepository.getPostsStream().listen(
          (posts) => add(_FeedUpdated(posts)),
          onError: (error) => emit(FeedError(message: error.toString())),
        );
  }

  void _onFeedUpdated(_FeedUpdated event, Emitter<FeedState> emit) {
    emit(FeedLoaded(event.posts));
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }
}
