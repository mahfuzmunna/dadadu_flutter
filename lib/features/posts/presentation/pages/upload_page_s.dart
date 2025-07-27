// lib/features/upload/presentation/pages/upload_page.dart

import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;
  bool _showZoomIndicator = false;
  Timer? _zoomIndicatorTimer;

  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _timer?.cancel();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
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

      _maxZoomLevel = await newController.getMaxZoomLevel();
      _minZoomLevel = await newController.getMinZoomLevel();

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

  Future<void> _toggleFlashMode() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    final nextMode =
        FlashMode.values[(_flashMode.index + 1) % FlashMode.values.length];
    try {
      await _cameraController!.setFlashMode(nextMode);
      setState(() {
        _flashMode = nextMode;
      });
    } on CameraException catch (e) {
      debugPrint('Error setting flash mode: $e');
    }
  }

  Future<void> _toggleRecording() async {
    if (!_isCameraInitialized) return;

    if (_isRecording) {
      // Unlock orientation when recording stops
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      final file = await _cameraController!.stopVideoRecording();
      _timer?.cancel();
      setState(() {
        _isRecording = false;
        _recordSeconds = 0;
      });
      if (mounted) _navigateToCreatePost(file.path);
    } else {
      // Lock orientation during recording to prevent issues
      final orientation = MediaQuery.of(context).orientation;
      if (orientation == Orientation.landscape) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]);
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }

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
    context.push('/createPost', extra: videoPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseZoomLevel = _currentZoomLevel;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (_cameraController == null || _isRecording) return;

    // Calculate the new zoom level and clamp it within the supported range
    final double newZoomLevel =
        (_baseZoomLevel * details.scale).clamp(_minZoomLevel, _maxZoomLevel);

    if (newZoomLevel != _currentZoomLevel) {
      await _cameraController!.setZoomLevel(newZoomLevel);
      setState(() {
        _currentZoomLevel = newZoomLevel;
        _showZoomIndicator = true;
      });

      // Hide the zoom indicator after a short delay
      _zoomIndicatorTimer?.cancel();
      _zoomIndicatorTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showZoomIndicator = false);
      });
    }
  }

  Widget _buildBody() {
    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // ✅ FIX: Calculate the scale to fill the screen without distortion.
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final previewRatio = _cameraController!.value.aspectRatio;

    // We use a scale factor to fill the screen, "cropping" the excess.
    // This is the same technique native camera apps use.
    var scale = 1 / (_cameraController!.value.aspectRatio * size.aspectRatio);

    // ✅ Check if the current camera is the front camera.
    final bool isFrontCamera = _cameraController!.description.lensDirection ==
        CameraLensDirection.front;

    // ✅ NEW: Use OrientationBuilder to react to screen rotation
    return OrientationBuilder(builder: (context, orientation) {
      return Stack(
        children: [
          // Full-screen Camera Preview
          Positioned.fill(
            child: GestureDetector(
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              // ✅ This FittedBox and RotatedBox combination handles all aspect ratios
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.center,
                child: Transform(
                  alignment: Alignment.center,
                  transform: isFrontCamera
                      ? (Matrix4.rotationY(math.pi * 2))
                      : Matrix4.identity(),
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),
          ),
          // UI Controls Overlay
          _buildControlsOverlay(),
          _buildZoomIndicator(),
        ],
      );
    });
  }

// ✅ NEW: Helper to determine the correct rotation for the preview
  int _getQuarterTurns() {
    final orientation = _cameraController!.description.sensorOrientation;
    switch (orientation) {
      case 90:
        return 0;
      case 180:
        return 3;
      case 270:
        return 2;
      default: // 0
        return 1;
    }
  }

  Widget _buildZoomIndicator() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showZoomIndicator ? 1.0 : 0.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentZoomLevel.toStringAsFixed(1)}x',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildControlButton(
                  icon: Icons.close_rounded,
                  onPressed: () => context.go('/home'), // Navigate home
                ),
                _buildTimerChip(),
                _buildControlButton(
                  icon: _getFlashIcon(),
                  onPressed: _isRecording ? null : _toggleFlashMode,
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeSelectorChip(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.photo_library_rounded,
                  onPressed: _isRecording ? null : _pickFromGallery,
                ),
                _buildRecordButton(),
                _buildControlButton(
                  icon: Icons.flip_camera_ios_rounded,
                  onPressed: _isRecording ? null : _switchCamera,
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto_rounded;
      case FlashMode.always:
        return Icons.flash_on_rounded;
      case FlashMode.torch:
        return Icons.highlight_rounded;
      case FlashMode.off:
        return Icons.flash_off_rounded;
    }
  }

  Widget _buildTimerChip() {
    if (!_isRecording) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glowing red dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.7),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '0:${_recordSeconds.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelectorChip() {
    final bool isSelected = true;

    return Chip(
      // The main text content of the chip
      label: const Text(
        '20s',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),

      shape: const StadiumBorder(),
      // Gives it the modern pill shape
      side: BorderSide(
        color: isSelected
            ? Colors.transparent
            : Theme.of(context).colorScheme.outline,
      ),
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
    );
  }

  Widget _buildControlButton(
      {required IconData icon, VoidCallback? onPressed}) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 30),
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.5),
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.4),
      ),
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