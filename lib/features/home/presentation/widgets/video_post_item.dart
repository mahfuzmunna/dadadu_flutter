// lib/features/home/presentation/widgets/video_post_item.dart

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // Still needed for the VideoPlayer widget itself

class VideoPostItem extends StatefulWidget {
  final PostEntity post;
  final UserEntity? postUser;
  final bool
      isCurrentPage; // Indicates if this video is currently visible and should play
  final ValueChanged<String>? onUserTapped; // NEW: Callback for user tap

  const VideoPostItem({
    super.key,
    required this.post,
    this.postUser,
    required this.isCurrentPage,
    this.onUserTapped, // Add to constructor
  });

  @override
  State<VideoPostItem> createState() => _VideoPostItemState();
}

class _VideoPostItemState extends State<VideoPostItem>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  CachedVideoPlayerPlus? _videoController; // Made nullable
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

    // Initialize video only if it's the current page initially
    // Or if the post data indicates it should be auto-played/initialized
    if (widget.isCurrentPage) {
      _initializeAndPlayVideo();
    }
  }

  void _initializeAndPlayVideo() {
    // If a controller already exists and is for the same video, don't re-initialize
    if (_videoController != null &&
        _videoController!.dataSource == widget.post.videoUrl) {
      debugPrint(
          'Controller already exists and matches for ${widget.post.id}. Skipping re-init.');
      return;
    }

    // Dispose of the old controller if it exists and is for a different video
    if (_videoController != null) {
      debugPrint('Disposing old controller for ${widget.post.id}.');
      _videoController!.controller
          .removeListener(_videoListener); // Remove listener first
      _videoController!.dispose();
      _videoController = null; // Clear reference
    }

    _hasError = false; // Reset error state

    // Create a new controller
    _videoController =
        CachedVideoPlayerPlus.networkUrl(Uri.parse(widget.post.videoUrl));
    debugPrint(
        'Initializing video for ${widget.post.id}: ${widget.post.videoUrl}');

    // Store the initialization future
    _initializeVideoPlayerFuture = _videoController!.initialize().then((_) {
      // Ensure widget is still mounted and controller is not null before proceeding
      if (!mounted || _videoController == null) return;

      // Check if the controller is indeed initialized before setting properties
      if (_videoController!.controller.value.isInitialized) {
        _videoController!.controller.setLooping(true);
        _videoController!.controller.setVolume(1.0);
        _videoController!.controller.addListener(_videoListener);

        if (widget.isCurrentPage) {
          _videoController!.controller.play();
          _fadeAnimationController.forward();
        }
      } else {
        // This case should ideally be caught by catchError, but good for robustness
        debugPrint(
            'CachedVideoPlayerPlus failed to initialize value for ${widget.post.id}');
        if (mounted) {
          setState(() {
            _hasError = true;
            _videoController?.dispose();
            _videoController = null;
          });
        }
      }
    }).catchError((error) {
      debugPrint(
          'Error caught initializing video for ${widget.post.id}: $error');
      if (mounted) {
        setState(() {
          _hasError = true;
          _videoController?.dispose(); // Dispose on error
          _videoController = null; // Clear reference
        });
      }
    });

    // Set state to trigger FutureBuilder update
    if (mounted) {
      setState(() {});
    }
  }

  void _videoListener() {
    // Only call setState if there's a specific UI update dependent on the controller state (e.g., buffering indicator)
    // Avoid excessive setState calls within listeners if not strictly necessary for performance.
    // For buffering, you might only need to set state when isBuffering changes.
    // if (mounted && _videoController!.controller.value.isBuffering != _isBuffering) {
    //   setState(() {
    //     _isBuffering = _videoController!.controller.value.isBuffering;
    //   });
    // }
  }

  @override
  void didUpdateWidget(covariant VideoPostItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Scenario 1: Video URL changes (different post)
    if (widget.post.videoUrl != oldWidget.post.videoUrl) {
      debugPrint('Video URL changed for ${widget.post.id}. Re-initializing.');
      _fadeAnimationController.reset();
      _initializeAndPlayVideo();
    }
    // Scenario 2: Current page status changes (same post, but visibility changed)
    else if (widget.isCurrentPage != oldWidget.isCurrentPage) {
      if (widget.isCurrentPage) {
        // If it becomes the current page, and controller is ready, play.
        // If not ready, attempt to initialize it.
        if (_videoController != null &&
            _videoController!.controller.value.isInitialized) {
          debugPrint('Now current page for ${widget.post.id}. Playing.');
          _videoController!.controller.play();
          _fadeAnimationController.forward();
        } else {
          debugPrint(
              'Becoming current page for ${widget.post.id}, but not initialized. Attempting init.');
          _initializeAndPlayVideo();
        }
      } else {
        // No longer current page: pause and seek to zero
        if (_videoController != null &&
            _videoController!.controller.value.isInitialized) {
          debugPrint(
              'No longer current page for ${widget.post.id}. Pausing and seeking to zero.');
          _videoController!.controller.pause();
          _videoController!.controller.seekTo(Duration.zero);
          _fadeAnimationController.reverse();
        }
        // Optionally, if the video is far off-screen, you might want to dispose of its controller
        // to free up resources. This depends on your PageView's `viewportFraction` and `cacheExtent`.
        // For simplicity, we're keeping it initialized but paused.
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only control if controller exists and is initialized
    if (_videoController == null ||
        !_videoController!.controller.value.isInitialized) return;

    if (state == AppLifecycleState.paused) {
      debugPrint('App paused. Pausing video for ${widget.post.id}.');
      _videoController!.controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (widget.isCurrentPage) {
        debugPrint(
            'App resumed and current page for ${widget.post.id}. Playing video.');
        _videoController!.controller.play();
      }
    }
  }

  @override
  void dispose() {
    debugPrint('Disposing VideoPostItem for ${widget.post.id}');
    // Safely remove listener and dispose controller
    if (_videoController != null) {
      // Check if controller value is initialized before removing listener
      // This prevents errors if dispose is called before initialize finishes
      if (_videoController!.controller.value.isInitialized) {
        _videoController!.controller.removeListener(_videoListener);
      }
      _videoController!.dispose();
    }
    _fadeAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _togglePlayPause() {
    // Only toggle if controller exists and is initialized
    if (_videoController != null &&
        _videoController!.controller.value.isInitialized) {
      setState(() {
        _showPlayPauseOverlay = true;
        if (_videoController!.controller.value.isPlaying) {
          _videoController!.controller.pause();
        } else {
          _videoController!.controller.play();
        }
      });

      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() {
            _showPlayPauseOverlay = false;
          });
        }
      });
    } else {
      // If tapped and not initialized, try to initialize it
      debugPrint(
          'Tapped uninitialized video for ${widget.post.id}. Attempting to initialize.');
      _initializeAndPlayVideo();
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
        }
        // Crucial Check: Ensure _videoController is not null and it's initialized
        else if (_videoController != null &&
            snapshot.connectionState == ConnectionState.done &&
            _videoController!.controller.value.isInitialized) {
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
                        // We are now confident _videoController is not null here
                        width: _videoController!.controller.value.size.width,
                        height: _videoController!.controller.value.size.height,
                        child: VideoPlayer(_videoController!.controller),
                      ),
                    ),
                  ),
                ),

                // Buffering Indicator
                if (_videoController!.controller.value.isBuffering &&
                    !_videoController!.controller.value.isPlaying)
                  Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                // Play/Pause Overlay Icon
                if (_showPlayPauseOverlay)
                  Center(
                    child: Icon(
                      _videoController!.controller.value.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
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
                      // Wrap the Row with GestureDetector for username tap
                      GestureDetector(
                        onTap: () {
                          // Invoke the callback if provided and user data exists
                          if (widget.onUserTapped != null &&
                              widget.postUser != null) {
                            widget.onUserTapped!(
                                widget.postUser!.uid); // Pass the user ID
                          } else {
                            // Optional: provide feedback if tap can't be handled
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('User profile unavailable.')),
                            );
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // User Profile Avatar
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              backgroundImage: (widget
                                          .postUser?.profilePhotoUrl !=
                                      null)
                                  ? NetworkImage(widget
                                          .postUser?.profilePhotoUrl ??
                                      '') // It was already like this in your code, but the problem is the type is still String?
                                  : null,
                              child: (widget.postUser?.profilePhotoUrl == null)
                                  ? const Icon(Icons.person,
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
                                minimumSize: const Size(0, 28),
                                padding: const EdgeInsets.symmetric(
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
                      _buildActionButton(Icons.favorite, '${widget.post.likes}',
                          () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Like button tapped!')),
                        );
                      }),
                      const SizedBox(height: 16),
                      _buildActionButton(Icons.file_download, 'Download', () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Download button tapped!')),
                        );
                      }),
                      const SizedBox(height: 16),
                      _buildActionButton(Icons.share, 'Share', () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share button tapped!')),
                        );
                      }),
                      const SizedBox(height: 16),
                      _buildActionButton(
                          Icons.comment, '${widget.post.comments}', () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Comment button tapped!')),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Show a loading indicator while video is not ready
          // Only show progress for the current page, or if initialization has started
          return Container(
            color: Colors.black, // Dark background while loading
            child: Center(
              child: (_videoController != null || widget.isCurrentPage)
                  ? CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary)
                  : const SizedBox
                      .shrink(), // Don't show progress for off-screen videos that aren't initializing
            ),
          );
        }
      },
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
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
