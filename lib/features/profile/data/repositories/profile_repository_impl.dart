import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../datasources/profile_remote_data_source.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../auth/data/models/user_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> getUserProfile(String uid) async {
    try {
      final userModel = await remoteDataSource.getUserProfile(uid);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(UserEntity user) async {
    try {
      // Assuming UserEntity can be cast to UserModel or converted
      // In a real app, you might have a mapper from Entity to Model
      if (user is UserModel) {
        await remoteDataSource.updateProfile(user);
      } else {
        // Handle conversion if UserEntity is not directly UserModel
        final userModel = UserModel(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          firstName: user.firstName,
          lastName: user.lastName,
          username: user.username,
          profilePhotoUrl: user.profilePhotoUrl,
          userModeEmoji: user.userModeEmoji,
          followersCount: user.followersCount,
          followingCount: user.followingCount,
          rank: user.rank,
          uploadedVideoUrls: user.uploadedVideoUrls,
        );
        await remoteDataSource.updateProfile(userModel);
      }
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}