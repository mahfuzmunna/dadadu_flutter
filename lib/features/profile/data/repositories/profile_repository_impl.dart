// lib/features/profile/data/repositories/profile_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../home/domain/entities/post_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

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
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(UserEntity user) async {
    try {
      // Assuming UserModel can be created from UserEntity for data layer operations
      final userModel = UserModel(
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        username: user.username,
        bio: user.bio,
        profilePhotoUrl: user.profilePhotoUrl,
        followersCount: user.followersCount,
        followingCount: user.followingCount,
        postCount: user.postCount,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        rank: user.rank,
        referralLink: user.referralLink,
        moodStatus: user.moodStatus,
        language: user.language,
        discoverMode: user.discoverMode,
        uploadedVideoUrls: user.uploadedVideoUrls,
        profilePhotoFile: user.profilePhotoFile,
        isEmailConfirmed: user.isEmailConfirmed,
      );
      await remoteDataSource.updateUserProfile(userModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
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
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(
      String userId, String imagePath) async {
    try {
      final imageUrl =
          await remoteDataSource.uploadProfileImage(userId, imagePath);
      return Right(imageUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(
          'An unexpected error occurred during image upload: ${e.toString()}'));
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
}