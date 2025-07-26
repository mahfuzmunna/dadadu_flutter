// lib/features/now/presentation/bloc/feed_bloc.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/posts/domain/usecases/stream_feed_usecase.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final StreamFeedUseCase _streamFeedUseCase;
  StreamSubscription<Tuple2<List<PostEntity>, Map<String, UserEntity>>>?
      _feedSubscription;

  FeedBloc({required StreamFeedUseCase streamFeedUseCase})
      : _streamFeedUseCase = streamFeedUseCase,
        super(FeedInitial()) {
    on<SubscribeToFeed>(_onSubscribeToFeed);
    on<_FeedUpdated>(_onFeedUpdated);
  }

  Future<void> _onSubscribeToFeed(SubscribeToFeed event,
      Emitter<FeedState> emit,) async {
    emit(FeedLoading());
    await _feedSubscription?.cancel();

    final result = await _streamFeedUseCase(null);

    result.fold(
      (failure) => emit(FeedError(message: failure.message)),
      (feedStream) {
        _feedSubscription = feedStream.listen((feedData) {
          add(_FeedUpdated(posts: feedData.head, authors: feedData.tail));
        });
      },
    );
  }

  void _onFeedUpdated(_FeedUpdated event, Emitter<FeedState> emit) {
    emit(FeedLoaded(posts: event.posts, authors: event.authors));
  }

  @override
  Future<void> close() {
    _feedSubscription?.cancel();
    return super.close();
  }
}
