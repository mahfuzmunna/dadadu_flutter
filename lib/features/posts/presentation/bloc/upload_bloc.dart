import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/posts/domain/usecases/upload_post_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

part 'upload_event.dart';
part 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final UploadPostUseCase _uploadPostUseCase;

  UploadBloc({required UploadPostUseCase uploadPostUseCase})
      : _uploadPostUseCase = uploadPostUseCase,
        super(const UploadState()) {
    on<UploadCaptionChanged>(_onCaptionChanged);
    on<UploadIntentChanged>(_onIntentChanged);
    on<UploadSubmitted>(_onSubmitted);
    on<UploadReset>(_onReset);
    on<_UploadProgressUpdated>(_onUploadProgressUpdated);
    on<UploadVideoSelected>(_onVideoSelected);
    on<UploadShowCameraView>(
        (event, emit) => emit(state.copyWith(viewMode: UploadViewMode.camera)));
    on<UploadShowInitialView>((event, emit) {
      // When resetting, also clear the files
      emit(state.copyWith(
          viewMode: UploadViewMode.initial,
          videoFile: null,
          thumbnailFile: null,
          status: UploadStatus.initial));
    });
  }

  // Future<void> _onVideoSelected(UploadVideoSelected event, Emitter<UploadState> emit) async {
  //   // This handler now also changes the view mode to preview
  //   emit(state.copyWith(status: UploadStatus.loadingThumbnail, viewMode: UploadViewMode.preview));
  //   // ... rest of the thumbnail generation logic
  // }
  // // ...

  Future<void> _onVideoSelected(
      UploadVideoSelected event, Emitter<UploadState> emit) async {
    emit(state.copyWith(status: UploadStatus.loadingThumbnail));
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: event.videoFile.path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );
      if (thumbnailPath != null) {
        emit(state.copyWith(
          status: UploadStatus.initial,
          videoFile: event.videoFile,
          thumbnailFile: File(thumbnailPath),
        ));
      } else {
        throw Exception('Failed to generate thumbnail');
      }
    } catch (e) {
      emit(state.copyWith(
          status: UploadStatus.failure, error: 'Could not process video.'));
    }
  }

  void _onCaptionChanged(
      UploadCaptionChanged event, Emitter<UploadState> emit) {
    emit(state.copyWith(caption: event.caption));
  }

  void _onIntentChanged(UploadIntentChanged event, Emitter<UploadState> emit) {
    emit(state.copyWith(intent: event.intent));
  }

  Future<void> _onSubmitted(
      UploadSubmitted event, Emitter<UploadState> emit) async {
    if (state.videoFile == null ||
        state.thumbnailFile == null ||
        state.caption.isEmpty) return;

    emit(state.copyWith(status: UploadStatus.uploading, progress: 0.0));

    final result = await _uploadPostUseCase(UploadPostParams(
      videoFile: state.videoFile!,
      thumbnailFile: state.thumbnailFile!,
      caption: state.caption,
      intent: state.intent,
      userId: event.userId,
      onUploadProgress: (progress) {
        add(_UploadProgressUpdated(
            progress)); // Internal event to update progress
      },
    ));

    result.fold(
      (failure) => emit(
          state.copyWith(status: UploadStatus.failure, error: failure.message)),
      (_) => emit(state.copyWith(status: UploadStatus.success)),
    );
  }

  void _onUploadProgressUpdated(
      _UploadProgressUpdated event, Emitter<UploadState> emit) {
    emit(state.copyWith(progress: event.progress));
  }

  void _onReset(UploadReset event, Emitter<UploadState> emit) {
    emit(const UploadState());
  }

// You need to add a private event for progress updates to avoid calling emit from outside the BLoC
// In upload_event.dart: class _UploadProgressUpdated extends UploadEvent { final double progress; ... }
// on<_UploadProgressUpdated>((event, emit) => emit(state.copyWith(progress: event.progress)));
}

// Corresponding event and state files (upload_event.dart, upload_state.dart) would be needed.
