import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String? email;
  final String? displayName; // Can still be used as a fallback
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? profilePhotoUrl;
  final String? userModeEmoji; // New: For the emoji status
  final int followersCount; // New
  final int followingCount; // New
  final String? rank; // New
  final List<String> uploadedVideoUrls; // New: Assuming video URLs

  const UserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    this.username,
    this.profilePhotoUrl,
    this.userModeEmoji,
    this.followersCount = 0, // Default to 0
    this.followingCount = 0, // Default to 0
    this.rank,
    this.uploadedVideoUrls = const [], // Default to empty list
  });

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    firstName,
    lastName,
    username,
    profilePhotoUrl,
    userModeEmoji,
    followersCount,
    followingCount,
    rank,
    uploadedVideoUrls,
  ];

  // Helper to create a copy with updated values
  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? username,
    String? profilePhotoUrl,
    String? userModeEmoji,
    int? followersCount,
    int? followingCount,
    String? rank,
    List<String>? uploadedVideoUrls,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      userModeEmoji: userModeEmoji ?? this.userModeEmoji,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      rank: rank ?? this.rank,
      uploadedVideoUrls: uploadedVideoUrls ?? this.uploadedVideoUrls,
    );
  }
}