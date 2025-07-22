// lib/features/home/data/repositories/home_repository_impl.dart

// Removed: import 'package:cloud_firestore/cloud_firestore.dart'; // No longer needed
import 'package:dadadu_app/core/errors/exceptions.dart';
import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:dadadu_app/features/home/domain/repositories/home_repository.dart'; // Contains PostsPaginationResult
import 'package:dartz/dartz.dart';

import '../../../auth/domain/entities/user_entity.dart'; // Assuming UserEntity exists

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PostsPaginationResult>> getPosts(int limit,
      {String? startAfterTimestamp}) async {
    try {
      // remoteDataSource.fetchPosts now returns List<PostModel>
      final posts = await remoteDataSource.fetchPosts(limit,
          startAfterTimestamp: startAfterTimestamp);

      // Determine the last timestamp for the next pagination call
      final String? lastTimestamp =
          posts.isNotEmpty ? posts.last.timestamp : null;

      // Determine if there might be more posts. If the number of fetched posts
      // is exactly equal to the limit, it's likely there are more.
      final bool hasMore = posts.length == limit;

      return Right(PostsPaginationResult(
          posts: posts, lastTimestamp: lastTimestamp, hasMore: hasMore));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      // Catch any unexpected errors not handled by ServerException
      return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserInfo(String uid) async {
    try {
      // remoteDataSource.fetchUserInfo now returns UserModel which is a UserEntity
      final user = await remoteDataSource.fetchUserInfo(uid);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      // Catch any unexpected errors not handled by ServerException
      return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
}