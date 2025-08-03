import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/now/domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.userId,
      required super.postId,
      required super.comment,
      required super.createdAt,
      super.likes,
      super.likedBy,
      super.author});

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String?,
      userId: map['user_id'] as String?,
      postId: map['post_id'] as String?,
      comment: map['comment_body'] as String?,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      likes: map['likes'] ?? 0,
      likedBy:
          map['liked_by'] == null ? [] : List<String>.from(map['liked_by']),
      // The author is often joined in a query and might not be on every map
      author: map['author'] == null ? null : UserEntity.fromMap(map['author']),
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
