// lib/features/now/presentation/widgets/video_post_item.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../../upload/domain/entities/post_entity.dart';

class VideoPostItem extends StatelessWidget {
  final PostEntity post;
  final UserEntity? author;
  final VideoPlayerController?
      controller; // Receives the controller from the parent
  final bool isCurrentPage;
  final Function(String userId) onUserTapped;

  const VideoPostItem({
    super.key,
    required this.post,
    required this.author,
    required this.controller,
    required this.isCurrentPage,
    required this.onUserTapped,
  });

  @override
  Widget build(BuildContext context) {
    // For this UI, we can use a simpler BlocBuilder on a single PostActionBloc
    // to get live updates for the author, or pass it directly if available.
    // For simplicity, we'll build the UI directly from the `post` prop.

    return GestureDetector(
      onTap: () {
        if (controller?.value.isInitialized ?? false) {
          controller!.value.isPlaying
              ? controller!.pause()
              : controller!.play();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildVideoPlayer(),
          _buildGradientOverlay(),
          SafeArea(child: _buildPostOverlay(context)),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (controller != null && controller!.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
      );
    }
    // Show thumbnail while the controller is initializing in the background
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: CachedNetworkImageProvider(post.thumbnailUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildPostOverlay(BuildContext context) {
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
              _buildActionButtons(context),
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

    return BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
      if (state is ProfileLoaded && state.user != null) {
        author = state.user;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Author Info ---
            GestureDetector(
              onTap: () {
                (author != null) ? onUserTapped(author!.id) : null;
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
                          ? CachedNetworkImageProvider(author!.profilePhotoUrl!)
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
                      visualDensity:
                          VisualDensity(horizontal: 0.0, vertical: -4),
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
      } else
        return Container();
    });
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildActionButton(
          icon: Icons.diamond_outlined,
          label: post.diamonds.toString(),
          onPressed: () {
            // context.read<PostBloc>().add(IncrementLike(post.id));
          },
        ),
        const SizedBox(height: 20),
        _buildActionButton(
            icon: Icons.comment_bank_outlined,
            label: post.comments.toString(),
            onPressed: () {}),
        const SizedBox(height: 20),
        _buildActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onPressed: () {
              Share.share('Check out this video! ${post.caption}');
            }),
      ],
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
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
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ],
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
              Colors.black.withOpacity(0.4),
              Colors.transparent,
              Colors.black.withOpacity(0.6)
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
      ),
    );
  }
}
