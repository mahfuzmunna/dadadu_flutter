// lib/features/now/presentation/widgets/video_post_item.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/now/presentation/bloc/post_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../../upload/domain/entities/post_entity.dart';

class VideoPostItem extends StatefulWidget {
  final PostEntity initialPost;
  final bool isCurrentPage;
  final Function(String userId) onUserTapped;

  const VideoPostItem({
    super.key,
    required this.initialPost,
    required this.isCurrentPage,
    required this.onUserTapped,
  });

  @override
  State<VideoPostItem> createState() => _VideoPostItemState();
}

class _VideoPostItemState extends State<VideoPostItem>
    with WidgetsBindingObserver {
  CachedVideoPlayerPlus? _videoController;
  Future<void>? _initializeVideoPlayerFuture;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant VideoPostItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentPage != oldWidget.isCurrentPage) {
      if (widget.isCurrentPage) {
        _videoController?.controller.play();
      } else {
        _videoController?.controller.pause();
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
    _videoController?.controller.dispose();
    super.dispose();
  }

  void _initializeVideo() {
    if (_videoController?.controller != null) return;

    _videoController = CachedVideoPlayerPlus.networkUrl(
        Uri.parse(widget.initialPost.videoUrl));
    _initializeVideoPlayerFuture = _videoController!.initialize().then((_) {
      if (!mounted) return;
      if (_videoController!.controller.value.isInitialized) {
        _videoController!.controller.setLooping(true);
        if (widget.isCurrentPage) {
          _videoController!.controller.play();
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
              (state is PostLoaded) ? state.post : widget.initialPost;
          final author = (state is PostLoaded) ? state.author : null;

          return GestureDetector(
            onTap: () {
              if (_videoController?.controller.value.isInitialized ?? false) {
                _videoController!.controller.value.isPlaying
                    ? _videoController!.controller.pause()
                    : _videoController!.controller.play();
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
            (_videoController?.controller.value.isInitialized ?? false)) {
          return Center(
            child: AspectRatio(
              aspectRatio: _videoController!.controller.value.aspectRatio,
              child: VideoPlayer(_videoController!.controller),
            ),
          );
        }
        // While waiting for initialization, show the thumbnail as a background
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image:
                  CachedNetworkImageProvider(widget.initialPost.thumbnailUrl),
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
      padding: const EdgeInsets.all(16.0).copyWith(bottom: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left side: Author Info & Caption
              Expanded(
                child: _buildPostInfo(post, author),
              ),
              // Right side: Action Buttons
              _buildActionButtons(context, post),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostInfo(PostEntity post, UserEntity? author) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => (author != null) ? widget.onUserTapped(author.id) : null,
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: author?.profilePhotoUrl != null
                    ? CachedNetworkImageProvider(author!.profilePhotoUrl!)
                    : null,
                child: author?.profilePhotoUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                author?.username ?? 'Loading...',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(post.caption,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white)),
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
            context.read<PostBloc>().add(IncrementLike(post.id));
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