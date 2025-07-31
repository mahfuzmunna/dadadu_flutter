import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/like_unlike_comment_usecase.dart';

// Make sure to create and import your use cases

part 'like_unlike_comment_event.dart';
part 'like_unlike_comment_state.dart';

class LikeUnlikeCommentBloc extends Bloc<LikeUnlikeEvent, LikeUnlikeState> {
  final LikeCommentUseCase _likeCommentUseCase;
  final UnlikeCommentUseCase _unlikeCommentUseCase;

  LikeUnlikeCommentBloc({
    required LikeCommentUseCase likeCommentUseCase,
    required UnlikeCommentUseCase unlikeCommentUseCase,
  })  : _likeCommentUseCase = likeCommentUseCase,
        _unlikeCommentUseCase = unlikeCommentUseCase,
        super(LikeUnlikeInitial()) {
    on<LikeComment>(_onLikeComment);
    on<UnlikeComment>(_onUnlikeComment);
  }

  Future<void> _onLikeComment(
      LikeComment event, Emitter<LikeUnlikeState> emit) async {
    emit(LikeUnlikeLoading());
    final result = await _likeCommentUseCase(LikeUnlikeParams(
      userId: event.userId,
      postId: event.postId,
      commentId: event.commentId,
    ));
    result.fold(
      (failure) => emit(LikeUnlikeError(failure.message)),
      (_) => emit(LikeUnlikeSuccess()),
    );
  }

  Future<void> _onUnlikeComment(
      UnlikeComment event, Emitter<LikeUnlikeState> emit) async {
    emit(LikeUnlikeLoading());
    final result = await _unlikeCommentUseCase(LikeUnlikeParams(
      userId: event.userId,
      postId: event.postId,
      commentId: event.commentId,
    ));
    result.fold(
      (failure) => emit(LikeUnlikeError(failure.message)),
      (_) => emit(LikeUnlikeSuccess()),
    );
  }
}
