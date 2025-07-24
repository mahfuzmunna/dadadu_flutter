import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../bloc/upload_bloc.dart';
import 'trimmer_screen.dart';

class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<UploadBloc>(),
      child: const _UploadView(),
    );
  }
}

class _UploadView extends StatefulWidget {
  const _UploadView();

  @override
  State<_UploadView> createState() => __UploadViewState();
}

class __UploadViewState extends State<_UploadView> {
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickAndTrimVideo() async {
    final XFile? result =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (result == null || !context.mounted) return;

    final trimmedPath = await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => TrimmerScreen(videoFile: File(result.path))),
    );

    if (trimmedPath != null && context.mounted) {
      context.read<UploadBloc>().add(UploadVideoSelected(File(trimmedPath)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Post'),
        centerTitle: true,
        actions: [
          BlocBuilder<UploadBloc, UploadState>(
            builder: (context, state) {
              final isReady =
                  state.videoFile != null && state.caption.isNotEmpty;
              return TextButton(
                onPressed: isReady && state.status != UploadStatus.uploading
                    ? () {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthAuthenticated) {
                          context
                              .read<UploadBloc>()
                              .add(UploadSubmitted(authState.user.id));
                        }
                      }
                    : null,
                child: const Text('Publish'),
              );
            },
          )
        ],
      ),
      body: BlocConsumer<UploadBloc, UploadState>(
        listener: (context, state) {
          if (state.videoFile?.path != _videoController?.dataSource) {
            _videoController?.dispose();
            _videoController = null;
            if (state.videoFile != null) {
              _videoController = VideoPlayerController.file(state.videoFile!)
                ..initialize().then((_) {
                  _videoController?.setLooping(true);
                  if (mounted) setState(() {});
                });
            }
          }
          if (state.status == UploadStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upload successful!')));
          } else if (state.status == UploadStatus.failure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 9 / 16,
                  child: _buildMainContent(context, state),
                ),
                const SizedBox(height: 16),
                if (state.viewMode == UploadViewMode.preview) ...[
                  TextFormField(
                    initialValue: state.caption,
                    decoration: const InputDecoration(
                        hintText: 'Add a caption...',
                        border: OutlineInputBorder()),
                    maxLines: 3,
                    onChanged: (value) => context
                        .read<UploadBloc>()
                        .add(UploadCaptionChanged(value)),
                  ),
                  const SizedBox(height: 16),
                  _IntentSelector(
                    selectedIntent: state.intent,
                    onIntentSelected: (intent) => context
                        .read<UploadBloc>()
                        .add(UploadIntentChanged(intent)),
                  ),
                  const SizedBox(height: 24),
                  if (state.status == UploadStatus.uploading)
                    LinearProgressIndicator(value: state.progress),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, UploadState state) {
    switch (state.viewMode) {
      case UploadViewMode.initial:
        return _buildInitialView(context);
      case UploadViewMode.camera:
        return _CameraView(
          onVideoRecorded: (videoFile) {
            context.read<UploadBloc>().add(UploadVideoSelected(videoFile));
          },
        );
      case UploadViewMode.preview:
        return _buildPreview(context, state);
    }
  }

  Widget _buildInitialView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Create a new post",
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Select from Gallery'),
            onPressed: _pickAndTrimVideo,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.videocam_rounded),
            label: const Text('Record Now'),
            onPressed: () =>
                context.read<UploadBloc>().add(UploadShowCameraView()),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context, UploadState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        image: state.thumbnailFile != null
            ? DecorationImage(
                image: FileImage(state.thumbnailFile!), fit: BoxFit.cover)
            : null,
      ),
      child: Stack(
        children: [
          if (state.status == UploadStatus.loadingThumbnail)
            const Center(child: CircularProgressIndicator()),
          if (_videoController?.value.isInitialized ?? false)
            Center(
                child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!))),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () =>
                  context.read<UploadBloc>().add(UploadShowInitialView()),
            ),
          ),
        ],
      ),
    );
  }
}

// A helper widget for the camera view, encapsulated for clarity
class _CameraView extends StatefulWidget {
  final ValueChanged<File> onVideoRecorded;

  const _CameraView({required this.onVideoRecorded});

  @override
  State<_CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<_CameraView> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _timer;
  bool _isCameraInitializing = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (await Permission.camera.request().isGranted &&
        await Permission.microphone.request().isGranted) {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _onNewCameraSelected(_cameras.first);
      }
    } else {
      // Handle permission denied
    }
  }

  Future<void> _onNewCameraSelected(CameraDescription description) async {
    if (mounted)
      setState(() {
        _isCameraInitializing = true;
      });
    final oldController = _cameraController;
    if (oldController != null) {
      await oldController.dispose();
    }

    final newController =
        CameraController(description, ResolutionPreset.high, enableAudio: true);
    _cameraController = newController;

    try {
      await newController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }
    if (mounted) setState(() => _isCameraInitializing = false);
  }

  void _switchCamera() {
    if (_cameras.length < 2 || _cameraController == null) return;

    final currentLensDirection = _cameraController!.description.lensDirection;
    final newDescription = _cameras.firstWhere(
      (desc) => desc.lensDirection != currentLensDirection,
      orElse: () => _cameras.first,
    );
    _onNewCameraSelected(newDescription);
  }

  Future<void> _toggleRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    if (_isRecording) {
      final file = await _cameraController!.stopVideoRecording();
      _timer?.cancel();
      setState(() => _isRecording = false);
      widget.onVideoRecorded(File(file.path));
    } else {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordSeconds = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() => _recordSeconds++);
        if (_recordSeconds >= 20) {
          _toggleRecording();
        }
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCameraInitializing ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CameraPreview(_cameraController!),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (_isRecording)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_recordSeconds / 20s',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => context
                          .read<UploadBloc>()
                          .add(UploadShowInitialView()),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // A placeholder to balance the row
                    IconButton(
                      icon:
                          const Icon(Icons.flash_on, color: Colors.transparent),
                      onPressed: null,
                    ),
                    IconButton(
                      icon: Icon(
                        _isRecording
                            ? Icons.stop_circle
                            : Icons.radio_button_checked,
                        color: Colors.redAccent,
                        size: 64,
                      ),
                      onPressed: _toggleRecording,
                    ),
                    IconButton(
                      icon: const Icon(Icons.flip_camera_ios,
                          color: Colors.white, size: 28),
                      onPressed: _isRecording
                          ? null
                          : _switchCamera, // Disable while recording
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Your _IntentSelector widget remains the same

// A helper widget for the intent selector for better readability
class _IntentSelector extends StatelessWidget {
  final String selectedIntent;
  final ValueChanged<String> onIntentSelected;

  const _IntentSelector(
      {required this.selectedIntent, required this.onIntentSelected});

  @override
  Widget build(BuildContext context) {
    final intents = {
      'love': Icons.favorite,
      'business': Icons.business_center,
      'entertainment': Icons.movie
    };
    return Row(
      children: intents.entries.map((entry) {
        final isSelected = selectedIntent == entry.key;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: OutlinedButton.icon(
              icon: Icon(entry.value),
              label: Text(entry.key[0].toUpperCase() + entry.key.substring(1)),
              onPressed: () => onIntentSelected(entry.key),
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
