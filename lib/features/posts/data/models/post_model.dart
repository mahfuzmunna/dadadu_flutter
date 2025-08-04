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
    // Helper to safely parse lists of strings
    List<String>? _parseStringList(dynamic input) {
      if (input == null) return null;
      if (input is List) {
        // Filter to strings only, ignore malformed entries
        return input.whereType<String>().toList();
      }
      return null;
    }

    // Helper to safely parse ints from dynamic
    int? _parseInt(dynamic input) {
      if (input == null) return null;
      if (input is int) return input;
      if (input is String) return int.tryParse(input);
      return null;
    }

    // Helper to safely parse bools from dynamic
    bool? _parseBool(dynamic input) {
      if (input == null) return null;
      if (input is bool) return input;
      if (input is String) {
        if (input.toLowerCase() == 'true') return true;
        if (input.toLowerCase() == 'false') return false;
      }
      return null;
    }

    // Helper to safely parse DateTime from dynamic
    DateTime? _parseDateTime(dynamic input) {
      if (input == null) return null;
      if (input is DateTime) return input;
      if (input is String) return DateTime.tryParse(input);
      return null;
    }

    return PostModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      videoUrl: map['video_url'] as String,
      thumbnailUrl: map['thumbnail_url'] as String,
      caption: map['caption'] as String,
      tag: _parseStringList(map['tag']),
      diamondGivers: _parseStringList(map['diamond_givers']),
      diamondCount: _parseInt(map['diamond_count']),
      commentsId: map['comments_id'] as String?,
      commentCount: _parseInt(map['comment_count']),
      createdAt: _parseDateTime(map['created_at']),
      updatedAt: _parseDateTime(map['updated_at']),
      isDisabled: _parseBool(map['is_disabled']),
      visibilityLevel: _parseInt(map['visibility_level']),
      views: _parseInt(map['views']),
      soundTitle: map['sound_title'] as String?,
    );
  }
}
