// lib/features/upload/presentation/pages/camera_screen.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// IMPORTANT: _cameras MUST be initialized once before CameraScreen is built.
late List<CameraDescription> _cameras;

Future<void> initializeCameras() async {
  try {
    print('Attempting to get available cameras...');
    _cameras = await availableCameras();
    print('Available cameras: ${_cameras.length}');
    if (_cameras.isEmpty) {
      print('WARNING: No cameras found on this device.');
    }
  } on CameraException catch (e) {
    debugPrint('Error getting available cameras: ${e.code}\nError Message: ${e.description}');
    _cameras = [];
  } catch (e) {
    debugPrint('Unexpected error getting available cameras: $e');
    _cameras = [];
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
  bool _hasPermissions = false;
  bool _isCameraInitializing = true;
  String? _cameraInitializationError;

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
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_hasPermissions && _selectedCamera != null) {
        _initializeCamera(_selectedCamera!);
      } else {
        _initializeCameraAndPermissions();
      }
    }
  }

  Future<void> _initializeCameraAndPermissions() async {
    setState(() {
      _isCameraInitializing = true;
      _cameraInitializationError = null;
    });

    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      setState(() {
        _hasPermissions = true;
      });
      if (_cameras.isNotEmpty) {
        _selectedCamera = _cameras.first;
        await _initializeCamera(_selectedCamera!);
      } else {
        _showErrorDialog('No cameras available on this device.', 'No Camera');
        setState(() {
          _isCameraInitializing = false;
          _cameraInitializationError = 'No cameras found.';
        });
      }
    } else {
      setState(() {
        _hasPermissions = false;
        _isCameraInitializing = false;
      });
      _showPermissionDeniedDialog(cameraStatus, microphoneStatus);
    }
  }

  Future<void> _initializeCamera(CameraDescription cameraDescription) async {
    await _cameraController?.dispose();

    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      print('Initializing camera controller...');
      await _cameraController?.initialize();
      if (!mounted) return;
      print('Camera controller initialized.');
      setState(() {
        _isCameraInitializing = false;
        _cameraInitializationError = null;
      });
    } on CameraException catch (e) {
      print('Failed to initialize camera: ${e.description}');
      _showErrorDialog('Error initializing camera: ${e.description}', 'Camera Init Failed');
      setState(() {
        _isCameraInitializing = false;
        _cameraInitializationError = 'Error initializing camera: ${e.description}';
      });
    } catch (e) {
      print('Unexpected error during camera initialization: $e');
      _showErrorDialog('An unexpected error occurred: $e', 'Camera Error');
      setState(() {
        _isCameraInitializing = false;
        _cameraInitializationError = 'An unexpected error occurred: $e';
      });
    }
  }

  void _showErrorDialog(String message, String title) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
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
              openAppSettings();
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
    if (_cameras.length <= 1) {
      print('Only one camera available, cannot switch.');
      return;
    }

    final int newCameraIndex = (_cameras.indexOf(_selectedCamera!) + 1) % _cameras.length;
    _selectedCamera = _cameras[newCameraIndex];

    await _initializeCamera(_selectedCamera!);
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print('Camera not initialized. Cannot start recording.');
      _showErrorDialog('Camera is not ready. Please wait or try again.', 'Recording Issue');
      return;
    }
    if (_isRecording) {
      print('Already recording.');
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
        _videoPath = filePath;
      });
      print('Started recording to $filePath');
    } on CameraException catch (e) {
      _showErrorDialog('Error starting video recording: ${e.description}', 'Recording Error');
      print('Error starting video recording: ${e.description}');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _cameraController == null || !_cameraController!.value.isRecordingVideo) {
      print('Not recording or camera not ready. Cannot stop recording.');
      return;
    }

    try {
      final XFile videoFile = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _videoPath = videoFile.path;
      });
      print('Stopped recording. Video saved to: $_videoPath');
      _navigateToPostPage(_videoPath!);
    } on CameraException catch (e) {
      _showErrorDialog('Error stopping video recording: ${e.description}', 'Recording Error');
      print('Error stopping video recording: ${e.description}');
    }
  }

  Future<void> _pickVideoFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      setState(() {
        _videoPath = video.path;
      });
      print('Video picked from gallery: $_videoPath');
      _navigateToPostPage(_videoPath!);
    } else {
      print('No video picked from gallery.');
    }
  }

  void _navigateToPostPage(String videoPath) {
    if (!mounted) return;
    print('CameraScreen: Navigating to /createPost with videoPath: $videoPath');
    context.push('/createPost', extra: videoPath);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermissions) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_photography, size: 80, color: Colors.white70),
              const SizedBox(height: 20),
              const Text(
                'Camera and Microphone Permissions Required.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => openAppSettings(),
                child: const Text('Go to App Settings'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isCameraInitializing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text('Initializing camera...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    if (_cameraInitializationError != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cameraswitch_outlined, size: 80, color: Colors.redAccent),
              const SizedBox(height: 20),
              Text(
                'Camera Error: $_cameraInitializationError',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initializeCameraAndPermissions,
                child: const Text('Retry Camera'),
              ),
            ],
          ),
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: Text('Camera not ready. Unknown state.', style: TextStyle(color: Colors.white))));
    }

    // --- FIX FOR MAINTAINING ASPECT RATIO AND AVOIDING STRETCHING ---
    // Get the aspect ratio from the initialized camera controller
    final double aspectRatio = _cameraController!.value.aspectRatio;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen camera preview, wrapped in AspectRatio to prevent stretching
          Positioned.fill(
            child: AspectRatio( // <--- NEW: Wrap CameraPreview with AspectRatio
              aspectRatio: aspectRatio, // <--- Use the actual camera aspect ratio
              child: CameraPreview(_cameraController!),
            ),
          ),

          // Top Controls (Close, Camera Switcher)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => context.pop(),
                ),
                if (_cameras.length > 1)
                  IconButton(
                    icon: const Icon(Icons.switch_camera, color: Colors.white, size: 30),
                    onPressed: _toggleCamera,
                  ),
              ],
            ),
          ),

          // Bottom Controls (Gallery, Record Button)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.white, size: 40),
                  onPressed: _pickVideoFromGallery,
                  tooltip: 'Pick video from gallery',
                ),

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

                const SizedBox(width: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}