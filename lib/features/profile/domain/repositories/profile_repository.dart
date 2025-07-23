// lib/features/profile/domain/repositories/profile_repository.dart

import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart'; // Reusing UserEntity for profile data
import '../../../home/domain/entities/post_entity.dart';
import '../usecases/update_user_location_usecase.dart'; // Assuming PostEntity exists

abstract class ProfileRepository {
  Future<Either<Failure, UserEntity>> getUserProfile(String userId);

  Future<Either<Failure, void>> updateUserProfile(UserEntity user);

  Future<Either<Failure, List<PostEntity>>> getUserPosts(String userId);

  Future<Either<Failure, String>> uploadProfileImage(String userId,
      File photoFile); // Returns URL
  Future<Either<Failure, void>> deleteProfileImage(String userId);

  Future<Either<Failure, void>> updateUserLocation(
      UpdateUserLocationParams params);
}