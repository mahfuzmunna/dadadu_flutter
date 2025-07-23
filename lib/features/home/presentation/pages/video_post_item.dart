// lib/features/home/presentation/widgets/video_post_item.dart

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/home/presentation/bloc/feed_bloc.dart'; // Import your PostBloc
import 'package:dadadu_app/features/home/presentation/bloc/post_bloc.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:video_player/video_player.dart';

class VideoPostItem extends StatefulWidget {
  final PostEntity post; // Renamed to initialPost
  final UserEntity? postUser;
  final bool isCurrentPage;
  final ValueChanged<String>? onUserTapped;

  const VideoPostItem({
    super.key,
    required this.post, // Use initialPost
    this.postUser,
    required this.isCurrentPage,
    this.onUserTapped,
  });

  @override
  State<VideoPostItem> createState() => _VideoPostItemState();
}

class _VideoPostItemState extends State<VideoPostItem>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  CachedVideoPlayerPlus? _videoController;
  Future<void>? _initializeVideoPlayerFuture;
  bool _showPlayPauseOverlay = false;
  bool _isVideoInitialized = false;
  bool _hasError = false;
  late AnimationController _fadeAnimationController;

  // Current post state (will be updated by BlocBuilder)
  PostEntity _currentPost = PostEntity(
    id: '',
    // Dummy initial values, will be overridden
    userId: '',
    videoUrl: '',
    description: '',
    thumbnailUrl: '',
    diamonds: 0,
    comments: 0,
    location: '',
    tag: '',
    isDisabled: false,
    visibilityLevel: 0,
    views: 0,
    createdAt:
        DateTime.now().toIso8601String(), // Placeholder or provide a default
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _currentPost = widget.post; // Initialize with the initial post

    debugPrint(
        'VideoPostItem ${widget.post.id} initState. isCurrentPage: ${widget.isCurrentPage}');

    // Initialize video only if it's the current page initially
    if (widget.isCurrentPage) {
      _initializeAndPlayVideo();
    }
  }

  void _initializeAndPlayVideo() {
    debugPrint(
        'VideoPostItem ${_currentPost.id} _initializeAndPlayVideo called.');

    // If a controller already exists and is for the same video, don't re-initialize
    if (_videoController != null &&
        _videoController!.dataSource == _currentPost.videoUrl) {
      debugPrint(
          'VideoPostItem ${_currentPost.id} Controller already exists and matches. Skipping re-init.');
      // Ensure it's playing if it's the current page and already initialized
      if (widget.isCurrentPage &&
          _videoController!.controller.value.isInitialized &&
          !_videoController!.controller.value.isPlaying) {
        debugPrint(
            'VideoPostItem ${_currentPost.id} Already initialized, now current, playing.');
        _videoController!.controller.play();
        _fadeAnimationController.forward();
      }
      return;
    }

    // Dispose of the old controller if it exists (for different video or if re-init is needed)
    if (_videoController != null) {
      debugPrint('VideoPostItem ${_currentPost.id} Disposing old controller.');
      if (_videoController!.controller.value.isInitialized) {
        _videoController!.controller.removeListener(_videoListener);
        _videoController!.dispose();
      }
      _videoController = null; // Clear reference
    }

    _hasError = false; // Reset error state

    // Create a new controller
    _videoController =
        CachedVideoPlayerPlus.networkUrl(Uri.parse(_currentPost.videoUrl));
    debugPrint(
        'VideoPostItem ${_currentPost.id} Initializing new video: ${_currentPost.videoUrl}');

    // Store the initialization future
    _initializeVideoPlayerFuture = _videoController!.initialize().then((_) {
      // Ensure widget is still mounted and controller is not null before proceeding
      if (!mounted || _videoController == null) {
        debugPrint(
            'VideoPostItem ${_currentPost.id} Initialization finished, but widget not mounted or controller is null.');
        return;
      }

      // Check if the controller is indeed initialized before setting properties
      if (_videoController!.controller.value.isInitialized) {
        debugPrint(
            'VideoPostItem ${_currentPost.id} Controller initialized successfully.');
        _videoController!.controller.setLooping(true);
        _videoController!.controller.setVolume(1.0);
        _videoController!.controller.addListener(_videoListener);

        setState(() {
          _isVideoInitialized = true;
          _hasError = false;
        });

        if (widget.isCurrentPage) {
          debugPrint(
              'VideoPostItem ${_currentPost.id} isCurrentPage is true, playing video.');
          _videoController!.controller.play();
          _fadeAnimationController.forward();
        } else {
          debugPrint(
              'VideoPostItem ${_currentPost.id} isCurrentPage is false, not playing video.');
        }
      } else {
        debugPrint(
            'VideoPostItem ${_currentPost.id} CachedVideoPlayerPlus failed to initialize value.');
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
          'VideoPostItem ${_currentPost.id} Error caught during initialization: $error');
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
    // Only call setState if you need UI updates based on video state (e.g., buffering).
    // Avoid excessive setState calls here for performance.
  }

  @override
  void didUpdateWidget(covariant VideoPostItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint(
        'VideoPostItem ${_currentPost.id} didUpdateWidget. oldCurrent: ${oldWidget.isCurrentPage}, newCurrent: ${widget.isCurrentPage}');

    // Scenario 1: Video URL changes (different post)
    if (widget.post.videoUrl != oldWidget.post.videoUrl) {
      debugPrint(
          'VideoPostItem ${_currentPost.id} Video URL changed. Re-initializing.');
      _currentPost = widget.post; // Update current post reference
      _fadeAnimationController.reset();
      // Dispose old controller BEFORE initializing new one when URL changes
      if (_videoController != null) {
        if (_videoController!.controller.value.isInitialized) {
          _videoController!.controller.removeListener(_videoListener);
        }
        _videoController!.dispose();
        _videoController = null; // Clear reference
      }
      _initializeAndPlayVideo();
    }
    // Scenario 2: Current page status changes (same post, but visibility changed)
    else if (widget.isCurrentPage != oldWidget.isCurrentPage) {
      if (widget.isCurrentPage) {
        debugPrint('VideoPostItem ${_currentPost.id} BECAME current page.');
        // If it becomes the current page, and controller is ready, play.
        // If not ready, attempt to initialize it.
        if (_videoController != null &&
            _videoController!.controller.value.isInitialized) {
          debugPrint(
              'VideoPostItem ${_currentPost.id} Controller initialized, playing.');
          _videoController!.controller.play();
          _fadeAnimationController.forward();
        } else {
          debugPrint(
              'VideoPostItem ${_currentPost.id} Controller not initialized, attempting init and play.');
          _initializeAndPlayVideo(); // Attempt to initialize and play
        }
      } else {
        debugPrint(
            'VideoPostItem ${_currentPost.id} NO LONGER current page. Attempting to pause.');
        // No longer current page: pause and seek to zero
        if (_videoController != null &&
            _videoController!.controller.value.isInitialized) {
          debugPrint(
              'VideoPostItem ${_currentPost.id} Controller initialized, pausing and seeking to zero.');
          _videoController!.controller.pause();
          _videoController!.controller.seekTo(Duration.zero);
          _fadeAnimationController.reverse();
          debugPrint(
              'VideoPostItem ${_currentPost.id} After pause: isPlaying = ${_videoController!.controller.value.isPlaying}');
        } else {
          debugPrint(
              'VideoPostItem ${_currentPost.id} Controller not initialized, nothing to pause.');
        }
        // Consider disposing controller if you want to free resources for distant pages
        // if (_videoController != null) {
        //   _videoController!.controller.removeListener(_videoListener);
        //   _videoController!.dispose();
        //   _videoController = null;
        //   _initializeVideoPlayerFuture = null;
        //   debugPrint('VideoPostItem ${widget.initialPost.id} Controller disposed as no longer current.');
        // }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint(
        'VideoPostItem ${_currentPost.id} didChangeAppLifecycleState: $state');
    // Only control if controller exists and is initialized
    if (_videoController == null ||
        !_videoController!.controller.value.isInitialized) return;

    if (state == AppLifecycleState.paused) {
      debugPrint('VideoPostItem ${_currentPost.id} App paused. Pausing video.');
      _videoController!.controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (widget.isCurrentPage) {
        debugPrint(
            'VideoPostItem ${_currentPost.id} App resumed and current. Playing video.');
        _videoController!.controller.play();
      }
    }
  }

  @override
  void dispose() {
    debugPrint('VideoPostItem ${_currentPost.id} dispose called.');
    // Safely remove listener and dispose controller
    if (_videoController != null) {
      if (_videoController!.controller.value.isInitialized) {
        _videoController!.controller.removeListener(_videoListener);
      }
      _videoController!.dispose();
      _videoController = null; // Clear reference
    }
    _fadeAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _togglePlayPause() {
    debugPrint('VideoPostItem ${_currentPost.id} _togglePlayPause tapped.');
    // Only toggle if controller exists and is initialized
    if (_videoController != null &&
        _videoController!.controller.value.isInitialized) {
      setState(() {
        _showPlayPauseOverlay = true;
        if (_videoController!.controller.value.isPlaying) {
          _videoController!.controller.pause();
          debugPrint('VideoPostItem ${_currentPost.id} Manual pause.');
        } else {
          _videoController!.controller.play();
          debugPrint('VideoPostItem ${_currentPost.id} Manual play.');
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
          'VideoPostItem ${_currentPost.id} Tapped uninitialized video. Attempting to initialize.');
      _initializeAndPlayVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder to listen for PostState changes
    return BlocBuilder<PostBloc, PostState>(
      // Build only if the state is for THIS post
      buildWhen: (previous, current) {
        if (current is PostLoaded) {
          return current.post?.id == widget.post.id;
        }
        return false; // Don't rebuild for other posts' states or non-loaded states
      },
      builder: (context, state) {
        // Update _currentPost if the state indicates a change for this specific post
        if (state is PostLoaded) {
          _currentPost = state.post!;
          debugPrint(
              'VideoPostItem ${_currentPost.id} received PostLoaded state.');
        } else if (state is FeedLoading &&
            state.props.contains(widget.post.id)) {
          // Optionally show a loading indicator just for the Post's data, not the video
          debugPrint(
              'VideoPostItem ${_currentPost.id} received PostLoading state.');
        } else if (state is FeedError && state.props.contains(widget.post.id)) {
          // Handle error for post data specifically, maybe a small error icon
          debugPrint(
              'VideoPostItem ${_currentPost.id} received PostError state: ${state.message}');
        }

        final String username = widget.postUser?.username ??
            widget.postUser?.email?.split('@')[0] ??
            'Unknown User';

        return FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (_hasError) {
              debugPrint(
                  'VideoPostItem ${_currentPost.id} Building with error state.');
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
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Please try again later.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
              debugPrint(
                  'VideoPostItem ${_currentPost.id} Building video player.');
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
                            width:
                                _videoController!.controller.value.size.width,
                            height:
                                _videoController!.controller.value.size.height,
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
                                // Assuming UserEntity has a 'uid' field
                                widget.onUserTapped!(widget.postUser!.id);
                              } else {
                                // Optional: provide feedback if tap can't be handled
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('User profile unavailable.')),
                                );
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // User Profile Avatar
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  backgroundImage:
                                      (widget.postUser?.profilePhotoUrl != null)
                                          ? NetworkImage(widget
                                                  .postUser!.profilePhotoUrl ??
                                              '')
                                          : null,
                                  child:
                                      (widget.postUser?.profilePhotoUrl == null)
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
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
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
                              _currentPost.description, // Use _currentPost
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
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
                          _buildActionButton(
                              Icons.favorite, '${_currentPost.diamonds}', () {
                            // Use _currentPost.diamonds
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Like button tapped!')),
                            );
                            // TODO: Dispatch an event to increment diamonds (e.g., context.read<PostBloc>().add(IncrementDiamonds(_currentPost.id)))
                          }),
                          const SizedBox(height: 16),
                          _buildActionButton(Icons.file_download, 'Download',
                              () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Download button tapped!')),
                            );
                          }),
                          const SizedBox(height: 16),
                          _buildActionButton(Icons.share, 'Share', () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Share button tapped!')),
                            );
                          }),
                          const SizedBox(height: 16),
                          _buildActionButton(
                              Icons.comment, '${_currentPost.comments}', () {
                            // Use _currentPost.comments
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Comment button tapped!')),
                            );
                            // TODO: Dispatch an event to open comments or increment count
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              debugPrint(
                  'VideoPostItem ${_currentPost.id} Building loading/placeholder.');
              // Show a loading indicator while video is not ready
              return Container(
                color: Colors.black, // Dark background while loading
                child: Center(
                  child: (state is FeedLoading ||
                          _videoController != null ||
                          widget.isCurrentPage)
                      ? CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary)
                      : const SizedBox
                          .shrink(), // Don't show progress for off-screen videos that aren't initializing
                ),
              );
            }
          },
        );
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
