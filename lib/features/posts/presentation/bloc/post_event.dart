part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched from the UI to start the entire post upload process.
class UploadPost extends PostEvent {
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
class _UploadProgressUpdated extends PostEvent {
  final double progress;

  const _UploadProgressUpdated(this.progress);

  @override
  List<Object> get props => [progress];
}

class LoadPost extends PostEvent {
  final String postId;

  const LoadPost(this.postId);
}

class IncrementLike extends PostEvent {
  final String postId;

  const IncrementLike(this.postId);
}

// Internal event for stream updates
class _PostUpdated extends PostEvent {
  final PostEntity post;

  const _PostUpdated({required this.post});
}