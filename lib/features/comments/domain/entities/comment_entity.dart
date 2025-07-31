import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String userId;
  final String comment;
  final DateTime timestamp;
  final int likes;
  final List<dynamic> likedBy;
  final UserEntity? author; // Author details will be populated later

  const CommentEntity({
    required this.id,
    required this.userId,
    required this.comment,
    required this.timestamp,
    required this.likes,
    required this.likedBy,
    this.author,
  });

  @override
  List<Object?> get props => [id, userId, comment, timestamp, likedBy, author, likes];
}
