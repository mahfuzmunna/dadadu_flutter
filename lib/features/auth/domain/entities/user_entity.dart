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
        isEmailConfirmed
      ];

  UserEntity copyWith(
      {required String id,
      required String email,
      required String fullName,
      required String username,
      required String? bio,
      required String? profilePhotoUrl,
      required int followersCount,
      required int followingCount,
      required int postCount,
      required String createdAt,
      required String updatedAt,
      required String rank,
      required String referralLink,
      required String moodStatus,
      required String language,
      required String discoverMode,
      required bool isEmailConfirmed}) {
    return UserEntity(
        id: id,
        email: email,
        fullName: fullName,
        username: username,
        bio: bio,
        profilePhotoUrl: profilePhotoUrl,
        followersCount: followersCount,
        followingCount: followingCount,
        postCount: postCount,
        createdAt: createdAt,
        updatedAt: updatedAt,
        rank: rank,
        referralLink: referralLink,
        moodStatus: moodStatus,
        language: language,
        discoverMode: discoverMode,
        isEmailConfirmed: isEmailConfirmed);
  }
}
