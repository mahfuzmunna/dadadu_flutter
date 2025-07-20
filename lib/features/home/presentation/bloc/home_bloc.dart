import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../features/home/domain/entities/post_entity.dart';
import '../../../../features/home/domain/usecases/get_feed_posts_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetFeedPostsUseCase getFeedPostsUseCase;

  HomeBloc({required this.getFeedPostsUseCase}) : super(HomeInitial()) {
    on<LoadFeedPosts>(_onLoadFeedPosts);
  }

  Future<void> _onLoadFeedPosts(LoadFeedPosts event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    final result = await getFeedPostsUseCase(NoParams());
    result.fold(
          (failure) => emit(HomeError(message: _mapFailureToMessage(failure))),
          (posts) => emit(HomeLoaded(posts: posts)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return 'Cache Error';
    }
    return 'Unexpected Error';
  }
}