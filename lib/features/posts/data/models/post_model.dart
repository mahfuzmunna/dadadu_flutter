import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    super.id,
    super.userId,
    super.videoUrl,
    super.thumbnailUrl,
    super.caption,
    super.tag,
    super.diamondGivers,
    super.diamondCount,
    super.commentsId,
    super.commentCount,
    super.createdAt,
    super.updatedAt,
    super.isDisabled,
    super.visibilityLevel,
    super.views,
    super.soundTitle,
  });

  /// Creates a PostModel from a Supabase map.
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      videoUrl: map['video_url'] as String,
      thumbnailUrl: map['thumbnail_url'] as String,
      caption: map['caption'] as String,
      // Safely handle lists that might be null
      tag: map['tag'] == null ? null : List<String>.from(map['tag']),
      diamondGivers: map['diamond_givers'] == null
          ? null
          : List<String>.from(map['diamond_givers']),
      diamondCount: map['diamond_count'] as int?,
      commentsId: map['comments_id'] as String?,
      commentCount: map['comment_count'] as int?,
      // Safely handle timestamps that might be null
      createdAt: map['created_at'] == null
          ? null
          : DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.parse(map['updated_at'] as String),
      isDisabled: map['is_disabled'] as bool?,
      visibilityLevel: map['visibility_level'] as int?,
      views: map['views'] as int?,
      soundTitle: map['sound_title'] as String?,
    );
  }
}
