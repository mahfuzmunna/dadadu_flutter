import '../../domain/entities/user_entity.dart';
import 'location_model.dart';

List<String> _toStringList(dynamic maybeList) {
  if (maybeList is Iterable) {
    // Keeps only string elements, avoids runtime cast exceptions.
    return maybeList.whereType<String>().toList();
  }
  return [];
}

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
    super.feedTags,
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
      interestedIn: _toStringList(map['interested_in']),
      lookingFor: map['looking_for'] as String?,

      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'] as String? ?? ''),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.tryParse(map['updated_at'] as String? ?? ''),

      diamonds: map['diamonds'] is int
          ? map['diamonds'] as int
          : int.tryParse((map['diamonds'] ?? '0').toString()) ?? 0,

      postIds: _toStringList(map['video_post_ids']),
      followerIds: _toStringList(map['follower_ids']),
      followingIds: _toStringList(map['following_ids']),
      commentIds: _toStringList(map['comments_ids']),
      // verify key name: comments_ids vs comment_ids
      chatroomIds: _toStringList(map['chatroom_ids']),
      referredIds: _toStringList(map['referred_ids']),
      referredBy: map['referred_by'] as String?,
      lastLoginAt: map['last_login_at'] == null
          ? null
          : DateTime.tryParse(map['last_login_at'] as String? ?? ''),

      // feedTags: (map['feed_tags'] is Map)
      //     ? FeedTagsModel.fromMap(
      //     Map<String, dynamic>.from(map['feed_tags'] as Map))
      //     : null,

      location: (map['location'] is Map)
          ? LocationModel.fromMap(
          Map<String, dynamic>.from(map['location'] as Map))
          : null,

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
