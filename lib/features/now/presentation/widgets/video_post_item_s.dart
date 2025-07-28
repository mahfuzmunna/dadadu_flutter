// lib/features/now/presentation/widgets/video_post_item.dart

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/posts/presentation/bloc/diamond_bloc.dart';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

// import 'package:video_watermark_plus/video_watermark_plus.dart';

import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../comments/presentation/bloc/comments_bloc.dart';
import '../../../profile/presentation/bloc/follow_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../upload/domain/entities/post_entity.dart';
import 'comments_view.dart';

class VideoPostItem extends StatefulWidget {
  final PostEntity post;
  final UserEntity? author;
  final bool isCurrentPage;
  final VideoPlayerController? controller;
  final Function(String userId) onUserTapped;

  const VideoPostItem({
    super.key,
    required this.post,
    required this.author,
    required this.isCurrentPage,
    required this.onUserTapped,
    required this.controller,
  });

  @override
  State<VideoPostItem> createState() => _VideoPostItemState();
}

class _VideoPostItemState extends State<VideoPostItem> {
  Future<void>? _initializeVideoPlayerFuture;
  bool _hasError = false;
  bool _diamondActionInProgress = false;

  // State variables for the download feature
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant VideoPostItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentPage != oldWidget.isCurrentPage) {
      if (widget.isCurrentPage) {
        widget.controller?.play();
      } else {
        widget.controller?.pause();
      }
    }
  }

  @override
  void dispose() {
    // widget.controller?.dispose();
    super.dispose();
  }

  void _initializeVideo() {
    if (widget.controller != null) return;

    _initializeVideoPlayerFuture = widget.controller!.initialize().then((_) {
      if (!mounted) return;
      if (widget.controller!.value.isInitialized) {
        widget.controller!.setLooping(true);
        if (widget.isCurrentPage) {
          widget.controller!.play();
        }
      } else {
        if (mounted) setState(() => _hasError = true);
      }
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint("Error initializing video for post ${widget.post.id}: $error");
      if (mounted) setState(() => _hasError = true);
    });
  }

  // --- Video Saving Logic ---

  Future<void> _saveVideo() async {
    if (_isDownloading) return;

    final status = await Permission.storage.request();
    if (!status.isGranted) {
      _showSnackBar('Storage permission is required to save videos.');
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/${widget.post.id}.mp4';

      await dio.download(
        widget.post.videoUrl,
        tempFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      final watermarkedFilePath = await _applyWatermark(tempFilePath);
      final success = await GallerySaver.saveVideo(watermarkedFilePath);

      if (success ?? false) {
        _showSnackBar('Video saved to gallery!');
      } else {
        _showSnackBar('Failed to save video.', isError: true);
      }
    } catch (e) {
      _showSnackBar('An error occurred while saving the video.', isError: true);
      debugPrint('Save video error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
        });
      }
    }
  }

  Future<String> _applyWatermark(String filePath) async {
    try {
      debugPrint("Applying watermark to video at: $filePath");

      // 1. Get the watermark image from assets and save it to a temporary file
      final byteData = await rootBundle.load('assets/images/watermark.png');
      final tempDir = await getTemporaryDirectory();
      final watermarkImagePath = '${tempDir.path}/watermark.png';
      final watermarkFile = File(watermarkImagePath);
      await watermarkFile.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      // 2. Define the output path for the watermarked video
      final outputVideoPath =
          '${tempDir.path}/watermarked_${widget.post.id}.mp4';

      // 3. Using ffmpeg to watermark the video

      final ffmpegCommand = '-y -i "$filePath" -i "${watermarkFile.path}" '
          '-filter_complex "overlay=(main_w-overlay_w)/2:main_h-overlay_h-290" '
          '-c:v libx264 -preset ultrafast -crf 23 -c:a aac "$outputVideoPath"';

      final session = await FFmpegKit.execute(ffmpegCommand);
      final returnCode = await session.getReturnCode();

      if (returnCode?.isValueSuccess() ?? false) {
        return outputVideoPath;
      } else {
        final logs = await session.getAllLogs();
        logs.forEach((log) => print('FFmpeg Log: ${log.getMessage()}'));

        final stack = await session.getFailStackTrace();
        print("Fail stack: $stack");

        throw Exception('FFmpeg failed with code: $returnCode');
      }
    } catch (e) {
      throw Exception('Erreur création watermark: $e');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Theme.of(context).colorScheme.error : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.controller?.value.isInitialized ?? false) {
          widget.controller!.value.isPlaying
              ? widget.controller!.pause()
              : widget.controller!.play();
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
    if (widget.controller != null && widget.controller!.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: widget.controller!.value.aspectRatio,
          child: VideoPlayer(widget.controller!),
        ),
      );
    }
    // Show thumbnail while the controller is initializing in the background
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
                child: _buildPostInfo(context, widget.post, widget.author),
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

    final authState = context.watch<AuthBloc>().state;

    return BlocProvider<FollowBloc>(
        create: (context) => sl<FollowBloc>(),
        child:
            BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
          if (state is ProfileLoaded && state.user != null) {
            author = state.user;
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Author Info ---
                GestureDetector(
                  onTap: () {
                    (author != null) ? widget.onUserTapped(author!.id) : null;
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
                              ? CachedNetworkImageProvider(
                                  author!.profilePhotoUrl!)
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
                      if (author != null && authState is AuthAuthenticated)
                        _buildFollowButton(context, authState.user, author!),
                      // if (author != null) // Only show if author is loaded
                      //   const Chip(
                      //     label: Text('Follow'),
                      //     labelStyle:
                      //         TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      //     padding: EdgeInsets.zero,
                      //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      //     visualDensity:
                      //         VisualDensity(horizontal: 0.0, vertical: -4),
                      //   ),
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
          } else {
            return Container();
          }
        }));
  }

  Widget _buildFollowButton(
      BuildContext context, UserEntity currentUser, UserEntity author) {
    // Don't show the follow button on your own post
    if (currentUser.id == author.id) {
      return const SizedBox.shrink();
    }

    final bool isFollowing = currentUser.followingIds.contains(author.id);

    return BlocConsumer<FollowBloc, FollowState>(
      listener: (context, state) {
        if (state is FollowSuccess) {
          // Refresh current user data to update the UI correctly
          context.read<AuthBloc>().add(AuthRefreshCurrentUser(currentUser.id));
        }
        if (state is FollowError) {
          _showSnackBar(state.message, isError: true);
        }
      },
      builder: (context, state) {
        // Show a loading indicator while the request is in progress
        if (state is FollowLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
          );
        }

        // The actual button, wrapped in a GestureDetector for the tap event
        return GestureDetector(
          onTap: () {
            final event = isFollowing
                ? UnfollowUser(
                    currentUserId: currentUser.id, profileUserId: author.id)
                : FollowUser(
                    currentUserId: currentUser.id, profileUserId: author.id);
            context.read<FollowBloc>().add(event);
          },
          child: Chip(
            label: Text(isFollowing ? 'Following' : 'Follow'),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isFollowing ? Colors.black : Colors.white,
            ),
            backgroundColor: isFollowing
                ? Colors.white.withOpacity(0.8)
                : Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: 0.0, vertical: -4),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (authState is AuthAuthenticated && widget.author != null)
          _buildDiamondButton(
              context, authState.user, widget.post, widget.author!),
        const SizedBox(height: 20),
        _buildActionButton(
            icon: Icons.comment_bank_outlined,
            label: widget.post.comments != null
                ? widget.post.comments!.length.toString()
                : '0',
            onPressed: () {
              _showCommentsBottomSheet(context, widget.post.id);
            }),
        const SizedBox(height: 20),
        _buildActionButton(
            icon: Icons.file_download_rounded,
            label: 'Save',
            onPressed: _saveVideo),
        const SizedBox(height: 20),
        _buildActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onPressed: () {
              Share.share(
                  'Check out this video! https://dadadu.app/${widget.post.id.substring(0, 8)}');
            }),
      ],
    );
  }

  Widget _buildDiamondButton(BuildContext context, UserEntity currentUser,
      PostEntity post, UserEntity author) {
    final bool hasGivenDiamond =
        post.diamondGivers?.contains(currentUser.id) ?? false;

    return BlocConsumer<DiamondBloc, DiamondState>(
      listener: (context, state) {
        if (state is DiamondSuccess || state is DiamondFailure) {
          setState(() {
            _diamondActionInProgress = false;
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is DiamondLoading;

        return _buildActionButton(
          iconWidget: (isLoading)
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  hasGivenDiamond ? Icons.diamond : Icons.diamond_outlined,
                  color: hasGivenDiamond
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                ),
          label: '${post.diamondGivers?.length ?? 0}',
          onPressed: () {
            if (currentUser.id == author.id) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('You can\'t give a diamond to yourself.')));
              return;
            }
            if (_diamondActionInProgress) return;

            setState(() {
              _diamondActionInProgress = true;
            });

            final event = hasGivenDiamond
                ? UnsendDiamond(
                    userId: currentUser.id,
                    postId: post.id,
                    authorId: post.userId)
                : SendDiamond(
                    userId: currentUser.id,
                    postId: post.id,
                    authorId: post.userId);

            context.read<DiamondBloc>().add(event);
          },
        );
      },
    );
  }

  void _showCommentsBottomSheet(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) => BlocProvider(
          create: (context) => sl<CommentsBloc>()..add(LoadComments(postId)),
          child: CommentsView(scrollController: scrollController),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    IconData? icon,
    Widget? iconWidget, // Can now pass a custom widget for the icon
    required String label,
    required VoidCallback onPressed,
  }) {
    assert(icon != null || iconWidget != null,
        'Either icon or iconWidget must be provided.');

    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: onPressed,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  foregroundColor: Colors.white,
                  iconSize: 30,
                  padding: const EdgeInsets.all(12),
                ),
                icon: iconWidget ?? Icon(icon),
              ),
            ],
          ),
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
