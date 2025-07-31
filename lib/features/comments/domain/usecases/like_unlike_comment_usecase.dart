import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../posts/domain/repositories/post_repository.dart';

class LikeCommentUseCase implements UseCase<void, LikeUnlikeParams> {
  final PostRepository repository;

  LikeCommentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(LikeUnlikeParams params) async {
    return await repository.likeComment(
        postId: params.postId,
        userId: params.userId,
        commentId: params.commentId);
  }
}

class UnlikeCommentUseCase implements UseCase<void, LikeUnlikeParams> {
  final PostRepository repository;

  UnlikeCommentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(LikeUnlikeParams params) async {
    return await repository.unlikeComment(
        userId: params.userId,
        postId: params.postId,
        commentId: params.commentId);
  }
}

class LikeUnlikeParams extends Equatable {
  final String userId;
  final String postId;
  final String commentId;

  const LikeUnlikeParams({
    required this.userId,
    required this.postId,
    required this.commentId,
  });

  @override
  List<Object?> get props => [userId, commentId];
}
