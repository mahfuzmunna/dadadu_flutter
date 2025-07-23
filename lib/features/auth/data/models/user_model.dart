// lib/features/auth/data/models/user_model.dart

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.username,
    required super.bio,
    required super.profilePhotoUrl,
    required super.followersCount,
    required super.followingCount,
    required super.postCount,
    required super.createdAt,
    required super.updatedAt,
    required super.rank,
    required super.referralLink,
    required super.moodStatus,
    required super.language,
    required super.discoverMode,
    required super.isEmailConfirmed,
    required super.latitude,
    required super.longitude,
    required super.location, // Keep if used for temporary local file selection
  });

  // Factory constructor to create UserModel from a Map (Supabase query result)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      fullName: map['full_name'],
      username: map['username'],
      bio: map['bio'],
      profilePhotoUrl: map['profile_photo_url'],
      followersCount: map['followers_count'],
      followingCount: map['following_count'],
      postCount: map['post_count'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      rank: map['rank'],
      referralLink: map['referral_link'],
      moodStatus: map['mood_status'],
      language: map['language'],
      discoverMode: map['discover_mode'],
      isEmailConfirmed: false,
      latitude: 0.0,
      longitude: 0.0,
      location: '',
      // Always null when loaded from DB
    );
  }

  // To Map for saving to Supabase (using snake_case for Supabase column names)
  Map<String, dynamic> toMap() {
    return {
      // 'id' (uid) should not be sent in update/insert if it's an auto-generated primary key
      // It's used in .eq() for updates.
      'email': email,
      'full_name': fullName,
      'username': username,
      'bio': bio,
      'profile_photo_url': profilePhotoUrl,
      'followers_count': followersCount,
      'following_count': followingCount,
      'post_count': postCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'rank': rank,
      'referral_link': referralLink,
      'mood_status': moodStatus,
      'language': language,
      'discover_mode': discoverMode,
      'is_email_confirmed': isEmailConfirmed,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
    };
  }

// Optional: create a copyWith method for easier state updates
}