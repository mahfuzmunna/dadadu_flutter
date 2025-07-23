// lib/features/home/presentation/bloc/post_bloc.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:dadadu_app/features/upload/domain/repositories/post_repository.dart';
import 'package:equatable/equatable.dart';

import '../../../auth/data/models/user_model.dart';
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
    await _postSubscription?.cancel();
    emit(PostLoading());
    final initialPostResult = await _postRepository.getPostById(event.postId);

    initialPostResult.fold((failure) => emit(PostError(failure.message)),
        (post) async {
      try {
        emit(PostLoaded(post: post, author: null));
        final authorResult =
            await _profileRepository.getUserProfile(post.userId);

        authorResult.fold(
          (failure) => emit(PostError(failure.message)),
          (author) {
            emit((state as PostLoaded).copyWith(author: author));
            // Subscribe to the stream of changes for the specific post.
            _postSubscription =
                _postRepository.subscribeToPostChanges(event.postId).listen(
              (post) {
                // When new data arrives from the stream, add an internal event.
                add(_PostUpdated(post: post));
              },
              onError: (error) {
                // If the stream has an error, emit the error state.
                emit(PostError('Failed to load post updates: $error'));
              },
            );
          },
        );
      } catch (e) {
        emit(PostError(e.toString()));
      }
    });
  }

  /// Handles the event when a user likes a post.
  void _onIncrementLike(IncrementLike event, Emitter<PostState> emit) async {
    // We don't need to emit a state here. We just call the repository
    // to perform the action. The realtime stream from `_onLoadPost` will
    // automatically push the updated post data, which triggers `_PostUpdated`
    // and rebuilds the UI with the new like count.
    final result = await _postRepository.incrementDiamond(event.postId);

    // Optionally, handle the failure case to show a snackbar or log the error.
    result.fold(
      (failure) {
        // You could emit a temporary error state or log this.
        print('Failed to increment like: ${failure.message}');
      },
      (_) {
        // Success is handled by the stream.
      },
    );
  }

  /// Handles pushing the updated post from the stream into the state.
  void _onPostUpdated(_PostUpdated event, Emitter<PostState> emit) {
    emit(PostLoaded(post: event.post, author: event.author));
  }

  @override
  Future<void> close() {
    // Always cancel subscriptions when the BLoC is closed.
    _postSubscription?.cancel();
    return super.close();
  }
}
