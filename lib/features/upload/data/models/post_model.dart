// lib/features/upload/data/models/post_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    required super.videoUrl,
    super.description,
    super.tag,
    required super.timestamp,
    super.likes,
    super.comments,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] as String,
      videoUrl: data['videoUrl'] as String,
      description: data['description'] as String? ?? '',
      tag: data['tag'] as String? ?? 'Entertainment',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      likes: data['likes'] as int? ?? 0,
      comments: data['comments'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'videoUrl': videoUrl,
      'description': description,
      'tag': tag,
      'timestamp': Timestamp.fromDate(timestamp), // Convert DateTime to Firestore Timestamp
      'likes': likes,
      'comments': comments,
    };
  }
}