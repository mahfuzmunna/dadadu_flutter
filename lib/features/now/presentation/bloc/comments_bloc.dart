import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/now/domain/repositories/comments_repository.dart';
import 'package:dadadu_app/features/posts/domain/usecases/get_post_comments_usecase.dart';
import 'package:equatable/equatable.dart';

import '../../data/datasources/comments_remote_data_source.dart';

part 'comments_event.dart';
part 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  // Comment Stream Subscription

  final CommentsRepository _repository;
  StreamSubscription<CommentsResult>? _externalSub;

  final GetPostCommentsUseCase _getPostCommentsUseCase;
  final AddCommentUseCase _addCommentUseCase;

  CommentsBloc(
      {required GetPostCommentsUseCase getPostCommentsUseCase,
      required CommentsRepository repository,
      required AddCommentUseCase addCommentUseCase})
      : _getPostCommentsUseCase = getPostCommentsUseCase,
        _addCommentUseCase = addCommentUseCase,
        _repository = repository,
        super(CommentsInitial()) {
    on<AddComment>(_onAddComment);
    on<SubscribeToComments>(_onSubscribe);
    on<RefreshComments>(_onRefresh);
  }

  void _onAddComment(AddComment event, Emitter<CommentsState> emit) async {
    emit(CommentAdding());
    final result = await _addCommentUseCase(event.params);

    result.fold(
      (failure) => emit(CommentsError(failure.message)),
      (_) {
        emit(CommentAdded());
        add(RefreshComments(postId: event.params.postId));
        // After successfully adding, refresh the comments list.
        // add(LoadComments(event.params.postId));
      },
    );
  }

  Future<void> _onSubscribe(
      SubscribeToComments event, Emitter<CommentsState> emit) async {
    emit(CommentsLoading());

    // Cancel any previous external subscription if you still keep it
    await _externalSub?.cancel();
    _externalSub = null;

    // Use emit.forEach to properly integrate the stream into the handler
    await emit.forEach<CommentsResult>(
      _repository.streamComments(postId: event.postId),
      onData: (result) {
        if (result.data.comments.isEmpty) {
          return const CommentsLoaded(data: CommentsData([], {}));
        }
        if (result.isPartial) {
          return CommentsLoaded(
            data: result.data,
            degraded: true,
            message: result.errorMessage,
          );
        }
        return CommentsLoaded(data: result.data);
      },
      onError: (error, _) {
        return CommentsError(error.toString());
      },
    );
  }

  Future<void> _onRefresh(
      RefreshComments event, Emitter<CommentsState> emit) async {
    // Simply re-subscribe by calling the same logic
    await _onSubscribe(SubscribeToComments(postId: event.postId), emit);
  }

  @override
  Future<void> close() async {
    await _externalSub?.cancel();
    return super.close();
  }
}
