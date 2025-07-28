part of 'upload_bloc.dart';

abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched from the UI to start the entire post upload process.
class UploadPost extends UploadEvent {
  final File videoFile;
  final Uint8List thumbnailBytes;
  final String caption;
  final String intent;
  final String userId;

  const UploadPost({
    required this.videoFile,
    required this.thumbnailBytes,
    required this.caption,
    required this.intent,
    required this.userId,
  });

  @override
  List<Object?> get props =>
      [videoFile, thumbnailBytes, caption, intent, userId];
}

/// Internal event used by the use case to report upload progress back to the BLoC.
class _UploadProgressUpdated extends UploadEvent {
  final double progress;

  const _UploadProgressUpdated(this.progress);

  @override
  List<Object> get props => [progress];
}
