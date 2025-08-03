import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/feed_remote_data_source.dart';
import '../../domain/repositories/feed_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository _repository;
  StreamSubscription<FeedResult>? _externalSub;

  FeedBloc({required FeedRepository repository})
      : _repository = repository,
        super(FeedInitial()) {
    on<SubscribeToFeed>(_onSubscribe);
    on<RefreshFeed>(_onRefresh);
  }

  Future<void> _onSubscribe(
      SubscribeToFeed event, Emitter<FeedState> emit) async {
    emit(FeedLoading());

    // Cancel any previous external subscription if you still keep it
    await _externalSub?.cancel();
    _externalSub = null;

    // Use emit.forEach to properly integrate the stream into the handler
    await emit.forEach<FeedResult>(
      _repository.streamFeed(),
      onData: (result) {
        if (result.data.posts.isEmpty) {
          return const FeedLoaded(data: FeedData([], {}));
        }
        if (result.isPartial) {
          return FeedLoaded(
            data: result.data,
            degraded: true,
            message: result.errorMessage,
          );
        }
        return FeedLoaded(data: result.data);
      },
      onError: (error, _) {
        return FeedError(error.toString());
      },
    );
  }

  Future<void> _onRefresh(RefreshFeed event, Emitter<FeedState> emit) async {
    // Simply re-subscribe by calling the same logic
    await _onSubscribe(SubscribeToFeed(), emit);
  }

  @override
  Future<void> close() async {
    await _externalSub?.cancel();
    return super.close();
  }
}
