import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<PostEntity>>> getFeedPosts();
}