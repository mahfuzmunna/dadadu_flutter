// lib/features/home/presentation/bloc/home_feed_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/features/home/domain/repositories/home_repository.dart';
import 'package:dadadu_app/features/home/domain/usecases/get_posts_usecase.dart';
import 'package:dadadu_app/features/home/domain/usecases/get_user_info_usecase.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';

// THESE TWO LINES ARE CRUCIAL
part 'home_feed_event.dart';
part 'home_feed_state.dart';

const int _postLimit = 5;

class HomeFeedBloc extends Bloc<HomeFeedEvent, HomeFeedState> { // <--- Error points here
  final GetPostsUseCase getPostsUseCase;
  final GetUserInfoUseCase getUserInfoUseCase;

  DocumentSnapshot? _lastDocument;
  List<PostEntity> _allLoadedPosts = [];
  Map<String, UserEntity> _userCache = {};
  bool _hasMore = true;

  HomeFeedBloc({
    required this.getPostsUseCase,
    required this.getUserInfoUseCase,
  }) : super(HomeFeedInitial()) {
    on<FetchPosts>(_onFetchPosts);
  }

  Future<void> _onFetchPosts(FetchPosts event, Emitter<HomeFeedState> emit) async {
    if (state is HomeFeedLoading && !(state as HomeFeedLoading).isFirstFetch) return;

    if (event.isInitialFetch) {
      _allLoadedPosts = [];
      _userCache = {};
      _lastDocument = null;
      _hasMore = true;
      emit(const HomeFeedLoading([], isFirstFetch: true));
    } else if (!_hasMore) {
      return;
    } else {
      emit(HomeFeedLoading(_allLoadedPosts));
    }

    final postsResult = await getPostsUseCase(GetPostsParams(
      limit: _postLimit,
      startAfterDocument: _lastDocument,
    ));

    await postsResult.fold(
          (failure) async {
        emit(HomeFeedError(message: _mapFailureToMessage(failure)));
      },
          (paginationResult) async {
        final newPosts = paginationResult.posts;
        _hasMore = paginationResult.hasMore;
        _lastDocument = paginationResult.lastDocument;

        if (newPosts.isNotEmpty) {
          _allLoadedPosts.addAll(newPosts);
        }

        for (final post in newPosts) {
          if (!_userCache.containsKey(post.userId)) {
            final userResult = await getUserInfoUseCase(GetUserInfoParams(uid: post.userId));
            userResult.fold(
                  (failure) {
                debugPrint('Warning: Could not fetch user info for ${post.userId}: ${_mapFailureToMessage(failure)}');
              },
                  (user) {
                _userCache[post.userId] = user;
              },
            );
          }
        }

        emit(HomeFeedLoaded(
          posts: List.from(_allLoadedPosts),
          userCache: Map.from(_userCache),
          hasMore: _hasMore,
        ));
      },
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