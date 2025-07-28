import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/posts/domain/repositories/post_repository.dart';
import 'package:dadadu_app/features/posts/domain/usecases/upload_post_usecase.dart';
import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../upload/domain/entities/post_entity.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final UploadPostUseCase _uploadPostUseCase;
  final PostRepository _postRepository;
  final ProfileRepository _profileRepository;
  StreamSubscription<PostEntity>? _postSubscription;

  PostBloc(
      {required UploadPostUseCase uploadPostUseCase,
      required PostRepository postRepository,
      required ProfileRepository profileRepository})
      : _uploadPostUseCase = uploadPostUseCase,
        _postRepository = postRepository,
        _profileRepository = profileRepository,
        super(UploadInitial()) {
    on<UploadPost>(_onUploadPost);
    on<_UploadProgressUpdated>(_onUploadProgressUpdated);
    on<LoadPost>(_onLoadPost);
    on<_PostUpdated>(_onPostUpdated);
  }

  Future<void> _onLoadPost(LoadPost event, Emitter<PostState> emit) async {
    await _postSubscription?.cancel();
    emit(PostLoading());

    final initialPostResult = await _postRepository.getPostById(event.postId);

    await initialPostResult.fold(
      (failure) async => emit(PostError(failure.message)),
      (post) async {
        final authorResult =
            await _profileRepository.getUserProfile(post.userId);
        authorResult.fold(
          (failure) => emit(PostError(failure.message)),
          (author) {
            emit(PostLoaded(post: post, author: author));
            final streamResult =
                _postRepository.subscribeToPostChanges(event.postId);
            streamResult.fold((failure) => emit(PostError(failure.message)),
                (postStream) {
              _postSubscription = postStream.listen(
                  (updatedPost) => add(_PostUpdated(post: updatedPost)));
            });
          },
        );
      },
    );
  }

  void _onPostUpdated(_PostUpdated event, Emitter<PostState> emit) {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      emit(currentState.copyWith(post: event.post));
    }
  }

  Future<void> _onUploadPost(UploadPost event, Emitter<PostState> emit) async {
    emit(const UploadInProgress(0.0));
    final result = await _uploadPostUseCase(UploadPostParams(
      videoFile: event.videoFile,
      thumbnailBytes: event.thumbnailBytes,
      caption: event.caption,
      intent: event.intent,
      userId: event.userId,
      onUploadProgress: (progress) {
        if (!isClosed) {
          add(_UploadProgressUpdated(progress));
        }
      },
    ));
    result.fold(
      (failure) => emit(UploadFailure(failure.message)),
      (_) => emit(UploadSuccess()),
    );
  }

  void _onUploadProgressUpdated(_UploadProgressUpdated event,
      Emitter<PostState> emit) {
    emit(UploadInProgress(event.progress));
  }

  @override
  Future<void> close() {
    _postSubscription?.cancel();
    return super.close();
  }
}

// Create the corresponding event and state files for this BLoC