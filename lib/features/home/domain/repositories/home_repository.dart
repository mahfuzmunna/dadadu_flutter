// lib/features/home/domain/repositories/home_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../upload/data/models/post_model.dart';

// NEW or UPDATED: Pagination Result Class
class PostsPaginationResult {
  final List<PostModel> posts;
  final String? lastTimestamp; // Changed from DocumentSnapshot
  final bool hasMore;

  PostsPaginationResult({
    required this.posts,
    this.lastTimestamp,
    required this.hasMore,
  });
}

abstract class HomeRepository {
  Future<Either<Failure, PostsPaginationResult>> getPosts(int limit,
      {String? startAfterTimestamp}); // Changed parameter type
  Future<Either<Failure, UserEntity>> getUserInfo(String uid);
}