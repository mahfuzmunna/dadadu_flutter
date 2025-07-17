import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  final String id;
  final String userId;
  final String username;
  final String url;
  final String thumbnailUrl;
  final String caption;
  final bool isDadader;
  int diamonds;
  final DateTime createdAt;
  final String? profilePicture;
  final String? intent;
  final String? language;

  Video({
    required this.id,
    required this.userId,
    required this.username,
    required this.url,
    required this.thumbnailUrl,
    required this.caption,
    required this.isDadader,
    required this.diamonds,
    required this.createdAt,
    this.profilePicture,
    this.intent,
    this.language,
  });

  factory Video.fromJson(Map<String, dynamic> json, String docId) {
    return Video(
      id: docId,
      userId: json['uid'] ?? '',
      username: json['username'] ?? '',
      url: json['videoUrl'] ?? json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      caption: json['caption'] ?? '',
      isDadader: json['isDadader'] ?? false,
      diamonds: json['diamonds'] ?? 0,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      profilePicture: json['profilePicture'] ?? '',
      intent: json['intent'] ?? 'love',
      language: json['language'] ?? 'fr',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': userId,
      'username': username,
      'videoUrl': url,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'isDadader': isDadader,
      'diamonds': diamonds,
      'createdAt': Timestamp.fromDate(createdAt),
      'profilePicture': profilePicture,
      'intent': intent,
      'language': language,
    };
  }

  Video copyWith({
    String? id,
    String? userId,
    String? username,
    String? url,
    String? thumbnailUrl,
    String? caption,
    bool? isDadader,
    int? diamonds,
    DateTime? createdAt,
    String? profilePicture,
    String? intent,
    String? language,
  }) {
    return Video(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      isDadader: isDadader ?? this.isDadader,
      diamonds: diamonds ?? this.diamonds,
      createdAt: createdAt ?? this.createdAt,
      profilePicture: profilePicture ?? this.profilePicture,
      intent: intent ?? this.intent,
      language: language ?? this.language,
    );
  }
}