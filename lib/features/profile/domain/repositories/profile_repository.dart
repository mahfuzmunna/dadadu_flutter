// lib/features/profile/domain/repositories/profile_repository.dart

import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart'; // Reusing UserEntity for profile data
import '../../../now/domain/entities/post_entity.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../usecases/update_user_location_usecase.dart';
import '../usecases/update_user_mood_usecase.dart'; // Assuming PostEntity exists

abstract class ProfileRepository {
  Either<Failure, Stream<UserEntity>> streamUserProfile(String userId);

  Future<Either<Failure, UserEntity>> getUserProfile(String userId);

  /// Updates the user's profile data, optionally including a new photo.
  Future<Either<Failure, void>> updateUserProfile({
    required UserEntity user,
    File? photoFile,
  });

  Future<Either<Failure, List<PostEntity>>> getUserPosts(String userId);

  Future<Either<Failure, void>> deleteProfileImage(String userId);

  Future<Either<Failure, void>> updateUserLocation(
      UpdateUserLocationParams params);

  Future<Either<Failure, String>> updateProfilePhoto({
    required String userId,
    required File photoFile,
  });

  Future<Either<Failure, void>> updateUserMood(UpdateUserMoodParams params);
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> getUserProfile(String userId) async {
    try {
      final userModel = await remoteDataSource.getUserProfile(userId);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      // If you later add local cache
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(
      {required UserEntity user, File? photoFile}) async {
    try {
      await remoteDataSource.updateUserProfile(
          user: user, photoFile: photoFile);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getUserPosts(String userId) async {
    try {
      final postModels = await remoteDataSource.getUserPosts(userId);
      // Assuming PostModel extends PostEntity or has a toEntity method
      return Right(postModels.map((model) => model as PostEntity).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfileImage(String userId) async {
    try {
      await remoteDataSource.deleteProfileImage(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(
          'An unexpected error occurred during image deletion: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserLocation(
      UpdateUserLocationParams params) async {
    try {
      // Call the data source method and return Right on success
      await remoteDataSource.updateUserLocation(params);
      return const Right(null);
    } on ServerException catch (e) {
      // Convert ServerException to ServerFailure and return Left
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, String>> updateProfilePhoto({
    required String userId,
    required File photoFile,
  }) async {
    try {
      final photoUrl = await remoteDataSource.updateProfilePhoto(
        userId: userId,
        photoFile: photoFile,
      );
      return Right(photoUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserMood(
      UpdateUserMoodParams params) async {
    try {
      await remoteDataSource.updateUserMood(params);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Either<Failure, Stream<UserEntity>> streamUserProfile(String userId) {
    try {
      final userStream = remoteDataSource.streamUserProfile(userId);
      // The UserModel from the data source is compatible with UserEntity
      return Right(userStream);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }
}