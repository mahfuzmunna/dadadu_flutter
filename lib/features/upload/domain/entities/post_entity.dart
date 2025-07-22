// lib/features/upload/domain/entities/post_entity.dart

import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String userId;
  final String videoUrl;
  final String thumbnailUrl; // NEW: Thumbnail URL for the video
  final String description;
  final String tag; // e.g., 'Love', 'Business', 'Entertainment'
  final DateTime timestamp;
  final int likes;
  final int comments;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.videoUrl,
    required this.thumbnailUrl, // NEW: Make it required in constructor
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
        thumbnailUrl, // NEW: Add to props
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
    String? thumbnailUrl, // NEW: Add to copyWith
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
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      // NEW: Assign in copyWith
      description: description ?? this.description,
      tag: tag ?? this.tag,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }
}