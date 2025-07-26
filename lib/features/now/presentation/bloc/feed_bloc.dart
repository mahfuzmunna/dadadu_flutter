// lib/features/now/presentation/bloc/feed_bloc.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/posts/domain/usecases/stream_all_posts_usecase.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:equatable/equatable.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final StreamAllPostsUseCase _streamAllPostsUseCase;
  StreamSubscription<List<PostEntity>>? _feedSubscription;

  FeedBloc({required StreamAllPostsUseCase streamAllPostsUseCase})
      : _streamAllPostsUseCase = streamAllPostsUseCase,
        super(FeedInitial()) {
    on<SubscribeToFeed>(_onSubscribeToFeed);
    on<_FeedUpdated>(_onFeedUpdated);
  }

  Future<void> _onSubscribeToFeed(
      SubscribeToFeed event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    _feedSubscription?.cancel(); // Cancel any existing subscription
    final result = await _streamAllPostsUseCase(null);
    result.fold(
      (failure) => emit(FeedError(message: failure.message)),
      (feedStream) {
        _feedSubscription = feedStream.listen((posts) {
          add(_FeedUpdated(posts));
        });
      },
    );
  }

  void _onFeedUpdated(_FeedUpdated event, Emitter<FeedState> emit) {
    emit(FeedLoaded(event.posts));
  }

  @override
  Future<void> close() {
    _feedSubscription?.cancel();
    return super.close();
  }
}
