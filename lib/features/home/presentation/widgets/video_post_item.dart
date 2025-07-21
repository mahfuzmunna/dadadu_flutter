// lib/features/home/presentation/widgets/video_post_item.dart

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
// Ensure these imports point to your actual entity files
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
// import 'package:video_player/video_player.dart'; // This import is no longer needed as CachedVideoPlayerPlus wraps it.

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

class _VideoPostItemState extends State<VideoPostItem>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late CachedVideoPlayerPlus _videoController;
  Future<void>? _initializeVideoPlayerFuture;
  bool _showPlayPauseOverlay = false;
  bool _hasError = false;
  late AnimationController _fadeAnimationController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initializeAndPlayVideo();
  }

  void _initializeAndPlayVideo() {
    _hasError = false;
    _videoController = CachedVideoPlayerPlus.networkUrl(Uri.parse(widget.post.videoUrl));

    _initializeVideoPlayerFuture = _videoController.initialize().then((_) {
      _videoController.controller.setLooping(true);
      _videoController.controller.setVolume(1.0);
      if (widget.isCurrentPage) {
        _videoController.controller.play();
        _fadeAnimationController.forward();
      }
      _videoController.controller.addListener(_videoListener);
    }).catchError((error) {
      debugPrint('Error initializing video for ${widget.post.id}: $error');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    });
  }

  void _videoListener() {
    // Optional: You can add more detailed buffering indicators here
  }

  @override
  void didUpdateWidget(covariant VideoPostItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.post.videoUrl != oldWidget.post.videoUrl) {
      _videoController.controller.removeListener(_videoListener);
      _videoController.dispose();
      _fadeAnimationController.reset();
      _initializeAndPlayVideo();
    } else if (widget.isCurrentPage != oldWidget.isCurrentPage) {
      if (_videoController.controller.value.isInitialized) {
        if (widget.isCurrentPage) {
          _videoController.controller.play();
          _fadeAnimationController.forward();
        } else {
          _videoController.controller.pause();
          _videoController.controller.seekTo(Duration.zero);
          _fadeAnimationController.reverse();
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_videoController.controller.value.isInitialized) return;

    if (state == AppLifecycleState.paused) {
      _videoController.controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (widget.isCurrentPage) {
        _videoController.controller.play();
      }
    }
  }

  @override
  void dispose() {
    _videoController.controller.removeListener(_videoListener);
    _videoController.dispose();
    _fadeAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController.controller.value.isInitialized) {
      setState(() {
        _showPlayPauseOverlay = true;
        if (_videoController.controller.value.isPlaying) {
          _videoController.controller.pause();
        } else {
          _videoController.controller.play();
        }
      });

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
                Icon(Icons.broken_image,
                    color: Theme.of(context).colorScheme.error, size: 80),
                const SizedBox(height: 10),
                Text(
                  'Failed to load video.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Please try again later.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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
                  bottom: 90,
                  left: 16,
                  right: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // User Profile Avatar - CORRECTED HERE
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            backgroundImage: widget.postUser?.profilePhotoUrl !=
                                        null &&
                                    (widget.postUser?.profilePhotoUrl) != null
                                ? NetworkImage(
                                    widget.postUser?.profilePhotoUrl ?? '')
                                : null,
                            child: (widget.postUser?.profilePhotoUrl == null ||
                                    (widget.postUser!.profilePhotoUrl) == null)
                                ? Icon(Icons.person,
                                    color: Colors.white, size: 20)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          // Username (without '@')
                          Text(
                            username,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                    color: Colors.black.withOpacity(0.6)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Follow Button
                          FilledButton.tonal(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Follow functionality coming soon!')),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary,
                              minimumSize: Size(0, 28),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Follow',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          widget.post.description,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            shadows: [
                              Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black.withOpacity(0.6)),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons (Right Side)
                Positioned(
                  bottom: 90,
                  right: 16,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionButton(Icons.favorite, '${widget.post.likes}', () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Like button tapped!')),
                        );
                      }),
                      const SizedBox(height: 16),
                      _buildActionButton(Icons.file_download, 'Download', () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Download button tapped!')),
                        );
                      }),
                      const SizedBox(height: 16),
                      _buildActionButton(Icons.share, 'Share', () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share button tapped!')),
                        );
                      }),
                      const SizedBox(height: 16),
                      _buildActionButton(Icons.comment, '${widget.post.comments}', () {
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
          return Container(
            color: Colors.black,
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
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 1,
                  color: Colors.black.withOpacity(0.5)),
            ],
          ),
        ),
      ],
    );
  }
}