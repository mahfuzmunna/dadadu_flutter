import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String userId;
  final String videoUrl;
  final String thumbnailUrl;
  final String caption;
  final List<String>? tag;
  final List<String>? diamondGivers;
  final int? diamondCount;
  final String? commentsId;
  final int? commentCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isDisabled;
  final int? visibilityLevel;
  final int? views;
  final String? soundTitle;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.caption,
    required this.tag,
    required this.diamondGivers,
    required this.diamondCount,
    required this.commentsId,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
    required this.isDisabled,
    required this.visibilityLevel,
    required this.views,
    required this.soundTitle,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        videoUrl,
        thumbnailUrl,
        caption,
        tag,
        diamondGivers,
        diamondCount,
        commentsId,
        commentCount,
        createdAt,
        isDisabled,
        visibilityLevel,
        views,
        soundTitle,
      ];
}