// lib/features/upload/data/models/post_model.dart

// No more Firebase imports
// import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    required super.videoUrl,
    required super.thumbnailUrl,
    super.description,
    super.tag,
    required super.timestamp,
    super.likes,
    super.comments,
  });

  // Factory constructor to create PostModel from a Map (Supabase query result)
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      // Assuming 'id' is the primary key column for posts in your Supabase 'posts' table
      id: map['id'] as String,
      // Assuming Supabase column names are snake_case, e.g., 'user_id'
      userId: map['user_id'] as String,
      videoUrl: map['video_url'] as String,
      thumbnailUrl: map['thumbnail_url'] as String,
      description: map['description'] as String,
      // Can be null
      tag: map['tag'] as String? ?? 'Entertainment',
      // Default if null
      // Supabase typically returns timestamps as ISO 8601 strings
      timestamp: map['timestamp'] as String,
      likes: map['likes'] as int? ?? 0,
      // Default to 0 if null
      comments: map['comments'] as int? ?? 0, // Default to 0 if null
    );
  }

  // To Map for saving to Supabase (using snake_case for Supabase column names)
  Map<String, dynamic> toMap() {
    return {
      // 'id' should generally not be included in `insert` operations if it's
      // an auto-incrementing primary key in Supabase. It's typically used
      // in the `.eq('id', postId)` clause for `update` operations.
      'user_id': userId,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'description': description,
      'tag': tag,
      'timestamp': timestamp,
      // Send as ISO 8601 string
      'likes': likes,
      'comments': comments,
      // 'created_at' and 'updated_at' often managed by Supabase defaults/triggers.
      // If you manually manage 'timestamp', ensure your DB column type matches.
    };
  }

  // Optional: Add a copyWith method for immutability and easier updates
  PostModel copyWith({
    String? id,
    String? userId,
    String? videoUrl,
    String? thumbnailUrl,
    String? description,
    String? tag,
    String? timestamp,
    int? likes,
    int? comments,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
      tag: tag ?? this.tag,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }
}