// lib/features/profile/data/datasources/profile_remote_data_source.dart

import 'dart:io';

import '../../../auth/data/models/user_model.dart';
import '../../../upload/data/models/post_model.dart';
import '../../domain/usecases/update_user_location_usecase.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile(String userId);
  Future<void> updateUserProfile(UserModel user);
  Future<List<PostModel>> getUserPosts(String userId);

  Future<void> deleteProfileImage(String userId);

  Future<void> updateUserLocation(UpdateUserLocationParams user);

  Future<String> updateProfilePhoto({
    required String userId,
    required File photoFile,
  });
}

