// lib/features/profile/data/datasources/profile_remote_data_source.dart

import '../../../auth/data/models/user_model.dart';
import '../../../upload/data/models/post_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile(String userId);
  Future<void> updateUserProfile(UserModel user);
  Future<List<PostModel>> getUserPosts(String userId);

  Future<String> uploadProfileImage(
      String userId, String imagePath); // Returns URL
  Future<void> deleteProfileImage(String userId);
}

