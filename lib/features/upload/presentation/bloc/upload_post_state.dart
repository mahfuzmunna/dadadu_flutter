// lib/features/upload/presentation/bloc/upload_post_state.dart

part of 'upload_post_bloc.dart';

@immutable
abstract class UploadPostState extends Equatable {
  const UploadPostState();

  @override
  List<Object?> get props => [];
}

class UploadPostInitial extends UploadPostState {}

class UploadPostLoading extends UploadPostState {
  final double progress; // Progress from 0.0 to 1.0

  const UploadPostLoading({this.progress = 0.0});

  @override
  List<Object> get props => [progress];
}

class UploadPostSuccess extends UploadPostState {
  final String postId;
  final String videoUrl;

  const UploadPostSuccess({required this.postId, required this.videoUrl});

  @override
  List<Object> get props => [postId, videoUrl];
}

class UploadPostError extends UploadPostState {
  final String message;

  const UploadPostError({required this.message});

  @override
  List<Object> get props => [message];
}