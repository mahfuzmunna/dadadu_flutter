import 'package:chewie/chewie.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart'; // Ensure correct path
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPostItem extends StatefulWidget {
  final PostEntity post;

  const VideoPostItem({super.key, required this.post});

  @override
  State<VideoPostItem> createState() => _VideoPostItemState();
}

class _VideoPostItemState extends State<VideoPostItem> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.post.videoUrl));
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        // Or true, depending on your app's UX
        looping: true,
        allowFullScreen: true,
        // Optional: Custom controls, placeholder, etc.
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Failed to load video: $errorMessage',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint(
          'Error initializing video player: ${widget.post.videoUrl} - $e');
      // Optionally set an error state or show a placeholder
      _chewieController = null; // Indicate an error state
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    } else {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off, color: Colors.grey, size: 50),
              SizedBox(height: 10),
              Text('Video not available or failed to load.',
                  style: TextStyle(color: Colors.grey)),
              Text('URL: ${widget.post.videoUrl}',
                  style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),
      );
    }
  }
}
