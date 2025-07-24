// lib/features/now/presentation/widgets/video_post_item.dart

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/now/presentation/bloc/post_bloc.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class VideoPostItem extends StatefulWidget {
  final bool isCurrentPage;
  final Function(String userId) onUserTapped;

  const VideoPostItem({
    super.key,
    required this.isCurrentPage,
    required this.onUserTapped,
  });

  @override
  State<VideoPostItem> createState() => _VideoPostItemState();
}

class _VideoPostItemState extends State<VideoPostItem>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  CachedVideoPlayerPlus? _videoController;
  Future<void>? _initializeVideoPlayerFuture;
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
  }

  // This method now takes the PostEntity to initialize the correct video
  void _initializeVideo(PostEntity post) {
    // If controller exists and is for the same video, do nothing.
    if (_videoController != null &&
        _videoController!.dataSource == post.videoUrl) {
      // If it became the current page, ensure it plays
      if (widget.isCurrentPage &&
          !_videoController!.controller.value.isPlaying) {
        _videoController!.controller.play();
        _fadeAnimationController.forward();
      }
      return;
    }

    // Dispose old controller if it exists
    _videoController?.dispose();

    _hasError = false;
    _videoController =
        CachedVideoPlayerPlus.networkUrl(Uri.parse(post.videoUrl));

    _initializeVideoPlayerFuture =
        _videoController!.controller.initialize().then((_) {
      if (!mounted || _videoController == null) return;

      if (_videoController!.controller.value.isInitialized) {
        _videoController!.controller.setLooping(true);
        _videoController!.controller.setVolume(1.0);
        if (widget.isCurrentPage) {
          _videoController!.controller.play();
          _fadeAnimationController.forward();
        }
      } else {
        if (mounted) setState(() => _hasError = true);
      }
    }).catchError((error) {
      if (mounted) setState(() => _hasError = true);
    });

    // Trigger a rebuild to show the FutureBuilder for the new future
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant VideoPostItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This logic now only handles playing/pausing based on page visibility.
    // Initialization is handled by the BlocBuilder.
    if (widget.isCurrentPage != oldWidget.isCurrentPage) {
      if (widget.isCurrentPage) {
        if (_videoController != null &&
            _videoController!.controller.value.isInitialized) {
          _videoController!.controller.play();
          _fadeAnimationController.forward();
        }
      } else {
        if (_videoController != null &&
            _videoController!.controller.value.isInitialized) {
          _videoController!.controller.pause();
          _fadeAnimationController.reverse();
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_videoController == null ||
        !_videoController!.controller.value.isInitialized) return;
    if (state == AppLifecycleState.paused) {
      _videoController!.controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (widget.isCurrentPage) {
        _videoController!.controller.play();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoController?.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        // Handle Loading and Initial States
        if (state is PostLoading || state is PostInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle Error State
        if (state is PostError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Could not load post: ${state.message}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Handle Loaded State
        if (state is PostLoaded) {
          final post = state.post;
          final author = state.author;

          // Crucial: Initialize the video player when we have the post data.
          _initializeVideo(post!);

          return FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (_hasError) {
                return const Center(
                    child:
                        Icon(Icons.error_outline, color: Colors.red, size: 48));
              }

              final isPlayerReady = _videoController != null &&
                  snapshot.connectionState == ConnectionState.done &&
                  _videoController!.controller.value.isInitialized;

              if (isPlayerReady) {
                return GestureDetector(
                  onTap: () {
                    if (_videoController!.controller.value.isPlaying) {
                      _videoController!.controller.pause();
                    } else {
                      _videoController!.controller.play();
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: FadeTransition(
                          opacity: _fadeAnimationController,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width:
                                  _videoController!.controller.value.size.width,
                              height: _videoController!
                                  .controller.value.size.height,
                              child: VideoPlayer(_videoController!.controller),
                            ),
                          ),
                        ),
                      ),
                      _buildGradientOverlay(),
                      _buildPostInfo(post!, author),
                      _buildActionButtons(context, post),
                    ],
                  ),
                );
              } else {
                return Container(
                  color: Colors.black,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.5),
            ],
            stops: const [0.5, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildPostInfo(PostEntity post, UserEntity? author) {
    return Positioned(
      bottom: 20,
      left: 15,
      right: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AuthorInfo(author: author, onUserTapped: widget.onUserTapped),
          const SizedBox(height: 8),
          Text(
            post.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white,
                shadows: [Shadow(blurRadius: 4.0, color: Colors.black)]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, PostEntity post) {
    return Positioned(
      bottom: 20,
      right: 10,
      child: Column(
        children: [
          // The 'Like' button now dispatches an event to the PostBloc
          _buildActionButton(Icons.diamond, post.diamonds.toString(), () {
            context.read<PostBloc>().add(IncrementLike(post.id));
          }),
          const SizedBox(height: 16),
          _buildActionButton(Icons.comment, post.comments.toString(), () {}),
          const SizedBox(height: 16),
          _buildActionButton(Icons.share, 'Share', () {}),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white, size: 30),
          onPressed: onPressed,
        ),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

// This sub-widget remains the same and is a great pattern.
class _AuthorInfo extends StatelessWidget {
  final UserEntity? author;
  final Function(String userId) onUserTapped;

  const _AuthorInfo({required this.author, required this.onUserTapped});

  @override
  Widget build(BuildContext context) {
    if (author == null) {
      return const Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: Colors.grey),
          SizedBox(width: 8),
          Text('loading...', style: TextStyle(color: Colors.white70)),
        ],
      );
    }

    return GestureDetector(
      onTap: () => onUserTapped(author!.id),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: author!.profilePhotoUrl != null &&
                    author!.profilePhotoUrl!.isNotEmpty
                ? NetworkImage(author!.profilePhotoUrl!)
                : null,
            child: author!.profilePhotoUrl == null ||
                    author!.profilePhotoUrl!.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            author!.username as String,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              shadows: [Shadow(blurRadius: 4.0, color: Colors.black)],
            ),
          ),
        ],
      ),
    );
  }
}