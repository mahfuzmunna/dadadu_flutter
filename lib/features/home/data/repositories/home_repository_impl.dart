// lib/features/home/data/repositories/home_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for DocumentSnapshot
import 'package:dadadu_app/core/errors/exceptions.dart';
import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:dadadu_app/features/home/domain/repositories/home_repository.dart';
import 'package:dadadu_app/features/upload/data/models/post_model.dart'; // Assuming PostModel exists
import 'package:dadadu_app/features/auth/data/models/user_model.dart';

import '../../../auth/domain/entities/user_entity.dart'; // Assuming UserModel exists

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PostsPaginationResult>> getPosts(int limit, {DocumentSnapshot? startAfterDocument}) async {
    try {
      final snapshot = await remoteDataSource.fetchPostsSnapshot(limit, startAfterDocument: startAfterDocument);
      final posts = snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      final hasMore = posts.length == limit; // If we fetched the limit, assume there might be more

      return Right(PostsPaginationResult(posts: posts, lastDocument: lastDoc, hasMore: hasMore));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserInfo(String uid) async {
    try {
      final user = await remoteDataSource.fetchUserInfo(uid);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}