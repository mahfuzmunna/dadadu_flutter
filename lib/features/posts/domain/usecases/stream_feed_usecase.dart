import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/posts/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../upload/domain/entities/post_entity.dart';

class StreamFeedUseCase
    implements
        UseCase<Stream<Tuple2<List<PostEntity>, Map<String, UserEntity>>>,
            void> {
  final PostRepository repository;

  StreamFeedUseCase(this.repository);

  @override
  Future<
      Either<Failure,
          Stream<Tuple2<List<PostEntity>, Map<String, UserEntity>>>>> call(
      void params) async {
    return repository.streamFeed();
  }
}
