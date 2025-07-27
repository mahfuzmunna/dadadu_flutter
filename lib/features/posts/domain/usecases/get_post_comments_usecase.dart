import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/comments/domain/entities/comment_entity.dart';
import 'package:dadadu_app/features/posts/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';

class GetPostCommentsUseCase implements UseCase<List<CommentEntity>, String> {
  final PostRepository repository;

  GetPostCommentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CommentEntity>>> call(String params) async {
    return await repository.getPostComments(params);
  }
}
