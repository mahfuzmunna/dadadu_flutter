// lib/features/upload/presentation/pages/upload_page.dart

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _onNewCameraSelected(_cameras[_selectedCameraIndex]);
    }
  }

  Future<void> _initialize() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        await _onNewCameraSelected(_cameras.first);
      }
    } else {
      // Handle permission denied state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Camera and microphone permissions are required.')));
      }
    }
  }

  Future<void> _onNewCameraSelected(CameraDescription description) async {
    final oldController = _cameraController;
    if (oldController != null) {
      await oldController.dispose();
    }

    final newController =
        CameraController(description, ResolutionPreset.high, enableAudio: true);
    _cameraController = newController;

    try {
      await newController.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _switchCamera() {
    if (_cameras.length > 1) {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
      _onNewCameraSelected(_cameras[_selectedCameraIndex]);
    }
  }

  Future<void> _toggleRecording() async {
    if (!_isCameraInitialized) return;

    if (_isRecording) {
      final file = await _cameraController!.stopVideoRecording();
      _timer?.cancel();
      setState(() {
        _isRecording = false;
        _recordSeconds = 0;
      });
      if (mounted) _navigateToCreatePost(file.path);
    } else {
      await _cameraController!.startVideoRecording();
      setState(() => _isRecording = true);
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

  Future<void> _pickFromGallery() async {
    final XFile? video =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (video != null && mounted) {
      _navigateToCreatePost(video.path);
    }
  }

  void _navigateToCreatePost(String videoPath) {
    // Assuming you have a route like '/createPost' that accepts the video path
    context.push('/createPost', extra: videoPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        // Full-screen Camera Preview
        Positioned.fill(
          child: AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
        ),
        // UI Controls Overlay
        _buildControlsOverlay(),
      ],
    );
  }

  Widget _buildControlsOverlay() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top controls: Timer and Camera Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimerChip(),
                IconButton(
                  onPressed: _isRecording ? null : _switchCamera,
                  icon: const Icon(Icons.flip_camera_ios_rounded,
                      color: Colors.white),
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.4)),
                ),
              ],
            ),
            const Spacer(),
            // Bottom controls: Gallery and Record Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _isRecording ? null : _pickFromGallery,
                  icon: const Icon(Icons.photo_library_rounded,
                      color: Colors.white, size: 32),
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.4)),
                ),
                _buildRecordButton(),
                // Placeholder for balance
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerChip() {
    if (!_isRecording) return const SizedBox.shrink();
    return Chip(
      avatar: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
            color: Colors.redAccent, shape: BoxShape.circle),
      ),
      label: Text(
        '0:${_recordSeconds.toString().padLeft(2, '0')} / 0:20',
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.black.withOpacity(0.4),
      side: BorderSide.none,
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _toggleRecording,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isRecording ? 35 : 65,
            height: _isRecording ? 35 : 65,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(_isRecording ? 8 : 35),
            ),
          ),
        ),
      ),
    );
  }
}
