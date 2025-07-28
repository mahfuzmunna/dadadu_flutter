import 'dart:io';
import 'dart:typed_data';

import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../comments/data/models/comment_model.dart';
import '../../../comments/domain/entities/comment_entity.dart';
import '../../../upload/domain/entities/post_entity.dart';
import '../../data/datasources/post_remote_data_source.dart';

abstract class PostRepository {
  Future<Either<Failure, void>> uploadPost({
    required File videoFile,
    required Uint8List thumbnailBytes,
    required String caption,
    required String intent,
    required String userId,
    Function(double progress)? onUploadProgress,
  });

  Future<Either<Failure, PostEntity>> getPostById(String postId);

  Either<Failure, Stream<PostEntity>> subscribeToPostChanges(String postId);

  Either<Failure, Stream<List<PostEntity>>> streamAllPosts();

  Either<Failure, Stream<Tuple2<List<PostEntity>, Map<String, UserEntity>>>>
      streamFeed();

  Future<Either<Failure, List<CommentEntity>>> getPostComments(String postId);

  Future<Either<Failure, void>> sendDiamond(
      {required String senderId, required String receiverId});

  Future<Either<Failure, void>> unsendDiamond(
      {required String senderId, required String receiverId});
}

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  // You might also inject a NetworkInfo service to check for internet connection
  // final NetworkInfo networkInfo;

  PostRepositoryImpl({
    required this.remoteDataSource,
    // required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> uploadPost({
    required File videoFile,
    required Uint8List thumbnailBytes,
    required String caption,
    required String intent,
    required String userId,
    Function(double progress)? onUploadProgress,
  }) async {
    // Optional: Check for internet connection first
    // if (!await networkInfo.isConnected) {
    //   return Left(OfflineFailure());
    // }

    try {
      // Call the method on the remote data source to perform the actual upload
      await remoteDataSource.uploadPost(
        videoFile: videoFile,
        thumbnailBytes: thumbnailBytes,
        caption: caption,
        intent: intent,
        userId: userId,
        onUploadProgress: onUploadProgress,
      );

      // If the call completes without throwing an exception, return Right(null) for success.
      return const Right(null);
    } on ServerException catch (e) {
      // If the data source throws a ServerException, convert it to a ServerFailure.
      // This keeps your domain and presentation layers clean from data layer exceptions.
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      // Catch any other unexpected errors
      return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Either<Failure, Stream<List<PostEntity>>> streamAllPosts() {
    try {
      final postStream = remoteDataSource.streamAllPosts();
      return Right(postStream);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Either<Failure, Stream<Tuple2<List<PostEntity>, Map<String, UserEntity>>>>
      streamFeed() {
    try {
      final feedStream = remoteDataSource.streamFeed();
      return Right(feedStream);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getPostComments(
      String postId) async {
    try {
      final commentMaps = await remoteDataSource.getPostComments(postId);
      List<CommentModel> comments =
          commentMaps.map((map) => CommentModel.fromMap(map)).toList();

      // Fetch author details for all comments in one go
      if (comments.isNotEmpty) {
        final userIds = comments.map((c) => c.userId).toSet().toList();
        // Assume you have a method in ProfileRepository to get multiple users
        final authorsResult = await remoteDataSource.getUsersByIds(userIds);

        authorsResult.fold(
          (failure) => null,
          // Could log this error, but proceed without authors
          (authors) {
            final authorMap = {for (var author in authors) author.id: author};
            comments = comments.map((comment) {
              return comment.copyWith(author: authorMap[comment.userId]);
            }).toList();
          },
        );
      }

      return Right(comments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(String postId) async {
    try {
      final post = await remoteDataSource.getPostById(postId);
      return Right(post);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Either<Failure, Stream<PostEntity>> subscribeToPostChanges(String postId) {
    try {
      final postStream = remoteDataSource.subscribeToPostChanges(postId);
      return Right(postStream);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, void>> sendDiamond(
      {required String senderId, required String receiverId}) async {
    try {
      await remoteDataSource.sendDiamond(
          senderId: senderId, receiverId: receiverId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, void>> unsendDiamond(
      {required String senderId, required String receiverId}) async {
    try {
      await remoteDataSource.unsendDiamond(
          senderId: senderId, receiverId: receiverId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }
}
