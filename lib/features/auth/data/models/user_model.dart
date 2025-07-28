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
    required super.followersCount,
    required super.followingCount,
    required super.postCount,
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
  });

  // Factory constructor to create UserModel from a Map (Supabase query result)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    final userModel = UserModel(
        id: map['id'],
      email: map['email'],
      fullName: map['full_name'],
      username: map['username'],
        bio: map['bio'] ?? '',
        profilePhotoUrl: map['profile_photo_url'] ?? '',
        followersCount: map['followers_count'],
      followingCount: map['following_count'],
      postCount: map['post_count'],
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
            : []
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
      'followers_count': followersCount,
      'following_count': followingCount,
      'post_count': postCount,
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
    };
  }

  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? username,
    String? bio,
    String? profilePhotoUrl,
    int? followersCount,
    int? followingCount,
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
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postCount: postCount ?? this.postCount,
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
    );
  }
}