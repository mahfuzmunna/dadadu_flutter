// lib/features/upload/presentation/pages/camera_screen.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

late List<CameraDescription> _cameras; // Global variable to store available cameras

Future<void> initializeCameras() async {
  try {
    _cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Error: ${e.code}\nError Message: ${e.description}');
    _cameras = []; // Ensure it's an empty list on error
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isRecording = false;
  CameraDescription? _selectedCamera;
  String? _videoPath;
  bool _hasPermissions = false; // Track if app has camera/microphone permissions

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCameraAndPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed (e.g., app in background/foreground)
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera(_selectedCamera!); // Re-initialize camera when app resumes
    }
  }

  Future<void> _initializeCameraAndPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      setState(() {
        _hasPermissions = true;
      });
      if (_cameras.isNotEmpty) {
        _selectedCamera = _cameras.first; // Default to the first camera (usually back)
        await _initializeCamera(_selectedCamera!);
      } else {
        _showErrorDialog('No cameras available.');
      }
    } else {
      setState(() {
        _hasPermissions = false;
      });
      _showPermissionDeniedDialog(cameraStatus, microphoneStatus);
    }
  }

  Future<void> _initializeCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium, // Adjust resolution as needed (high, ultraHigh)
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.yuv420, // Recommended for performance
    );

    try {
      await _cameraController?.initialize();
      if (!mounted) return;
      setState(() {});
    } on CameraException catch (e) {
      _showErrorDialog('Error initializing camera: ${e.description}');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog(
      PermissionStatus cameraStatus, PermissionStatus microphoneStatus) {
    if (!mounted) return;
    String message = 'Camera and microphone permissions are required to use this feature.';
    if (cameraStatus.isDenied || microphoneStatus.isDenied) {
      message = 'Please grant camera and microphone permissions in app settings.';
    } else if (cameraStatus.isPermanentlyDenied || microphoneStatus.isPermanentlyDenied) {
      message = 'Permissions permanently denied. Please go to app settings to enable them.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              openAppSettings(); // Opens the app's settings page
            },
            child: const Text('Go to Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCamera() async {
    if (_cameras.isEmpty || _cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final int newCameraIndex = (_cameras.indexOf(_selectedCamera!) + 1) % _cameras.length;
    _selectedCamera = _cameras[newCameraIndex];

    await _cameraController?.dispose(); // Dispose current controller
    await _initializeCamera(_selectedCamera!); // Initialize new controller
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isRecording) {
      return;
    }

    final Directory appDirectory = await getTemporaryDirectory();
    final String videoDirectory = '${appDirectory.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    final String filePath = '${videoDirectory}/${DateTime.now().millisecondsSinceEpoch}.mp4';

    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _videoPath = filePath; // Store the expected path
      });
    } on CameraException catch (e) {
      _showErrorDialog('Error starting video recording: ${e.description}');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _cameraController == null || !_cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      final XFile videoFile = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _videoPath = videoFile.path;
      });
      // Navigate to Post Page with the video path
      _navigateToPostPage(_videoPath!);
    } on CameraException catch (e) {
      _showErrorDialog('Error stopping video recording: ${e.description}');
    }
  }

  Future<void> _pickVideoFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      setState(() {
        _videoPath = video.path;
      });
      // Navigate to Post Page with the selected video path
      _navigateToPostPage(_videoPath!);
    }
  }

  void _navigateToPostPage(String videoPath) {
    if (!mounted) return;
    context.push('/createPost', extra: videoPath); // Pass video path as an extra
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermissions) {
      return const Center(
        child: Text(
          'Permissions not granted. Please enable Camera and Microphone in settings.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return Scaffold(
      backgroundColor: Colors.black, // Full screen camera, so background is black
      body: Stack(
        children: [
          // Full-screen camera preview
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),

          // Top Controls (Camera Switcher)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => context.pop(), // Go back to previous screen (e.g., home)
                ),
                if (_cameras.length > 1) // Only show if multiple cameras available
                  IconButton(
                    icon: const Icon(Icons.switch_camera, color: Colors.white, size: 30),
                    onPressed: _toggleCamera,
                  ),
              ],
            ),
          ),

          // Bottom Controls (Record Button, Gallery)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery Icon
                IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.white, size: 40),
                  onPressed: _pickVideoFromGallery,
                  tooltip: 'Pick video from gallery',
                ),

                // Record Button
                GestureDetector(
                  onTap: _isRecording ? _stopRecording : _startRecording,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.fiber_manual_record,
                      color: _isRecording ? Colors.red : Colors.red,
                      size: 70,
                    ),
                  ),
                ),

                // Placeholder for future features or just for spacing
                const SizedBox(width: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}