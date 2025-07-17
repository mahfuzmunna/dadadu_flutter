import 'dart:io';
import 'dart:async';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:start/generated/l10n.dart';
import 'package:start/screens/home_screen.dart';
import 'package:start/screens/trimmer_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with TickerProviderStateMixin {
  File? _videoFile;
  VideoPlayerController? _videoController;
  CameraController? _cameraController;

  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final DatabaseService _dbService = DatabaseService();

  bool _isUploading = false;
  bool _isRecording = false;
  bool _isInitialized = false;
  bool _showCamera = false;
  String _selectedIntent = 'love';
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  double _uploadProgress = 0.0;

  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;

  final List<String> _intents = ['love', 'business', 'entertainment'];
  final Map<String, IconData> _intentIcons = {
    'love': Icons.favorite,
    'business': Icons.business_center,
    'entertainment': Icons.sports_esports,
  };
  final Map<String, Color> _intentColors = {
    'love': Colors.pinkAccent,
    'business': Colors.blueAccent,
    'entertainment': Colors.orangeAccent,
  };

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initCamera();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
          enableAudio: true,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() => _isInitialized = true);
        }
      }
    } catch (e) {
      debugPrint('Camera error: $e');
      _showError('Camera error: Check permissions');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _videoController?.dispose();
    _cameraController?.dispose();
    _captionController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

 Future<void> _pickVideoFromGallery() async {
  final strings = S.of(context);

  try {
    final XFile? result =
        await _picker.pickVideo(source: ImageSource.gallery);

    if (result != null) {
      final trimmedPath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrimmerView(
            videoFilePath: result.path,
          ),
        ),
      );

      if (trimmedPath != null) {
        await _setVideoFile(File(trimmedPath));
        setState(() => _showCamera = false);
        HapticFeedback.lightImpact();
      }
    }
  } catch (e) {
    debugPrint('Video selection error: $e');
    _showError(strings.selectionError(e.toString()));
  }
}

Future<void> _setVideoFile(File file) async {
  final strings = S.of(context);

  try {
    _videoFile = file;
    _videoController?.dispose();
    _videoController = VideoPlayerController.file(file);

    await _videoController!.initialize();
    if (mounted) {
      setState(() {});
      _videoController?.setLooping(true);
      _videoController?.play();
    }
  } catch (e) {
    debugPrint('Video loading error: $e');
    _showError(strings.videoLoadingError(e.toString()));
  }
}


  Future<void> _startRecording() async {
     final strings = S.of(context);
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showError('Camera not initialized');
      return;
    }

    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });

      _pulseController.repeat(reverse: true);
      _progressController.forward();

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() => _recordingSeconds++);
          if (_recordingSeconds >= 20) {
            _stopRecording();
          }
        }
      });

      HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Recording error: $e');
     _showError(strings.recordingError(e.toString()));

    }
  }

  Future<void> _stopRecording() async {
    final strings = S.of(context);
    if (!_isRecording) return;

    try {
      final XFile videoFile = await _cameraController!.stopVideoRecording();
      await _setVideoFile(File(videoFile.path));

      setState(() {
        _isRecording = false;
        _showCamera = false;
        _recordingSeconds = 0;
      });

      _pulseController.stop();
      _progressController.reset();
      _recordingTimer?.cancel();

      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Stop recording error: $e');
      _showError(strings.stopRecordingError(e));
    }
  }

 Future<void> _uploadVideo() async {
  final strings = S.of(context);

  if (_videoFile == null) {
    _showError(strings.noVideoSelected);
    return;
  }

  if (_captionController.text.trim().isEmpty) {
    _showError(strings.pleaseAddCaption);
    return;
  }

  setState(() {
    _isUploading = true;
    _uploadProgress = 0.0;
  });

  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception(strings.userNotLoggedIn);
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      throw Exception(strings.userProfileNotFound);
    }

    final userData = userDoc.data()!;
    final String videoId = const Uuid().v4();

    final videoRef =
        FirebaseStorage.instance.ref().child('videos').child('$videoId.mp4');

    final videoUploadTask = videoRef.putFile(
        _videoFile!, SettableMetadata(contentType: 'video/mp4'));

    videoUploadTask.snapshotEvents.listen((snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      if (mounted) {
        setState(() => _uploadProgress = progress);
      }
    });

    await videoUploadTask;
    final String videoUrl = await videoRef.getDownloadURL();
final locale = Localizations.localeOf(context);
    await _dbService.uploadVideo(
      url: videoUrl,
      thumbnailUrl: '',
      caption: _captionController.text.trim(),
      intent: _selectedIntent,
      language: userData['language'] ?? 'en',
    );

    if (mounted) {
      setState(() => _uploadProgress = 1.0);
      _showSuccess(strings.videoPublishedSuccessfully);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 0)),
        (route) => false,
      );
    }
  } catch (e) {
    debugPrint('Upload error: $e');
    if (mounted) {
      _showError('${strings.uploadError}: ${e.toString()}');
    }
  } finally {
    if (mounted) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }
}

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildCameraView() {
     final s = S.of(context);
    if (!_isInitialized || _cameraController == null) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child:  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
               s.initializingCamera,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _intentColors[_selectedIntent]!.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Camera preview
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            ),

            // Recording timer
            if (_isRecording) ...[
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_recordingSeconds}s / 20s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Progress bar
              Positioned(
                bottom: 100,
                left: 20,
                right: 20,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _recordingSeconds / 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // Record button
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isRecording ? _pulseAnimation.value : 1.0,
                      child: GestureDetector(
                        onTap: _isRecording ? _stopRecording : _startRecording,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording ? Colors.red : Colors.white,
                            border: Border.all(
                              color: _isRecording ? Colors.white : Colors.red,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (_isRecording ? Colors.red : Colors.white)
                                        .withValues(alpha: 0.3),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.videocam,
                            color: _isRecording ? Colors.white : Colors.red,
                            size: 32,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Close button
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => setState(() => _showCamera = false),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _intentColors[_selectedIntent]!.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Video
            if (_videoController != null &&
                _videoController!.value.isInitialized)
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              ),

            // Play/pause overlay
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  if (_videoController != null) {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                    } else {
                      _videoController!.play();
                    }
                    setState(() {});
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity:
                          _videoController?.value.isPlaying == true ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Delete button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _videoFile = null;
                    _showCamera = false;
                  });
                  _videoController?.dispose();
                  _videoController = null;
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildActionButtons() {
  final strings = S.of(context);

  return Row(
    children: [
      Expanded(
        child: ElevatedButton.icon(
          onPressed: _pickVideoFromGallery,
          icon: const Icon(Icons.photo_library, size: 20),
          label: Text(strings.gallery),  // localized
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () => setState(() => _showCamera = !_showCamera),
          icon: Icon(
            _showCamera ? Icons.videocam_off : Icons.videocam,
            size: 20,
          ),
          label: Text(_showCamera ? strings.close : strings.camera),  // localized
          style: ElevatedButton.styleFrom(
            backgroundColor: _intentColors[_selectedIntent],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
          ),
        ),
      ),
    ],
  );
}

 Widget _buildIntentSelector(bool isDark, {required ThemeData theme}) {
  final strings = S.of(context);

  
  // For example, if your intents are ['fun', 'serious', 'informative'], map them like this:

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1a1a1a) : const Color(0xFFF9F9F9),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: _intentColors[_selectedIntent]!.withAlpha(80), // changed withValues to withAlpha
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.category,
              color: _intentColors[_selectedIntent],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              strings.videoIntent, // localized "Video Intent"
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: _intents.map((intent) {
            final isSelected = _selectedIntent == intent;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedIntent = intent);
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _intentColors[intent]!.withAlpha(50)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected
                          ? _intentColors[intent]!
                          : Colors.grey[600]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _intentIcons[intent],
                        color: isSelected
                            ? _intentColors[intent]
                            : Colors.grey[400],
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                         intent.toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? _intentColors[intent]
                              : Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}

  @override
 Widget build(BuildContext context) {
  final hasVideo = _videoFile != null;
  final isReadyToUpload =
      hasVideo && _captionController.text.trim().isNotEmpty;

  final theme = Theme.of(context);
  final isDarkMode = AdaptiveTheme.of(context).modeChangeNotifier.value == AdaptiveThemeMode.dark;

  final S strings = S.of(context);

  return ValueListenableBuilder(
    valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
    builder: (context, mode, _) {
      final isDarkMode = mode == AdaptiveThemeMode.dark;
      return Scaffold(
        backgroundColor: theme.primaryColorDark,
        appBar: AppBar(
          title: Text(
            strings.createVideoTitle,   // localized
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [const Color(0xFF0a0a0a), const Color(0xFF1a1a1a)]
                  : [
                      const Color(0xFFF8F8F8),
                      const Color(0xFFEDEDED),
                    ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasVideo && !_showCamera)
                  _buildVideoPreview()
                else if (_showCamera)
                  _buildCameraView()
                else
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDarkMode ? Colors.white24 : Colors.black26,
                        width: 2,
                      ),
                      color: isDarkMode
                          ? const Color(0xFF1a1a1a)
                          : const Color(0xFFF5F5F5),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.videocam_outlined,
                            size: 80,
                            color: Colors.white38,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            strings.createDadaduVideo, // localized
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            strings.maximum20Seconds, // localized
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white60 : Colors.black45,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                if (!hasVideo || _showCamera) _buildActionButtons(),

                const SizedBox(height: 24),

                _buildIntentSelector(isDarkMode, theme: theme),

                const SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? const Color(0xFF1a1a1a) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _intentColors[_selectedIntent]!.withAlpha(80),
                    ),
                  ),
                  child: TextField(
                    controller: _captionController,
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontSize: 16),
                    maxLines: 4,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: strings.captionHint, // localized
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      counterStyle: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.black54),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),

                const SizedBox(height: 32),

                Container(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton.icon(
                    onPressed: isReadyToUpload ? _uploadVideo : null,
                    icon: const Icon(Icons.upload, size: 30),
                    label: _isUploading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            strings.publishVideoButton, // localized
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isReadyToUpload
                          ? Colors.green
                          : isDarkMode
                              ? Colors.grey[600]
                              : Colors.grey[300],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 10,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (!isReadyToUpload)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withAlpha(75),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hasVideo
                                ? strings.infoAddCaption // localized
                                : strings.infoSelectOrRecord, // localized
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ));
      },
    );
  }
    }