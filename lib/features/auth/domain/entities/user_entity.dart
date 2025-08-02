// lib/features/auth/domain/entities/user_entity.dart
import 'package:dadadu_app/features/auth/domain/entities/feed_tags_entity.dart';
import 'package:dadadu_app/features/auth/domain/entities/location_entity.dart';
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? username;
  final String? email;
  final String? phone;
  final String? gender;
  final List<String>? interestedIn;
  final String? lookingFor;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? diamonds;
  final List<String>? postIds;
  final List<String>? followerIds; // Renamed for clarity
  final List<String>? followingIds; // Renamed for clarity
  final List<String>? commentIds;
  final List<String>? chatroomIds;
  final List<String>? referredIds;
  final String? referredBy;
  final DateTime? lastLoginAt;

  // ✅ CHANGED: Switched from a List to a Map for key-value pairs.
  final FeedTagsEntity? feedTags;
  final LocationEntity? location;
  final bool? activeStatus;
  final String? fullName;
  final String? profilePhotoUrl;
  final String? bio;
  final int?
      rank; // Moving to int (1 => Leaf, 2 => Threeleaf, 3=> Fiveleaf, 4=> Dadalord)
  final int?
      moodStatus; //Moving to int (1 =>  Happy, 2 => Sad, 3=> Excited, 4=> Calm, 5=> Angry)
  final int? referralsCount;

  const UserEntity({
    required this.id,
    this.username,
    this.email,
    this.phone,
    this.gender,
    required this.interestedIn,
    this.lookingFor,
    required this.createdAt,
    this.updatedAt,
    this.diamonds = 0,
    required this.postIds,
    required this.followerIds,
    required this.followingIds,
    required this.commentIds,
    required this.chatroomIds,
    required this.referredIds,
    this.referredBy,
    this.lastLoginAt,
    required this.feedTags,
    this.location,
    this.activeStatus,
    this.fullName,
    this.profilePhotoUrl,
    this.bio,
    this.rank,
    this.moodStatus,
    this.referralsCount,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        phone,
        gender,
        interestedIn,
        lookingFor,
        createdAt,
        updatedAt,
        diamonds,
        postIds,
        followerIds,
        followingIds,
        commentIds,
        chatroomIds,
        referredIds,
        referredBy,
        lastLoginAt,
        feedTags, // ✅ Updated
        location,
        activeStatus,
        fullName,
        profilePhotoUrl,
        bio,
        rank,
        moodStatus,
        referralsCount,
      ];

  /// Creates a copy of this user but with the given fields replaced with the new values.
  UserEntity copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? gender,
    List<String>? interestedIn,
    String? lookingFor,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? diamonds,
    List<String>? postIds,
    List<String>? followerIds,
    List<String>? followingIds,
    List<String>? commentIds,
    List<String>? chatroomIds,
    List<String>? referredIds,
    String? referredBy,
    DateTime? lastLoginAt,
    // ✅ CHANGED: Updated type
    FeedTagsEntity? feedTags,
    LocationEntity? location,
    bool? activeStatus,
    String? fullName,
    String? profilePhotoUrl,
    String? bio,
    int? rank,
    int? moodStatus,
    int? referralsCount,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      interestedIn: interestedIn ?? this.interestedIn,
      lookingFor: lookingFor ?? this.lookingFor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      diamonds: diamonds ?? this.diamonds,
      postIds: postIds ?? this.postIds,
      followerIds: followerIds ?? this.followerIds,
      followingIds: followingIds ?? this.followingIds,
      commentIds: commentIds ?? this.commentIds,
      chatroomIds: chatroomIds ?? this.chatroomIds,
      referredIds: referredIds ?? this.referredIds,
      referredBy: referredBy ?? this.referredBy,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      feedTags: feedTags ?? this.feedTags,
      // ✅ Updated
      location: location ?? this.location,
      activeStatus: activeStatus ?? this.activeStatus,
      fullName: fullName ?? this.fullName,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      bio: bio ?? this.bio,
      rank: rank ?? this.rank,
      moodStatus: moodStatus ?? this.moodStatus,
      referralsCount: referralsCount ?? this.referralsCount,
    );
  }
}
