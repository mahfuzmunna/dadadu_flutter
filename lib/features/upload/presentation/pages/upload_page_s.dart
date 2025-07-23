// lib/features/upload/presentation/pages/upload_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class UploadPage extends StatefulWidget {
  final String videoPath;

  const UploadPage({
    super.key,
    required this.videoPath,
  });

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  late VideoPlayerController _videoPlayerController;
  File? _thumbnailFile;
  bool _isLoading = false;
  String _uploadStatus = '';

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeVideoAndThumbnail();
  }

  Future<void> _initializeVideoAndThumbnail() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
    await _generateThumbnail();
    setState(() {}); // Rebuild to show video and thumbnail
  }

  Future<void> _generateThumbnail() async {
    try {
      final String? thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: widget.videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200, // For a small, efficient thumbnail
        quality: 75,
      );
      if (thumbnailPath != null) {
        setState(() {
          _thumbnailFile = File(thumbnailPath);
        });
      }
    } catch (e) {
      debugPrint("Error generating thumbnail: $e");
      _showSnackBar('Could not generate a thumbnail for this video.');
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Future<void> _uploadPost() async {
    if (_isLoading) return;
    final currentUserId = _supabase.auth.currentUser?.id;

    if (currentUserId == null) {
      _showSnackBar('You must be logged in to upload.', isError: true);
      return;
    }
    if (_thumbnailFile == null) {
      _showSnackBar('Thumbnail is not ready yet. Please wait.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadStatus = 'Uploading video...';
    });

    try {
      final postId = _uuid.v4();
      final videoFile = File(widget.videoPath);
      final videoExt = videoFile.path.split('.').last;
      final videoPath = 'public/$currentUserId/$postId.$videoExt';

      // 1. Upload Video
      final videoUrl = await _uploadFile(videoPath, videoFile);
      setState(() => _uploadStatus = 'Uploading thumbnail...');

      // 2. Upload Thumbnail
      final thumbExt = _thumbnailFile!.path.split('.').last;
      final thumbPath = 'public/$currentUserId/$postId-thumb.$thumbExt';
      final thumbnailUrl = await _uploadFile(thumbPath, _thumbnailFile!);
      setState(() => _uploadStatus = 'Saving post details...');

      // 3. Insert Post into Database
      await _supabase.from('posts').insert({
        'id': postId,
        'user_id': currentUserId,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'description': _descriptionController.text.trim(),
        'tag': _tagController.text.trim().isEmpty
            ? 'Entertainment'
            : _tagController.text.trim(),
      });

      _showSnackBar('Upload successful!');
      if (mounted) context.go('/home');
    } catch (e) {
      debugPrint("Upload failed: $e");
      _showSnackBar('Upload failed. Please try again.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _uploadStatus = '';
        });
      }
    }
  }

  Future<String> _uploadFile(String path, File file) async {
    await _supabase.storage.from('videos').upload(
          path,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
    return _supabase.storage.from('videos').getPublicUrl(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _uploadPost,
            child: const Text('Upload'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(_uploadStatus,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    image: _thumbnailFile != null
                        ? DecorationImage(
                            image: FileImage(_thumbnailFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _thumbnailFile == null
                      ? const Center(child: CircularProgressIndicator())
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Describe your video...',
                          border: InputBorder.none,
                        ),
                        maxLines: 4,
                      ),
                      const Divider(),
                      TextField(
                        controller: _tagController,
                        decoration: const InputDecoration(
                          hintText: '#Tag (e.g. #Comedy)',
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Video Preview',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _videoPlayerController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
                  )
                : const Center(
                    child: Text('Initializing video preview...'),
                  ),
          ],
        ),
      ),
    );
  }
}