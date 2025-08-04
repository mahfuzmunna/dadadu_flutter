import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/now/domain/entities/comment_entity.dart';

List<String> _toStringList(dynamic maybeList) {
  if (maybeList is Iterable) {
    return maybeList.whereType<String>().toList();
  }
  return [];
}

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.userId,
    required super.postId,
    required super.comment,
    required super.createdAt,
    super.likes,
    super.likedBy,
    super.author,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    // Required string fields
    final rawId = map['id'];
    final rawUserId = map['user_id'];
    final rawPostId = map['post_id'];
    final rawComment = map['comment_body'];

    if (rawId is! String) {
      throw ArgumentError.value(map['id'], 'id', 'Expected a non-null String');
    }
    if (rawUserId is! String) {
      throw ArgumentError.value(
          map['user_id'], 'user_id', 'Expected a non-null String');
    }
    if (rawPostId is! String) {
      throw ArgumentError.value(
          map['post_id'], 'post_id', 'Expected a non-null String');
    }
    if (rawComment is! String) {
      throw ArgumentError.value(
          map['comment_body'], 'comment_body', 'Expected a non-null String');
    }

    // createdAt parsing
    DateTime? createdAt;
    final rawCreatedAt = map['created_at'];
    if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt);
    } else if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    } // else leave null

    // likes normalization (int or parseable string)
    int likes = 0;
    final rawLikes = map['likes'];
    if (rawLikes is int) {
      likes = rawLikes;
    } else if (rawLikes != null) {
      likes = int.tryParse(rawLikes.toString()) ?? 0;
    }

    // likedBy list safely
    final likedBy = _toStringList(map['liked_by']);

    // author parsing if present and well-shaped
    UserEntity? author;
    final rawAuthor = map['author'];
    if (rawAuthor is Map) {
      try {
        author = UserEntity.fromMap(
            Map<String, dynamic>.from(rawAuthor as Map<dynamic, dynamic>));
      } catch (_) {
        // swallow; leave author null if malformed
      }
    }

    return CommentModel(
      id: rawId,
      userId: rawUserId,
      postId: rawPostId,
      comment: rawComment,
      createdAt: createdAt,
      likes: likes,
      likedBy: likedBy,
      author: author,
    );
  }

  CommentModel copyWith({
    String? id,
    String? userId,
    String? postId,
    List<String>? likedBy,
    String? comment,
    DateTime? timestamp,
    int? likes,
    UserEntity? author,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      comment: comment ?? this.comment,
      createdAt: timestamp ?? this.createdAt,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      author: author ?? this.author,
    );
  }
}
