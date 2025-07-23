import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;

  // userId is still useful for quick reference
  final String userId;
  final String videoUrl;
  final String thumbnailUrl;
  final String description;
  final String tag;
  final int diamonds;
  final int comments;
  final String? createdAt;
  final bool isDisabled;
  final int visibilityLevel;
  final int views;
  final String? location;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.description,
    required this.tag,
    required this.diamonds,
    required this.comments,
    required this.createdAt,
    required this.isDisabled,
    required this.visibilityLevel,
    required this.views,
    required this.location,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        videoUrl,
        thumbnailUrl,
        description,
        tag,
        diamonds,
        comments,
        createdAt,
        isDisabled,
        visibilityLevel,
        views,
        location,
      ];
}