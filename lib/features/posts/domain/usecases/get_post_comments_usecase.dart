import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/comments/domain/entities/comment_entity.dart';
import 'package:dadadu_app/features/posts/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// =======================================================================
// Usecase to GET all comments for a post
// =======================================================================
class GetPostCommentsUseCase implements UseCase<List<CommentEntity>, String> {
  final PostRepository repository;

  GetPostCommentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CommentEntity>>> call(String postId) async {
    return await repository.getPostComments(postId);
  }
}

// =======================================================================
// ✅ CORRECTED: Usecase to ADD a new comment
// =======================================================================

/// A dedicated class to pass parameters for adding a comment.
/// This is much safer and cleaner than using a single string or a Map.
class CommentParams extends Equatable {
  final String userId;
  final String postId;
  final String comment;

  const CommentParams({
    required this.userId,
    required this.postId,
    required this.comment,
  });

  @override
  List<Object?> get props => [userId, postId, comment];
}

/// The corrected use case for adding a comment.
///
/// It implements `UseCase<void, CommentParams>`, meaning:
/// - It returns `void` on success because the command itself doesn't need to return data.
/// - It takes `CommentParams` as its input.
class AddCommentUseCase implements UseCase<void, CommentParams> {
  final PostRepository repository;

  AddCommentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CommentParams params) async {
    // Assumes your repository has a method like:
    // Future<Either<Failure, void>> addComment(CommentParams params);
    // Or you can destructure it as before.
    return await repository.addComment(
        userId: params.userId, postId: params.postId, comment: params.comment);
  }
}
