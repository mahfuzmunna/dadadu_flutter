// lib/features/posts/presentation/pages/video_editor_page.dart

import 'dart:io';

import 'package:dadadu_app/features/posts/domain/entities/post_draft.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoEditorPage extends StatefulWidget {
  final String videoFilePath;
  final PostDraft? draft;

  const VideoEditorPage({super.key, required this.videoFilePath, this.draft});

  @override
  State<VideoEditorPage> createState() => _VideoEditorPageState();
}

class _VideoEditorPageState extends State<VideoEditorPage> {
  final Trimmer _trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  void dispose() {
    _trimmer.dispose();
    super.dispose();
  }

  Future<void> _loadVideo() async {
    final videoFile = File(widget.videoFilePath);
    await _trimmer.loadVideo(videoFile: videoFile);
    if (mounted) setState(() {});
  }

  Future<void> _saveVideo() async {
    if (mounted) setState(() => _isSaving = true);

    await _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (outputPath) {
        if (outputPath != null && mounted) {
          context.push('/createPost', extra: {
            'videoPath': outputPath,
            'draft': widget.draft ?? const PostDraft(),
          });
        }
      },
    );

    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen video preview
          Center(
            child: VideoViewer(trimmer: _trimmer),
          ),
          // UI Controls Overlay
          _buildControlsOverlay(),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Top Controls: Cancel and Next ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildControlButton(
                  icon: Icons.close_rounded,
                  onPressed: () => context.pop(),
                ),
                _isSaving
                    ? const SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3)),
                      )
                    : _buildControlButton(
                        icon: Icons.check_rounded,
                        onPressed: _saveVideo,
                      ),
              ],
            ),
            const Spacer(),
            // --- Bottom Controls: Trimmer and Play/Pause ---
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TrimViewer(
                  trimmer: _trimmer,
                  viewerHeight: 50.0,
                  viewerWidth: MediaQuery.of(context).size.width,
                  maxVideoLength: const Duration(seconds: 20),
                  onChangeStart: (value) => _startValue = value,
                  onChangeEnd: (value) => _endValue = value,
                  onChangePlaybackState: (value) =>
                      setState(() => _isPlaying = value),
                  editorProperties: TrimEditorProperties(
                    borderPaintColor: theme.colorScheme.primary,
                    circlePaintColor: theme.colorScheme.primary,
                    scrubberPaintColor: theme.colorScheme.secondary,
                  ),
                  areaProperties: TrimAreaProperties.edgeBlur(
                    thumbnailQuality: 75,
                  ),
                ),
                const SizedBox(height: 16),
                IconButton(
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                    size: 64.0,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                          color: Colors.black.withOpacity(0.5), blurRadius: 8)
                    ],
                  ),
                  onPressed: () async {
                    final playbackState = await _trimmer.videoPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() => _isPlaying = playbackState);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper for creating stylish, consistent circular buttons
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
}
