// lib/features/upload/data/repositories/post_repository_impl.dart
import 'dart:io'; // For File

import 'package:dartz/dartz.dart'; // For Either

import '../../../../core/errors/exceptions.dart'; // For ServerException
import '../../../../core/errors/failures.dart'; // For Failure and ServerFailure
import '../../domain/entities/post_entity.dart'; // For PostEntity
import '../../domain/repositories/post_repository.dart'; // For PostRepository abstract class
import '../datasources/post_remote_data_source.dart'; // For PostRemoteDataSource

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
        thumbnailUrl: thumbnailUrl, // Pass the obtained thumbnail URL
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
}
