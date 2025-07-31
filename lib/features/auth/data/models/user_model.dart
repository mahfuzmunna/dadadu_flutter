// lib/features/auth/data/models/user_model.dart

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.username,
    required super.bio,
    required super.profilePhotoUrl,
    required super.referralsCount,
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
    required super.location,
    super.diamonds,
    super.followingIds = const [],
    super.followerIds = const [],
    super.postIds = const [],
  });

  // Factory constructor to create UserModel from a Map (Supabase query result)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    final userModel = UserModel(
      id: map['id'],
      email: map['email'],
      fullName: map['full_name'],
      username: map['username'],
      bio: map['bio'] ?? '',
      profilePhotoUrl: map['profile_photo_url'],
      referralsCount: map['referrals_count'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
      rank: map['rank'],
      referralLink: map['referral_link'] ?? '',
      moodStatus: map['mood_status'] ?? '',
      language: map['language'],
      discoverMode: map['discover_mode'],
      isEmailConfirmed: map['is_confirmed_email'],
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      location: map['location'] ?? '',
      diamonds: map['diamonds'],
      followingIds: map['following_ids'] != null
          ? List<String>.from(map['following_ids'].map((id) => id.toString()))
          : [],
      followerIds: map['follower_ids'] != null
          ? List<String>.from(map['follower_ids'].map((id) => id.toString()))
          : [],
      postIds: map['post_ids'] != null
          ? List<String>.from(map['post_ids'].map((id) => id.toString()))
          : [],
      // Always null when loaded from DB
    );
    return userModel;
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
      'referrals_count': referralsCount,
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
      'diamonds': diamonds,
      'following_ids': followingIds,
      'follower_ids': followerIds,
      'post_ids': postIds,
    };
  }

  @override
  UserEntity copyWith(
      {String? id,
      String? email,
      String? fullName,
      String? username,
      String? bio,
      String? profilePhotoUrl,
      int? postCount,
      int? referralsCount,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? rank,
      String? referralLink,
      String? moodStatus,
      String? language,
      String? discoverMode,
      bool? isEmailConfirmed,
      String? latitude,
      String? longitude,
      String? location,
      int? diamonds,
      List<String>? followingIds,
      List<String>? followerIds,
      List<String>? postIds}) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      referralsCount: referralsCount ?? this.referralsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rank: rank ?? this.rank,
      referralLink: referralLink ?? this.referralLink,
      moodStatus: moodStatus ?? this.moodStatus,
      language: language ?? this.language,
      discoverMode: discoverMode ?? this.discoverMode,
      isEmailConfirmed: isEmailConfirmed ?? this.isEmailConfirmed,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      location: location ?? this.location,
      diamonds: diamonds ?? this.diamonds,
      followingIds: followingIds ?? this.followingIds,
      followerIds: followerIds ?? this.followerIds,
      postIds: postIds ?? this.postIds,
    );
  }
}
