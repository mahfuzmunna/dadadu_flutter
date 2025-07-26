// lib/features/upload/domain/repositories/post_repository.dart
import 'dart:io'; // For the File type (used for video and thumbnail files)

import 'package:dartz/dartz.dart'; // For the Either type (from dartz package)

import '../../../../core/errors/exceptions.dart'; // For ServerException
import '../../../../core/errors/failures.dart'; // For your custom Failure types
import '../../data/datasources/post_remote_data_source.dart';
import '../entities/post_entity.dart'; // For the PostEntity

/// Abstract interface for the Post Repository.
/// This defines the contract that the data layer's repository implementation
/// must adhere to. It acts as a gateway to the data sources.
abstract class PostRepository {
  Future<Either<Failure, PostEntity>> getPostById(String postId);

  Stream<PostEntity> subscribeToPostChanges(String postId); // NEW
  Future<Either<Failure, PostEntity>> createPost({
    required String userId,
    required String videoUrl,
    required String thumbnailUrl,
    required String description,
    required String tag,
    String? location,
    required File videoFile,
    required File thumbnailFile,
  });

  Stream<List<PostEntity>> getPostsStream(); // NEW
  Future<Either<Failure, String>> uploadVideoToStorage({
    required File videoFile,
    required String userId,
  });

  Future<Either<Failure, String>> uploadThumbnailToStorage({
    required File thumbnailFile,
    required String userId,
  });

  Future<Either<Failure, void>> sendDiamond(
      {required String postId, required String userId});
}

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PostEntity>> createPost({
    required String userId,
    required String videoUrl,
    required String thumbnailUrl,
    required String description,
    required String tag,
    String? location,
    required File videoFile,
    required File thumbnailFile, // Expecting thumbnail file
  }) async {
    try {
      // Step 1: Upload video file to external storage (Wasabi/CDN)
      final String videoUrl = await remoteDataSource.uploadVideoToStorage(
        videoFile: videoFile,
        userId: userId,
      );

      // Step 2: Upload thumbnail file to external storage (Wasabi/CDN)
      final String thumbnailUrl =
          await remoteDataSource.uploadThumbnailToStorage(
        thumbnailFile: thumbnailFile,
        userId: userId,
      );

      // Step 3: Create the post entry in the Supabase database,
      // providing both the video and thumbnail CDN URLs.
      final PostEntity post = await remoteDataSource.createPostInDatabase(
          userId: userId,
          videoUrl: videoUrl,
          thumbnailUrl: thumbnailUrl,
          // Pass the obtained thumbnail URL
          description: description,
          tag: tag,
          location: location);

      // If all steps succeed, return the PostEntity wrapped in a Right
      return Right(post);
    } on ServerException catch (e) {
      // Catch custom ServerExceptions thrown by the remote data source
      return Left(ServerFailure(e.message));
    } catch (e) {
      // Catch any other unexpected errors and wrap them in a ServerFailure
      return Left(
          ServerFailure('An unexpected error occurred during post upload: $e'));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(String postId) async {
    try {
      final postModel = await remoteDataSource.getPostById(postId);
      return Right(postModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Stream<PostEntity> subscribeToPostChanges(String postId) {
    // Map PostModel stream to PostEntity stream
    return remoteDataSource.subscribeToPostChanges(postId);
  }

  @override
  Stream<List<PostEntity>> getPostsStream() {
    // Directly return the stream from the data source.
    // The BLoC layer will be responsible for handling stream errors.
    // Since PostModel is a subclass of PostEntity, the stream types are compatible.
    return remoteDataSource.getPostsStream();
  }

  @override
  Future<Either<Failure, String>> uploadThumbnailToStorage(
      {required File thumbnailFile, required String userId}) {
    // TODO: implement uploadThumbnailToStorage
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> uploadVideoToStorage(
      {required File videoFile, required String userId}) {
    // TODO: implement uploadVideoToStorage
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> sendDiamond(
      {required String postId, required String userId}) async {
    try {
      await remoteDataSource.sendDiamond(postId: postId, userId: userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }
}
