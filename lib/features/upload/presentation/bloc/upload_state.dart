// lib/features/upload/presentation/bloc/post_state.dart
part of 'upload_bloc.dart'; // This line links it to the bloc file

@immutable
abstract class UploadState extends Equatable {
  const UploadState();

  @override
  List<Object?> get props => [];
}

/// Initial state of the upload process.
class UploadInitial extends UploadState {}

/// State indicating that the upload process is currently in progress.
class UploadLoading extends UploadState {}

/// State indicating that the video post has been successfully uploaded.
class UploadSuccess extends UploadState {
  final PostEntity post; // The successfully created post entity

  const UploadSuccess({required this.post});

  @override
  List<Object?> get props => [post];
}

/// State indicating that an error occurred during the upload process.
class UploadError extends UploadState {
  final String message; // Error message

  const UploadError({required this.message});

  @override
  List<Object?> get props => [message];
}
