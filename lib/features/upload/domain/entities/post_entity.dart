// lib/features/upload/domain/entities/post_entity.dart

import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String userId;
  final String videoUrl;
  final String description;
  final String tag; // e.g., 'Love', 'Business', 'Entertainment'
  final DateTime timestamp;
  final int likes;
  final int comments;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.videoUrl,
    this.description = '',
    this.tag = 'Entertainment', // Default tag
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    videoUrl,
    description,
    tag,
    timestamp,
    likes,
    comments,
  ];

  PostEntity copyWith({
    String? id,
    String? userId,
    String? videoUrl,
    String? description,
    String? tag,
    DateTime? timestamp,
    int? likes,
    int? comments,
  }) {
    return PostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      videoUrl: videoUrl ?? this.videoUrl,
      description: description ?? this.description,
      tag: tag ?? this.tag,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }
}