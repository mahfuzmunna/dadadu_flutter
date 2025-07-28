import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/posts/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../upload/domain/entities/post_entity.dart';

class StreamSinglePostUseCase implements UseCase<Stream<PostEntity>, String> {
  final PostRepository repository;

  StreamSinglePostUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<PostEntity>>> call(String params) async {
    return repository.subscribeToPostChanges(params);
  }
}
