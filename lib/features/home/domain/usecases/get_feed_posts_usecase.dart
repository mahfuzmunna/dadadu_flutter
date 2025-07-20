import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/home_repository.dart';

class GetFeedPostsUseCase implements UseCase<List<PostEntity>, NoParams> {
  final HomeRepository repository;

  GetFeedPostsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PostEntity>>> call(NoParams params) async {
    return await repository.getFeedPosts();
  }
}