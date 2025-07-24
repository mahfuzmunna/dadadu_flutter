// lib/features/posts/presentation/bloc/upload_event.dart
part of 'upload_bloc.dart';

abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the user selects a video from the gallery or camera.
class UploadVideoSelected extends UploadEvent {
  final File videoFile;

  const UploadVideoSelected(this.videoFile);

  @override
  List<Object> get props => [videoFile];
}

/// Dispatched as the user types in the caption field.
class UploadCaptionChanged extends UploadEvent {
  final String caption;

  const UploadCaptionChanged(this.caption);

  @override
  List<Object> get props => [caption];
}

/// Dispatched when the user selects a new video intent (e.g., Love, Business).
class UploadIntentChanged extends UploadEvent {
  final String intent;

  const UploadIntentChanged(this.intent);

  @override
  List<Object> get props => [intent];
}

/// Dispatched when the user taps the final "Publish" button.
class UploadSubmitted extends UploadEvent {
  final String userId;

  const UploadSubmitted(this.userId);

  @override
  List<Object> get props => [userId];
}

/// Dispatched to clear the state and reset the upload page.
class UploadReset extends UploadEvent {}

/// Internal event used by the use case to report upload progress.
class _UploadProgressUpdated extends UploadEvent {
  final double progress;

  const _UploadProgressUpdated(this.progress);

  @override
  List<Object> get props => [progress];
}

class UploadShowCameraView extends UploadEvent {}

class UploadShowInitialView extends UploadEvent {}