import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/posts/domain/usecases/upload_post_usecase.dart';
import 'package:equatable/equatable.dart';

part 'upload_event.dart';
part 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final UploadPostUseCase _uploadPostUseCase;

  UploadBloc({required UploadPostUseCase uploadPostUseCase})
      : _uploadPostUseCase = uploadPostUseCase,
        super(UploadInitial()) {
    on<UploadPost>(_onUploadPost);
    on<_UploadProgressUpdated>(_onUploadProgressUpdated);
  }

  Future<void> _onUploadPost(
      UploadPost event, Emitter<UploadState> emit) async {
    emit(const UploadInProgress(0.0));
    final result = await _uploadPostUseCase(UploadPostParams(
      videoFile: event.videoFile,
      thumbnailBytes: event.thumbnailBytes,
      caption: event.caption,
      intent: event.intent,
      userId: event.userId,
      onUploadProgress: (progress) {
        if (!isClosed) {
          add(_UploadProgressUpdated(progress));
        }
      },
    ));
    result.fold(
      (failure) => emit(UploadFailure(failure.message)),
      (_) => emit(UploadSuccess()),
    );
  }

  void _onUploadProgressUpdated(
      _UploadProgressUpdated event, Emitter<UploadState> emit) {
    emit(UploadInProgress(event.progress));
  }
}
// Create the corresponding event and state files for this BLoC