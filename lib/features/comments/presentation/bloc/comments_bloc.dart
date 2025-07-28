import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/comments/domain/entities/comment_entity.dart';
import 'package:dadadu_app/features/posts/domain/usecases/get_post_comments_usecase.dart';
import 'package:equatable/equatable.dart';

part 'comments_event.dart';
part 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final GetPostCommentsUseCase _getPostCommentsUseCase;
  final AddCommentUseCase _addCommentUseCase;

  CommentsBloc(
      {required GetPostCommentsUseCase getPostCommentsUseCase,
      required AddCommentUseCase addCommentUseCase})
      : _getPostCommentsUseCase = getPostCommentsUseCase,
        _addCommentUseCase = addCommentUseCase,
        super(CommentsInitial()) {
    on<LoadComments>(_onLoadComments);
    on<AddComment>(_onAddComment);
  }

  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<CommentsState> emit,
  ) async {
    emit(CommentsLoading());
    final result = await _getPostCommentsUseCase(event.postId);
    result.fold(
      (failure) => emit(CommentsError(failure.message)),
      (comments) {
        // Sort for "Recent" tab
        final recentComments = List<CommentEntity>.from(comments)
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        // Sort for "Popular" tab
        final popularComments = List<CommentEntity>.from(comments)
          ..sort((a, b) => b.likes.compareTo(a.likes));

        emit(CommentsLoaded(recent: recentComments, popular: popularComments));
      },
    );
  }

  void _onAddComment(AddComment event, Emitter<CommentsState> emit) async {
    emit(CommentAdding());
    final result = await _addCommentUseCase(event.params);

    result.fold(
      (failure) => emit(CommentsError(failure.message)),
      (_) {
        emit(CommentAdded());
        // After successfully adding, refresh the comments list.
        add(LoadComments(event.params.postId));
      },
    );
  }
}
