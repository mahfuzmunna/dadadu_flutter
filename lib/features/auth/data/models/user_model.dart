// lib/features/auth/data/models/user_model.dart

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

  // Factory constructor to create UserModel from a Map (Supabase query result)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['id'] as String,
      email: map['email'] as String?,
      // Map 'full_name' from Supabase to 'displayName' in UserEntity
      displayName: map['full_name'] as String?,
      // firstName and lastName are no longer directly mapped from DB if you only have 'full_name'
      firstName: null,
      // Or derive from full_name if needed, but for simplicity set null
      lastName: null,
      // Or derive from full_name if needed
      username: map['username'] as String?,
      bio: map['bio'] as String?,
      profilePhotoUrl: map['profile_photo_url'] as String?,
      userModeEmoji: map['user_mode_emoji'] as String?,
      followersCount: map['followers_count'] as int? ?? 0,
      followingCount: map['following_count'] as int? ?? 0,
      postCount: map['post_count'] as int?,
      rank: map['rank'] as String?,
      uploadedVideoUrls: (map['uploaded_video_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      profilePhotoFile: null, // Always null when loaded from DB
    );
  }

  // To Map for saving to Supabase (using snake_case for Supabase column names)
  Map<String, dynamic> toMap() {
    return {
      // 'id' (uid) should not be sent in update/insert if it's an auto-generated primary key
      // It's used in .eq() for updates.
      'email': email,
      'full_name': displayName,
      // Map displayName (from UserEntity) to full_name (Supabase column)
      'username': username,
      'bio': bio,
      'profile_photo_url': profilePhotoUrl,
      'user_mode_emoji': userModeEmoji,
      'followers_count': followersCount,
      'following_count': followingCount,
      'post_count': postCount,
      'rank': rank,
      'uploaded_video_urls': uploadedVideoUrls,
    };
  }

// Optional: create a copyWith method for easier state updates
}