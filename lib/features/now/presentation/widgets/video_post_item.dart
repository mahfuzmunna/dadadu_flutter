// lib/features/now/presentation/widgets/video_post_item.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/now/presentation/bloc/post_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../upload/domain/entities/post_entity.dart';

class VideoPostItem extends StatefulWidget {
  final PostEntity post;
  final VideoPlayerController? controller;
  final bool isCurrentPage;
  final Function(String userId) onUserTapped;

  const VideoPostItem({
    super.key,
    required this.post,
    required this.controller,
    required this.isCurrentPage,
    required this.onUserTapped,
  });

  @override
  State<VideoPostItem> createState() => _VideoPostItemState();
}

class _VideoPostItemState extends State<VideoPostItem>
    with WidgetsBindingObserver {
  CachedVideoPlayerPlus? _player;
  Future<void>? _initializeVideoPlayerFuture;
  bool _hasError = false;
  late GoRouter _router;
  bool _isNowPageActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();

    _router = Provider.of<GoRouter>(context, listen: false);
    _router.routerDelegate.addListener(_handleRouteChange);
  }

  void _handleRouteChange() {
    // Get the current top-level route
    final String topRoute =
        _router.routerDelegate.currentConfiguration.fullPath ?? '';
    final bool isActive = (topRoute == '/home');

    if (_isNowPageActive != isActive) {
      setState(() {
        _isNowPageActive = isActive;
      });
      // If the page is no longer active, pause the video
      if (!isActive) {
        _player?.controller.pause();
      } else {
        // If the page becomes active again, play the video if it's the current one
        if (widget.isCurrentPage) {
          _player?.controller.play();
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant VideoPostItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentPage != oldWidget.isCurrentPage) {
      if (widget.isCurrentPage && _isNowPageActive) {
        _player?.controller.play();
      } else {
        _player?.controller.pause();
      }
    }
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (_player == null || !_player!.controller.value.isInitialized) return;
  //   if (state == AppLifecycleState.paused) {
  //     _player!.controller.pause();
  //   } else if (state == AppLifecycleState.resumed) {
  //     if (widget.isCurrentPage && widget.isPageActive) {
  //       _player!.controller.play();
  //     }
  //   }
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted ||
        _player?.controller == null ||
        !_player!.controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.paused) {
      _player!.controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      // Only resume playing if it's the current video on the active page
      if (widget.isCurrentPage && _isNowPageActive) {
        _player!.controller.play();
      } else {
        _player!.controller.pause();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.routerDelegate.removeListener(_handleRouteChange);
    _player?.controller.dispose();
    super.dispose();
  }

  void _initializeVideo() {
    if (_player?.controller != null) return;

    _player = CachedVideoPlayerPlus.networkUrl(Uri.parse(widget.post.videoUrl));
    _initializeVideoPlayerFuture = _player!.initialize().then((_) {
      if (!mounted) return;
      if (_player!.isInitialized) {
        _player!.controller.setLooping(true);
        if (widget.isCurrentPage && _isNowPageActive) {
          _player!.controller.play();
        }
      } else {
        if (mounted) setState(() => _hasError = true);
      }
      if (mounted) setState(() {});
    }).catchError((error) {
      if (mounted) setState(() => _hasError = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(top: statusBarHeight * 0.275),
      child: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          // The UI is built using the most up-to-date data.
          // It starts with the initialPost and updates live when PostLoaded arrives.
          final postToDisplay =
              (state is PostLoaded) ? state.post : widget.post;
          final author = (state is PostLoaded) ? state.author : null;

          return GestureDetector(
            onTap: () {
              if (_player?.isInitialized ?? false) {
                _player!.controller.value.isPlaying
                    ? _player!.controller.pause()
                    : _player!.controller.play();
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video Player Background
                _buildVideoPlayer(),
                // Gradient Overlay for text readability
                _buildGradientOverlay(),
                // UI Elements (Author, Caption, Actions)
                _buildPostOverlay(context, postToDisplay!, author),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (_hasError) {
          return Container(
            color: Colors.black,
            child: const Center(
                child: Icon(Icons.error_outline, color: Colors.red, size: 48)),
          );
        }
        if (snapshot.connectionState == ConnectionState.done &&
            (_player?.isInitialized ?? false)) {
          return Center(
            child: AspectRatio(
              aspectRatio: _player!.controller.value.aspectRatio,
              child: VideoPlayer(_player!.controller),
            ),
          );
        }
        // While waiting for initialization, show the thumbnail as a background
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: CachedNetworkImageProvider(widget.post.thumbnailUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
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
              Colors.black.withOpacity(0.3),
              Colors.transparent,
              Colors.black.withOpacity(0.5)
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildPostOverlay(
      BuildContext context, PostEntity post, UserEntity? author) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left side: Author Info & Caption
              Expanded(
                child: _buildPostInfo(context, post, author),
              ),
              // Right side: Action Buttons
              _buildActionButtons(context, post),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostInfo(
      BuildContext context, PostEntity post, UserEntity? author) {
    final textTheme = Theme.of(context).textTheme;
    const shadow =
        Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(0, 1));

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Author Info ---
        GestureDetector(
          onTap: () {
            (author != null) ? widget.onUserTapped(author.id) : null;
          },
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: author?.profilePhotoUrl != null &&
                          author!.profilePhotoUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(author.profilePhotoUrl!)
                      : null,
                  child: (author?.profilePhotoUrl == null ||
                          author!.profilePhotoUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 22)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                author?.username ?? 'loading...',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [shadow],
                ),
              ),
              const SizedBox(width: 8),
              // Follow Chip
              if (author != null) // Only show if author is loaded
                const Chip(
                  label: Text('Follow'),
                  labelStyle:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity(horizontal: 0.0, vertical: -4),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // --- Caption ---
        Text(
          post.caption,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            shadows: [shadow],
          ),
        ),
        const SizedBox(height: 12),

        // --- Sound/Music Info ---
        Row(
          children: [
            const Icon(Icons.music_note, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              'Original Sound - ${author?.username ?? '...'}',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: [shadow],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, PostEntity post) {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.diamond_outlined,
          label: post.diamonds.toString(),
          onPressed: () {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              context
                  .read<PostBloc>()
                  .add(SendDiamond(post.id, authState.user.id));
            }
          },
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          icon: Icons.comment_rounded,
          label: post.comments.toString(),
          onPressed: () {},
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          icon: Icons.share_rounded,
          label: 'Share',
          onPressed: () {
            Share.share(
                'Check out this video on Dadadu! https://dadadu.app/${post.id.substring(0, 8)}');
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withOpacity(0.4),
            foregroundColor: Colors.white,
            iconSize: 30,
            padding: const EdgeInsets.all(12),
          ),
          icon: Icon(icon),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 2, color: Colors.black87)],
          ),
        ),
      ],
    );
  }
}
