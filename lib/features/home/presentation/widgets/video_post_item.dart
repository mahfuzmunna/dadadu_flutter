// lib/features/home/presentation/widgets/video_post_item.dart

import 'package:flutter/material.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';

import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:video_player/video_player.dart';

class VideoPostItem extends StatefulWidget {
  final PostEntity post;
  final UserEntity? postUser;
  final bool isCurrentPage; // Indicates if this video is currently visible and should play

  const VideoPostItem({
    super.key,
    required this.post,
    this.postUser,
    required this.isCurrentPage,
  });

  @override
  State<VideoPostItem> createState() => _VideoPostItemState();
}

class _VideoPostItemState extends State<VideoPostItem> with SingleTickerProviderStateMixin {
  late CachedVideoPlayerPlus _videoController;
  Future<void>? _initializeVideoPlayerFuture; // Nullable to re-assign
  bool _showPlayPauseOverlay = false;
  bool _hasError = false; // Track video loading errors
  late AnimationController _fadeAnimationController;

  @override
  void initState() {
    super.initState();
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initializeAndPlayVideo();
  }

  // Helper method to initialize and potentially play the video
  void _initializeAndPlayVideo() {
    _hasError = false; // Reset error state
    _videoController = CachedVideoPlayerPlus.networkUrl(Uri.parse(widget.post.videoUrl));

    _initializeVideoPlayerFuture = _videoController.initialize().then((_) {
      _videoController.controller.setLooping(true);
      _videoController.controller.setVolume(1.0);
      if (widget.isCurrentPage) {
        _videoController.controller.play();
        _fadeAnimationController.forward(); // Fade in video once initialized
      }
      _videoController.controller.addListener(_videoListener); // Add listener for buffering
    }).catchError((error) {
      debugPrint('Error initializing video for ${widget.post.id}: $error');
      if (mounted) {
        setState(() {
          _hasError = true; // Set error state
        });
      }
    });
  }

  void _videoListener() {
    // Optional: You can add more detailed buffering indicators here
    // For example, if (_videoController.value.isBuffering) { /* show buffering */ }
    // setState(() {}); // No need to call setState for buffering unless UI changes
  }

  @override
  void didUpdateWidget(covariant VideoPostItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the video URL changes, dispose the old controller and initialize a new one
    if (widget.post.videoUrl != oldWidget.post.videoUrl) {
      _videoController.controller.removeListener(_videoListener); // Remove old listener
      _videoController.dispose();
      _fadeAnimationController.reset(); // Reset animation for new video
      _initializeAndPlayVideo();
    }
    // Control playback based on visibility (isCurrentPage)
    else if (widget.isCurrentPage != oldWidget.isCurrentPage) {
      if (widget.isCurrentPage) {
        _videoController.controller.play();
        _fadeAnimationController.forward(); // Fade in if coming into view
      } else {
        _videoController.controller.pause();
        _videoController.controller.seekTo(Duration.zero); // Reset to start
        _fadeAnimationController.reverse(); // Fade out if leaving view
      }
    }
  }

  @override
  void dispose() {
    _videoController.controller.removeListener(_videoListener);
    _videoController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController.controller.value.isInitialized) {
      setState(() {
        _showPlayPauseOverlay = true; // Show overlay on tap
        if (_videoController.controller.value.isPlaying) {
          _videoController.controller.pause();
        } else {
          _videoController.controller.play();
        }
      });

      // Hide the overlay after a short delay
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() {
            _showPlayPauseOverlay = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String username = widget.postUser?.username ??
        widget.postUser?.email?.split('@')[0] ??
        'Unknown User';

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (_hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, color: Colors.grey, size: 80),
                const SizedBox(height: 10),
                const Text(
                  'Failed to load video.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Please try again later.',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done && _videoController.controller.value.isInitialized) {
          return GestureDetector(
            onTap: _togglePlayPause,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video Player itself with fade animation
                Positioned.fill(
                  child: FadeTransition(
                    opacity: _fadeAnimationController,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.controller.value.size.width,
                        height: _videoController.controller.value.size.height,
                        child: VideoPlayer(_videoController.controller),
                      ),
                    ),
                  ),
                ),

                // Buffering Indicator
                if (_videoController.controller.value.isBuffering && !_videoController.controller.value.isPlaying)
                  Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                // Play/Pause Overlay Icon
                if (_showPlayPauseOverlay)
                  Center(
                    child: Icon(
                      _videoController.controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: Colors.white.withOpacity(0.7),
                      size: 80,
                    ),
                  ),

                // Gradient Overlay for text readability
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // User Info and Description (Bottom Left)
                Positioned(
                  bottom: 90, // Adjust this value based on your BottomNavigationBar height
                  left: 16,
                  right: 90, // Leave space for buttons on the right
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@$username',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black.withOpacity(0.6)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.post.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          shadows: [
                            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black.withOpacity(0.6)),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Action Buttons (Right Side)
                Positioned(
                  bottom: 90, // Align with text content
                  right: 16,
                  child: Column(
                    children: [
                      _buildActionButton(Icons.favorite, '${widget.post.likes}', () {
                        // TODO: Implement Like functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Like button tapped!')),
                        );
                      }),
                      const SizedBox(height: 16),
                      _buildActionButton(Icons.file_download, 'Download', () {
                        // TODO: Implement Download functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Download button tapped!')),
                        );
                      }),
                      const SizedBox(height: 16),
                      _buildActionButton(Icons.share, 'Share', () {
                        // TODO: Implement Share functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share button tapped!')),
                        );
                      }),
                      const SizedBox(height: 16),
                      _buildActionButton(Icons.comment, '${widget.post.comments}', () {
                        // TODO: Implement Comment functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Comment button tapped!')),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Show a placeholder or loading indicator while the video is loading
          return Container(
            color: Colors.black, // A solid black background as a placeholder
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white, size: 32),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}