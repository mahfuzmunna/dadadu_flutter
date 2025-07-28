// lib/features/auth/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? fullName; // This might be 'full_name' from DB
  final String? username;
  final String? bio;
  final String? profilePhotoUrl;
  final int? referralsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? rank;
  final String? referralLink;
  final String? moodStatus;
  final String? language;
  final String? discoverMode;
  final bool? isEmailConfirmed;
  final String? latitude;
  final String? longitude;
  final String? location;
  final int? diamonds;
  final List<String> followingIds;
  final List<String> followerIds;
  final List<String> postIds;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.username,
    required this.bio,
    required this.profilePhotoUrl,
    required this.referralsCount,
    required this.createdAt,
    required this.updatedAt,
    required this.rank,
    required this.referralLink,
    required this.moodStatus,
    required this.language,
    required this.discoverMode,
    required this.isEmailConfirmed,
    required this.latitude,
    required this.longitude,
    required this.location,
    this.diamonds,
    this.followingIds = const [],
    this.followerIds = const [],
    this.postIds = const [],
  });

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        username,
        bio,
        profilePhotoUrl,
        referralsCount,
        createdAt,
        updatedAt,
        rank,
        referralLink,
        moodStatus,
        language,
        discoverMode,
        isEmailConfirmed,
        latitude,
        longitude,
        location,
        diamonds,
        followingIds,
        followerIds,
        postIds,
      ];

  UserEntity copyWith({
    String? id,
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
    List<String>? postIds,
  }) {
    return UserEntity(
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
