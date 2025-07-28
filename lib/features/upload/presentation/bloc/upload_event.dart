// lib/features/upload/presentation/bloc/post_event.dart
part of 'upload_bloc.dart'; // This line links it to the bloc file

@immutable
abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request the upload of a new video post.
class UploadPostRequested extends UploadEvent {
  final File videoFile;
  final File thumbnailFile; // NEW: Thumbnail file for the video
  final String description; // Description of the post

  const UploadPostRequested({
    required this.videoFile,
    required this.thumbnailFile,
    required this.description,
  });

  @override
  List<Object?> get props => [videoFile, thumbnailFile, description];
}
