// lib/features/profile/domain/usecases/get_posts_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/entities/post_entity.dart'; // Assuming PostEntity is in profile/domain/entities
import '../repositories/profile_repository.dart';

class GetPostsUseCase implements UseCase<List<PostEntity>, GetPostsParams> {
  final ProfileRepository repository;

  GetPostsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PostEntity>>> call(GetPostsParams params) async {
    return await repository.getUserPosts(params.userId);
  }
}

class GetPostsParams extends Equatable {
  final String userId;

  const GetPostsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
