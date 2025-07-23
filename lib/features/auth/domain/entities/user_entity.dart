// lib/features/auth/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? fullName; // This might be 'full_name' from DB
  final String? username;
  final String? bio;
  final String? profilePhotoUrl;
  final int followersCount;
  final int followingCount;
  final int? postCount;
  final String createdAt;
  final String updatedAt;
  final String rank;
  final String referralLink;
  final String? moodStatus;
  final String language;
  final String discoverMode;
  final bool isEmailConfirmed;
  final double latitude;
  final double longitude;
  final String location;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.username,
    required this.bio,
    required this.profilePhotoUrl,
    required this.followersCount,
    required this.followingCount,
    required this.postCount,
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
  });

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        username,
        bio,
        profilePhotoUrl,
        followersCount,
        followingCount,
        postCount,
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
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? username,
    String? bio,
    String? profilePhotoUrl,
    int? followersCount,
    int? followingCount,
    int? postCount,
    String? createdAt,
    String? updatedAt,
    String? rank,
    String? referralLink,
    String? moodStatus,
    String? language,
    String? discoverMode,
    bool? isEmailConfirmed,
    double? latitude,
    double? longitude,
    String? location,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postCount: postCount ?? this.postCount,
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
    );
  }
}
