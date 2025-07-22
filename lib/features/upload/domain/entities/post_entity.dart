// lib/features/upload/domain/entities/post_entity.dart
import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String userId;
  final String videoUrl;
  final String description;
  final String thumbnailUrl;
  final int diamonds; // Changed from likes
  final int comments;
  final int views;
  final DateTime createdAt;
  final String? hashtags; // Or List<String>
  final String? location;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.videoUrl,
    required this.description,
    required this.thumbnailUrl,
    this.diamonds = 0, // Default to 0
    this.comments = 0, // Default to 0
    this.views = 0, // Default to 0
    required this.createdAt,
    this.hashtags,
    this.location,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        videoUrl,
        description,
        thumbnailUrl,
        diamonds,
        comments,
        views,
        createdAt,
        hashtags,
        location,
      ];
}