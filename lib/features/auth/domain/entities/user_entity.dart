// lib/features/auth/domain/entities/user_entity.dart
import 'dart:io';

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String? email;
  final String? displayName; // This might be 'full_name' from DB
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? bio;
  final String? profilePhotoUrl;
  final String? userModeEmoji;
  final int followersCount;
  final int followingCount;
  final int? postCount;
  final String? rank;
  final List<String> uploadedVideoUrls;
  final File?
      profilePhotoFile; // Used for local selection, not persisted directly as URL
  final bool isEmailConfirmed;

  const UserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    this.username,
    this.bio,
    this.profilePhotoUrl,
    this.userModeEmoji,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postCount,
    this.rank,
    this.uploadedVideoUrls = const [],
    this.profilePhotoFile,
    this.isEmailConfirmed = false,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        firstName,
        lastName,
        username,
        bio,
        profilePhotoUrl,
        userModeEmoji,
        followersCount,
        followingCount,
        postCount,
        rank,
        uploadedVideoUrls,
        profilePhotoFile,
        isEmailConfirmed,
      ];

  copyWith(
      {required String username,
      required String firstName,
      required String lastName,
      required String bio,
      File? profilePhotoFile}) {}
}