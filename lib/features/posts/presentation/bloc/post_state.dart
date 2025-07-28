part of 'post_bloc.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

/// The initial state before any action has been taken.
class PostInitial extends PostState {}

/// State indicating that the initial post and author data are being fetched.
class PostLoading extends PostState {}

/// State for when a post and its author have been successfully loaded.
/// This state is also used for real-time updates.
class PostLoaded extends PostState {
  final PostEntity post;
  final UserEntity? author;

  const PostLoaded({required this.post, this.author});

  /// Creates a copy of the current state with updated values.
  /// This is crucial for preserving the author while updating the post from a stream.
  PostLoaded copyWith({
    PostEntity? post,
    UserEntity? author,
  }) {
    return PostLoaded(
      post: post ?? this.post,
      author: author ?? this.author,
    );
  }

  @override
  List<Object?> get props => [post, author];
}

/// A generic error state for any failure during post loading.
class PostError extends PostState {
  final String message;

  const PostError(this.message);

  @override
  List<Object> get props => [message];
}


// --- Upload-specific States ---

/// The initial state for the upload feature before a post is submitted.
class UploadInitial extends PostState {}

/// State indicating that a post upload is currently in progress.
class UploadInProgress extends PostState {
  final double progress;

  const UploadInProgress(this.progress);

  @override
  List<Object> get props => [progress];
}

/// State emitted when the post has been successfully published.
class UploadSuccess extends PostState {}

/// State emitted when an error occurs during the upload process.
class UploadFailure extends PostState {
  final String message;

  const UploadFailure(this.message);

  @override
  List<Object> get props => [message];
}
