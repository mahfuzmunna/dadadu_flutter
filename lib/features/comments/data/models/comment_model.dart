import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/comments/domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel(
      {required super.userId,
      required super.comment,
      required super.timestamp,
      required super.likes,
      super.author});

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
        userId: map['user_id'] as String,
        comment: map['comment'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        likes: map['likes'] as int,
        author: null);
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
    };
  }

  CommentModel copyWith({
    String? userId,
    String? comment,
    DateTime? timestamp,
    int? likes,
    UserEntity? author,
  }) {
    return CommentModel(
      userId: userId ?? this.userId,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      author: author ?? this.author,
    );
  }
}
