import '../../domain/entities/user_entity.dart';
import 'feed_tags_model.dart';
import 'location_model.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.username,
    super.email,
    super.phone,
    super.gender,
    super.interestedIn,
    super.lookingFor,
    super.createdAt,
    super.updatedAt,
    super.diamonds,
    super.postIds,
    super.followerIds,
    super.followingIds,
    super.commentIds,
    super.chatroomIds,
    super.referredIds,
    super.referredBy,
    super.lastLoginAt,
    super.feedTags, // ✅ Updated
    super.location,
    super.activeStatus,
    super.fullName,
    super.profilePhotoUrl,
    super.bio,
    super.rank,
    super.moodStatus,
    super.referralsCount,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      username: map['username'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      gender: map['gender'] as String?,
      interestedIn: List<String>.from(map['interested_in'] ?? []),
      lookingFor: map['looking_for'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.parse(map['updated_at'] as String),
      diamonds: map['diamonds'] as int? ?? 0,
      postIds: List<String>.from(map['video_post_ids'] ?? []),
      followerIds: List<String>.from(map['follower_ids'] ?? []),
      followingIds: List<String>.from(map['following_ids'] ?? []),
      commentIds: List<String>.from(map['comments_ids'] ?? []),
      chatroomIds: List<String>.from(map['chatroom_ids'] ?? []),
      referredIds: List<String>.from(map['referred_ids'] ?? []),
      referredBy: map['referred_by'] as String?,
      lastLoginAt: map['last_login_at'] == null
          ? null
          : DateTime.parse(map['last_login_at'] as String),
      // ✅ CHANGED: Safely parse the map from the database
      feedTags: FeedTagsModel.fromMap(map['feed_tags'] as List<dynamic>?),
      location: LocationModel.fromMap(map['location'] as Map<String, dynamic>?),
      activeStatus: map['active_status'] as bool?,
      fullName: map['full_name'] as String?,
      profilePhotoUrl: map['profile_photo_url'] as String?,
      bio: map['bio'] as String?,
      rank: map['rank'] as int?,
      moodStatus: map['mood_status'] as int?,
      referralsCount: map['referrals_count'] as int?,
    );
  }
}