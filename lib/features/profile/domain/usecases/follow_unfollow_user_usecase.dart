// ... imports
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class FollowUserUseCase implements UseCase<void, FollowUserParams> {
  final ProfileRepository repository;

  FollowUserUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(FollowUserParams params) async {
    return await repository.followUser(
        followerId: params.followerId, followingId: params.followingId);
  }
}

class UnfollowUserUseCase implements UseCase<void, FollowUserParams> {
  final ProfileRepository repository;

  UnfollowUserUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(FollowUserParams params) async {
    return await repository.unfollowUser(
        followerId: params.followerId, followingId: params.followingId);
  }
}

class FollowUserParams extends Equatable {
  final String followerId; // The one doing the following (current user)
  final String followingId; // The one being followed (profile user)
  const FollowUserParams({required this.followerId, required this.followingId});

  @override
  List<Object> get props => [followerId, followingId];
}
