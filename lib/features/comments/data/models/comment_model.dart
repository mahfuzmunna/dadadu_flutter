import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/comments/domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.userId,
      required super.comment,
      required super.timestamp,
      required super.likes,
      required super.likedBy,
      super.author});

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        comment: map['comment_text'] as String,
        timestamp: map['created_at'] != null
            ? DateTime.parse(map['created_at'])
            : DateTime.now(),
        likes: map['likes'] ?? 0,
        likedBy: map['liked_by'] ?? [],
        author: null);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      userId: json['user_id'],
      comment: json['comment_text'],
      timestamp: DateTime.parse(json['created_at']),
      likes: json['likes'],
      likedBy: List<String>.from(json['liked_by']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'comment_text': comment,
      'created_at': timestamp.toIso8601String(),
      'likes': likes,
      'liked_by': likedBy,
    };
  }

  CommentModel copyWith({
    String? id,
    String? userId,
    String? comment,
    DateTime? timestamp,
    int? likes,
    UserEntity? author,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      likedBy: likedBy,
      author: author ?? this.author,
    );
  }
}
