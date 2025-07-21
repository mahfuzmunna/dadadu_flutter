// lib/features/upload/data/repositories/upload_post_repository_impl.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dadadu_app/core/errors/exceptions.dart';
import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/features/upload/data/datasources/upload_post_remote_data_source.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:dadadu_app/features/upload/domain/repositories/upload_post_repository.dart';
import 'package:dadadu_app/features/upload/data/models/post_model.dart'; // Import PostModel

class UploadPostRepositoryImpl implements UploadPostRepository {
  final UploadPostRemoteDataSource remoteDataSource;

  UploadPostRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> uploadVideo(File videoFile, String userId, String postId) async {
    try {
      final String downloadUrl = await remoteDataSource.uploadVideoToStorage(videoFile, userId, postId);
      return Right(downloadUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> createPost(PostEntity post) async {
    try {
      // Convert PostEntity to PostModel for data source
      final PostModel postModel = PostModel(
        id: post.id,
        userId: post.userId,
        videoUrl: post.videoUrl,
        description: post.description,
        tag: post.tag,
        timestamp: post.timestamp,
        likes: post.likes,
        comments: post.comments,
      );
      await remoteDataSource.createPostInFirestore(postModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserUploadedVideos(String userId, String videoUrl) async {
    try {
      await remoteDataSource.updateUserUploadedVideosList(userId, videoUrl);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}