import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/posts/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../upload/domain/entities/post_entity.dart';

class StreamAllPostsUseCase implements UseCase<Stream<List<PostEntity>>, void> {
  final PostRepository repository;

  StreamAllPostsUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<List<PostEntity>>>> call(void params) async {
    return repository.streamAllPosts();
  }
}
