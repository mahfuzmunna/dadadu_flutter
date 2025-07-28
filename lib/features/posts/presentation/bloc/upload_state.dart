part of 'upload_bloc.dart';

abstract class UploadState extends Equatable {
  const UploadState();

  @override
  List<Object> get props => [];
}

/// The initial state before any upload is attempted.
class UploadInitial extends UploadState {}

/// State indicating that the upload is currently in progress.
class UploadInProgress extends UploadState {
  final double progress;

  const UploadInProgress(this.progress);

  @override
  List<Object> get props => [progress];
}

/// State emitted when the post has been successfully published.
class UploadSuccess extends UploadState {}

/// State emitted when an error occurs during the upload process.
class UploadFailure extends UploadState {
  final String message;

  const UploadFailure(this.message);

  @override
  List<Object> get props => [message];
}
