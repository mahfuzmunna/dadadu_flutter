// lib/features/upload/presentation/bloc/upload_post_event.dart

part of 'upload_post_bloc.dart';

@immutable
abstract class UploadPostEvent extends Equatable {
  const UploadPostEvent();

  @override
  List<Object?> get props => [];
}

class UploadVideoAndPost extends UploadPostEvent {
  final File videoFile;
  final String description;
  final String tag;
  final String userId; // Current authenticated user ID
  final String thumbnailUrl; // URL of the thumbnail image

  const UploadVideoAndPost({
    required this.videoFile,
    required this.description,
    required this.tag,
    required this.userId,
    required this.thumbnailUrl,
  });

  @override
  List<Object> get props => [videoFile, description, tag, userId];
}