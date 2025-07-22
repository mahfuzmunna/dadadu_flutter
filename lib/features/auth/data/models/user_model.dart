// lib/features/auth/data/models/user_model.dart

// No more Firebase imports
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.email,
    super.displayName,
    super.firstName,
    super.lastName,
    super.username,
    super.bio,
    super.profilePhotoUrl,
    super.userModeEmoji,
    super.followersCount,
    super.followingCount = 0,
    super.postCount,
    super.rank,
    super.uploadedVideoUrls,
    super.profilePhotoFile, // Keep if used for temporary local file selection
  });

  // Removed factory UserModel.fromFirebaseUser, as it's Firebase-specific

  // Factory constructor to create UserModel from a Map (Supabase query result)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      // Assuming 'id' is the primary key column for users in your Supabase 'users' table
      uid: map['id'] as String,
      email: map['email'] as String?,
      displayName: map['display_name'] as String?,
      // Assuming 'display_name' column
      firstName: map['first_name'] as String?,
      // Assuming 'first_name' column
      lastName: map['last_name'] as String?,
      // Assuming 'last_name' column
      username: map['username'] as String?,
      bio: map['bio'] as String?,
      profilePhotoUrl: map['profile_photo_url'] as String?,
      // Assuming 'profile_photo_url' column
      userModeEmoji: map['user_mode_emoji'] as String?,
      // Assuming 'user_mode_emoji' column
      followersCount: map['followers_count'] as int? ?? 0,
      // Assuming 'followers_count' column
      followingCount: map['following_count'] as int? ?? 0,
      // Assuming 'following_count' column
      postCount: map['post_count'] as int?,
      // Assuming 'post_count' column
      rank: map['rank'] as String?,
      uploadedVideoUrls: (map['uploaded_video_urls']
                  as List<dynamic>?) // Assuming 'uploaded_video_urls' column
              ?.map((e) => e as String)
          .toList() ??
          const [],
      // profilePhotoFile is not retrieved from DB, it's a temporary local file.
      profilePhotoFile: null, // Always null when loaded from DB
    );
  }

  // To Map for saving to Supabase (using snake_case for Supabase column names)
  Map<String, dynamic> toMap() {
    return {
      // 'id' (uid) should not be sent in update/insert if it's an auto-generated primary key
      // It's used in .eq() for updates.
      'email': email,
      'display_name': displayName,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'bio': bio,
      'profile_photo_url': profilePhotoUrl,
      'user_mode_emoji': userModeEmoji,
      'followers_count': followersCount,
      'following_count': followingCount,
      'post_count': postCount,
      'rank': rank,
      'uploaded_video_urls': uploadedVideoUrls,
      // 'created_at' and 'updated_at' often managed by Supabase defaults/triggers,
      // but 'updated_at' is explicitly set in ProfileRemoteDataSourceImpl for updates.
    };
  }

// Optional: create a copyWith method for easier state updates
}