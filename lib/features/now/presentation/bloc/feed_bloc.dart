// feed_bloc.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/datasources/feed_remote_data_source.dart';
import '../../domain/repositories/feed_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository _repository;
  StreamSubscription<FeedResult>? _subscription;

  FeedBloc({required FeedRepository repository})
      : _repository = repository,
        super(FeedInitial()) {
    on<SubscribeToFeed>(_onSubscribe);
    on<RefreshFeed>(_onRefresh);
  }

  void _onSubscribe(SubscribeToFeed event, Emitter<FeedState> emit) {
    emit(FeedLoading());
    _subscription?.cancel();
    _subscription = _repository.streamFeed().listen(
      (result) {
        if (result.data.posts.isEmpty) {
          emit(const FeedLoaded(data: FeedData([], {})));
          return;
        }

        if (result.isPartial) {
          emit(FeedLoaded(
              data: result.data, degraded: true, message: result.errorMessage));
        } else {
          emit(FeedLoaded(data: result.data));
        }
      },
      onError: (e) {
        emit(FeedError(message: e.toString()));
      },
    );
  }

  void _onRefresh(RefreshFeed event, Emitter<FeedState> emit) {
    // Re-subscribe to force fresh data if needed
    add(SubscribeToFeed());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
