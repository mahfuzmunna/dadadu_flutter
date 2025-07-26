// lib/features/now/presentation/bloc/post_bloc.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:dadadu_app/features/upload/domain/repositories/post_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../profile/domain/repositories/profile_repository.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository _postRepository;
  final ProfileRepository _profileRepository;
  StreamSubscription<PostEntity>? _postSubscription;

  PostBloc(
      {required PostRepository postRepository,
      required ProfileRepository profileRepository})
      : _postRepository = postRepository,
        _profileRepository = profileRepository,
        super(PostInitial()) {
    on<LoadPost>(_onLoadPost);
    on<IncrementLike>(_onIncrementLike);
    on<_PostUpdated>(_onPostUpdated);
  }

  /// Handles loading and subscribing to a post.
  Future<void> _onLoadPost(LoadPost event, Emitter<PostState> emit) async {
    debugPrint(
        "--- [PostBloc] Start _onLoadPost for Post ID: ${event.postId} ---");
    await _postSubscription?.cancel();
    emit(PostLoading());
    debugPrint("[PostBloc] Emitted: PostLoading");
    final initialPostResult = await _postRepository.getPostById(event.postId);
    debugPrint("[PostBloc] Fetched initial post data.");

    await initialPostResult.fold(
      (failure) async {
        debugPrint("[PostBloc] Post fetch FAILED: ${failure.message}");
        emit(PostError(failure.message));
      },
      (post) async {
        debugPrint(
            "[PostBloc] Post fetch SUCCESS: '${post.caption}'. Now fetching author...");
        try {
          final authorResult =
              await _profileRepository.getUserProfile(post.userId);
          debugPrint("[PostBloc] Fetched author data.");

          authorResult.fold(
            (failure) {
              debugPrint("[PostBloc] Author fetch FAILED: ${failure.message}");
              emit(PostError(failure.message));
            },
            (author) {
              debugPrint(
                  "[PostBloc] Author fetch SUCCESS: ${author.username}. Emitting complete PostLoaded state.");
              emit(PostLoaded(post: post, author: author));
              debugPrint(
                  "[PostBloc] Emitted: PostLoaded with author: ${author.username}");

              debugPrint(
                  "[PostBloc] Subscribing to real-time updates for post ${event.postId}...");
              _postSubscription = _postRepository
                  .subscribeToPostChanges(event.postId)
                  .listen((updatedPost) {
                debugPrint(
                    "[PostBloc] Real-time update received for post ${updatedPost.id}. Diamonds: ${updatedPost.diamonds}");
                add(_PostUpdated(post: updatedPost));
              });
            },
          );
        } catch (e) {
          debugPrint(
              "[PostBloc] CATCH BLOCK ERROR in author fetch: ${e.toString()}");
          emit(PostError(e.toString()));
        }
      },
    );
  }

  /// Handles the event when a user likes a post.
  void _onIncrementLike(IncrementLike event, Emitter<PostState> emit) async {
    final result = await _postRepository.incrementDiamond(event.postId);
    result.fold(
      (failure) {
      },
      (_) {
        // Success is handled by the stream.
      },
    );
  }

  /// Handles pushing the updated post from the stream into the state.
  void _onPostUpdated(_PostUpdated event, Emitter<PostState> emit) {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      emit(currentState.copyWith(post: event.post));
    }
  }

  @override
  Future<void> close() {
    // Always cancel subscriptions when the BLoC is closed.
    _postSubscription?.cancel();
    return super.close();
  }
}
