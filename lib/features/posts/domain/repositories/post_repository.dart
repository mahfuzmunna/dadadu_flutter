import 'dart:io';

import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../data/datasources/post_remote_data_source.dart';

abstract class PostRepository {
  Future<Either<Failure, void>> uploadPost({
    required File videoFile,
    required File thumbnailFile,
    required String caption,
    required String intent,
    required String userId,
    Function(double progress)? onUploadProgress,
  });
// ... other repository methods
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
    required File thumbnailFile,
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
        thumbnailFile: thumbnailFile,
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

// ... implement other repository methods here
}
