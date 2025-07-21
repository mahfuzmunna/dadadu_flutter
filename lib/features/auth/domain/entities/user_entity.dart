import 'dart:io';

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String? email;
  final String? displayName; // Can still be used as a fallback
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? bio;
  final String? profilePhotoUrl;
  final String? userModeEmoji; // New: For the emoji status
  final int followersCount; // New
  final int followingCount; // New
  final int? postCount; // New
  final String? rank; // New
  final List<String> uploadedVideoUrls; // New: Assuming video URLs

  final File? profilePhotoFile; // New: For profile image

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
    this.followersCount = 0, // Default to 0
    this.followingCount = 0, // Default to 0
    this.postCount, // New
    this.rank,
    this.uploadedVideoUrls = const [], // Default to empty list
    this.profilePhotoFile, // New: For profile image
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
        profilePhotoFile
      ];

  // Helper to create a copy with updated values
  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? username,
    String? bio,
    String? profilePhotoUrl,
    String? userModeEmoji,
    int? followersCount,
    int? followingCount,
    int? postCount,
    String? rank,
    List<String>? uploadedVideoUrls,
    File? profilePhotoFile,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      userModeEmoji: userModeEmoji ?? this.userModeEmoji,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postCount: postCount ?? this.postCount,
      rank: rank ?? this.rank,
      uploadedVideoUrls: uploadedVideoUrls ?? this.uploadedVideoUrls,
      profilePhotoFile: profilePhotoFile ?? this.profilePhotoFile,
    );
  }
}