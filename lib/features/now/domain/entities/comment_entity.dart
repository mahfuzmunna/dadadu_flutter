import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String? id;
  final String? userId;
  final String? postId;
  final String? comment;
  final DateTime? createdAt;
  final int? likes;
  final List<String>? likedBy;
  final UserEntity? author; // Author details will be populated later

  const CommentEntity({
    required this.id,
    required this.userId,
    required this.postId,
    required this.comment,
    required this.createdAt,
    this.likes = 0,
    this.likedBy = const [],
    this.author,
  });

  @override
  List<Object?> get props =>
      [id, userId, postId, comment, createdAt, likes, likedBy, author];
}
