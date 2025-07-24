// lib/features/posts/presentation/bloc/upload_state.dart
part of 'upload_bloc.dart';

/// Enum representing the different stages of the upload process.
enum UploadStatus {
  initial,
  loadingThumbnail,
  uploading,
  success,
  failure,
}
enum UploadViewMode { initial, camera, preview }

class UploadState extends Equatable {
  /// The current view mode.
  final UploadViewMode viewMode;

  /// The current status of the upload process.
  final UploadStatus status;

  /// The video file selected by the user.
  final File? videoFile;

  /// The thumbnail file generated from the video.
  final File? thumbnailFile;

  /// The caption entered by the user.
  final String caption;

  /// The intent selected by the user (e.g., 'love').
  final String intent;

  /// The upload progress from 0.0 to 1.0.
  final double progress;

  /// An error message if the status is `failure`.
  final String error;

  const UploadState({
    this.viewMode = UploadViewMode.initial,
    this.status = UploadStatus.initial,
    this.videoFile,
    this.thumbnailFile,
    this.caption = '',
    this.intent = 'entertainment', // Default intent
    this.progress = 0.0,
    this.error = '',
  });

  /// Creates a copy of the current state with updated values.
  UploadState copyWith({
    UploadViewMode? viewMode,
    UploadStatus? status,
    File? videoFile,
    File? thumbnailFile,
    String? caption,
    String? intent,
    double? progress,
    String? error,
  }) {
    return UploadState(
      viewMode: viewMode ?? this.viewMode,
      status: status ?? this.status,
      videoFile: videoFile ?? this.videoFile,
      thumbnailFile: thumbnailFile ?? this.thumbnailFile,
      caption: caption ?? this.caption,
      intent: intent ?? this.intent,
      progress: progress ?? this.progress,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        viewMode,
        status,
        videoFile,
        thumbnailFile,
        caption,
        intent,
        progress,
        error,
      ];
}
