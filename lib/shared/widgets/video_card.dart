import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:start/generated/l10n.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:ui' as ui;
import '../../models/video_model.dart';
import '../widgets/comment_sheet.dart';
import '../services/database_service.dart';

class VideoCard extends StatefulWidget {
  final Video video;
  final ThemeData theme;
  final bool currentPage;
  final bool isDarkMode;
  final String target;
  final ValueNotifier<bool> tabChanged;
  final VoidCallback onProfileTap;
  final VoidCallback onDiamondTap;
  final int pageIndex;
  final ValueNotifier<int> currentPageNotifier;

  const VideoCard({
    super.key,
    required this.video,
    required this.onProfileTap,
    required this.onDiamondTap,
    required this.target,
    required this.currentPage,
    required this.theme,
    required this.isDarkMode,
    required this.tabChanged,
    required this.pageIndex,
    required this.currentPageNotifier,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;
  bool _showPlusOne = false;
  bool _isLiked = false;
  bool _isLoading = false;
  int _currentDiamonds = 0;
  bool isFollowing = false;
  bool _isDisposed = false;
  // Services Firebase
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _isVisible = false;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentDiamonds = widget.video.diamonds;
    _checkIfLiked();
    _initializeVideo();
    _getFollowers();
    widget.tabChanged.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (widget.tabChanged.value) {
      debugPrint('🧨 Feed tab was left, disposing video');
      _controller.dispose();

      // Optionally reset the flag
      widget.tabChanged.value = false;
    }
  }

  void _handlePageChange() {
    if (_isDisposed || !_controller.value.isInitialized) return;

    final isCurrent = widget.currentPageNotifier.value == widget.pageIndex;
    if (isCurrent && !_controller.value.isPlaying) {
      _controller.play();
    } else if (!isCurrent && _controller.value.isPlaying) {
      _controller.pause();
    }
  }

  Future<void> _getFollowers() async {
    final firestore = FirebaseFirestore.instance;
    final targetFollowersRef = firestore
        .collection('users')
        .doc(widget.target)
        .collection('followers')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    await targetFollowersRef.get().then((value) {
      final isFollowingRef = value.exists;
      if (isFollowingRef) {
        if (mounted) {
          setState(() {
            isFollowing = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isFollowing = false;
          });
        }
      }
    });
  }

  // @override
  // void didUpdateWidget(covariant VideoCard oldWidget) {
  //   super.didUpdateWidget(oldWidget);

  //   if (widget.currentPage && !_controller.value.isPlaying) {
  //     _controller.play();
  //   } else if (!widget.currentPage && _controller.value.isPlaying) {
  //     _controller.pause();
  //   }
  // }

  void _initializeVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.url))
      ..initialize().then((_) {
        if (mounted &&
            _isVisible &&
            !_isDisposed &&
            widget.currentPageNotifier.value == widget.pageIndex) {
          _controller.play();
          _controller.setLooping(true);
          setState(() {}); // Only update UI if visible
          widget.currentPageNotifier.addListener(_handlePageChange);
        }
      });

    _controller.addListener(() {
      if (_controller.value.hasError) {
        print('Video error: ${_controller.value.errorDescription}');
      }
    });
  }

  Future<void> _checkIfLiked() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final isLiked = await _databaseService.hasUserLikedVideo(
        currentUser.uid,
        widget.video.id,
      );

      if (mounted) {
        setState(() {
          _isLiked = isLiked;
        });
      }
    } catch (e) {
      debugPrint('Erreur vérification like: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleDiamondTap() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showSnackBar('You must be logged in');
      return;
    }

    // Empêcher auto-diamant
    if (widget.video.userId == currentUser.uid) {
      _showSnackBar('You cannot give yourself diamonds!');
      return;
    }

    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      if (_isLiked) {
        // Retirer diamant
        await _databaseService.removeDiamond(
          widget.video.id,
          widget.video.userId,
          currentUser.uid,
        );

        if (mounted) {
          setState(() {
            _isLiked = false;
            _currentDiamonds = _currentDiamonds > 0 ? _currentDiamonds - 1 : 0;
          });
          _showSnackBar('💎 Diamond removed');
        }
      } else {
        // Donner diamant
        await _databaseService.giveDiamond(
          widget.video.id,
          widget.video.userId,
          currentUser.uid,
        );

        if (mounted) {
          setState(() {
            _isLiked = true;
            _currentDiamonds = _currentDiamonds + 1;
          });
          _triggerPlusOneAnimation();
          _showSnackBar('💎 Diamond given to ${widget.video.username}');
        }
      }
    } catch (e) {
      _showSnackBar('Erreur: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _triggerPlusOneAnimation() {
    setState(() => _showPlusOne = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showPlusOne = false);
    });
  }

  // 📤 SYSTÈME DE PARTAGE
  Future<void> _shareVideo() async {
    try {
      _showSharingBottomSheet();
    } catch (e) {
      _showSnackBar(S.of(context).shareError(e.toString()));
    }
  }

  void _showSharingBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildSharingSheet(widget.theme, widget.isDarkMode),
    );
  }

  Widget _buildSharingSheet(ThemeData theme, bool isDarkMode) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white54 : Colors.black54,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            s.shareVideo,
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareButton(
                icon: Icons.message,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () => _shareToApp('whatsapp'),
              ),
              _buildShareButton(
                icon: Icons.camera_alt,
                label: 'Instagram',
                color: const Color(0xFFE4405F),
                onTap: () => _shareToApp('instagram'),
              ),
              _buildShareButton(
                icon: Icons.facebook,
                label: 'Facebook',
                color: const Color(0xFF1877F2),
                onTap: () => _shareToApp('facebook'),
              ),
              _buildShareButton(
                icon: Icons.flash_on,
                label: 'Snapchat',
                color: const Color(0xFFFFFC00),
                onTap: () => _shareToApp('snapchat'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _downloadVideo();
                  },
                  icon: const Icon(Icons.download, color: Colors.black),
                  label: Text(
                    s.download,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _shareToApp('general');
                  },
                  icon: Icon(Icons.share, color: theme.primaryColor),
                  label: Text(
                    s.other,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: label == 'Snapchat' ? Colors.black : Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareToApp(String platform) async {
    try {
      _showSnackBar('Preparing share with watermark...');

      // Créer vidéo avec watermark
      final watermarkedPath = await _createVideoWithWatermark();

      // Message personnalisé selon plateforme
      if (mounted) {
        final shareText = _getShareText(context, platform);

        // Partager
        await Share.shareXFiles(
          [XFile(watermarkedPath)],
          text: shareText,
          subject: 'Video from Dadadu',
        );

        // Analytics (Firebase Firestore)
        await _trackShareEvent(platform);
      }
    } catch (e) {
      _showSnackBar('Erreur partage: $e');
    }
  }

  Future<void> _downloadVideo() async {
    final s = S.of(context);

    try {
      bool permissionGranted = false;

      if (Platform.isAndroid) {
        // Android 13+
        if (await Permission.videos.isGranted ||
            await Permission.videos.request().isGranted) {
          permissionGranted = true;
        }
        // Android 10-12
        else if (await Permission.storage.request().isGranted) {
          permissionGranted = true;
        }
      } else {
        // iOS or others
        permissionGranted = true;
      }

      if (!permissionGranted) {
        _showSnackBar(s.permissionRequired);
        return;
      }

      _showSnackBar(s.downloading);

      final watermarkedPath = await _createVideoWithWatermark();

      final downloadsDir = Directory('/storage/emulated/0/Download');
      final fileName = 'dadadu_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final savedPath = path.join(downloadsDir.path, fileName);

      await File(watermarkedPath).copy(savedPath);

      _showSnackBar(s.videoSaved);
    } catch (e) {
      print('error save: $e');
      _showSnackBar(
          s.errorSavingVideo.toString().replaceAll('{error}', e.toString()));
    }
  }

  Future<String> _createVideoWithWatermark() async {
    try {
      final tempDir = await getTemporaryDirectory();

      // Step 1: Download video from Firebase Storage
      final originalFile =
          File('${tempDir.path}/original_${widget.video.id}.mp4');
      final ref = _storage.refFromURL(widget.video.url);
      await ref.writeToFile(originalFile);

      // Step 2: Generate watermark image
      final watermarkBytes = await _createWatermark();
      final watermarkFile = File('${tempDir.path}/watermark.png');
      await watermarkFile.writeAsBytes(watermarkBytes);

      // Step 3: Define output path
      final outputPath = '${tempDir.path}/watermarked_${widget.video.id}.mp4';

      // Step 4: Use FFmpeg to overlay watermark

      final ffmpegCommand =
          '-y -i "${originalFile.path}" -i "${watermarkFile.path}" '
          '-filter_complex "overlay=(main_w-overlay_w)/2:main_h-overlay_h-290" '
          '-c:v libx264 -preset ultrafast -crf 23 -c:a aac "$outputPath"';

      final session = await FFmpegKit.execute(ffmpegCommand);
      final returnCode = await session.getReturnCode();

      if (returnCode?.isValueSuccess() ?? false) {
        return outputPath;
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

  Future<Uint8List> _createWatermark() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const width = 220.0;
    const height = 60.0;

    // Background
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, width, height),
        const Radius.circular(20),
      ),
      bgPaint,
    );

    // Load your logo from assets (ensure it's in pubspec.yaml)
    final ByteData logoBytes = await rootBundle.load('assets/icons/logo.jpg');
    final Uint8List logoData = logoBytes.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(logoData,
        targetWidth: 40, targetHeight: 40);
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image logoImage = frame.image;

    // Draw logo on canvas
    final logoOffset = const Offset(10, 10);
    canvas.drawImage(logoImage, logoOffset, Paint());

    // Text next to logo
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'dadadu',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24, // Larger font
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(60, 18));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  String _getShareText(BuildContext context, String platform) {
    final s = S.of(context);

    final baseText = s.shareBaseText
        .toString()
        .replaceAll('{caption}', widget.video.caption)
        .replaceAll('{username}', widget.video.username);

    switch (platform) {
      case 'whatsapp':
        return '$baseText\n\n${s.shareWhatsAppSuffix}';
      case 'instagram':
        return '$baseText\n\n${s.shareInstagramSuffix}';
      case 'facebook':
        return '$baseText\n\n${s.shareFacebookSuffix}';
      case 'snapchat':
        return '$baseText\n\n${s.shareSnapchatSuffix}';
      default:
        return baseText;
    }
  }

  Future<void> _trackShareEvent(String platform) async {
    try {
      await FirebaseFirestore.instance.collection('analytics').add({
        'type': 'video_share',
        'platform': platform,
        'videoId': widget.video.id,
        'authorId': widget.video.userId,
        'sharerId': _auth.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Erreur analytics partage: $e');
    }
  }

  // Future<void> _trackDownloadEvent() async {
  //   try {
  //     await FirebaseFirestore.instance.collection('analytics').add({
  //       'type': 'video_download',
  //       'videoId': widget.video.id,
  //       'authorId': widget.video.userId,
  //       'downloaderId': _auth.currentUser?.uid,
  //       'timestamp': FieldValue.serverTimestamp(),
  //     });
  //   } catch (e) {
  //     debugPrint('Erreur analytics téléchargement: $e');
  //   }
  // }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.tealAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> toggleFollow({
    required String targetUserId,
    required String currentUserId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    final targetFollowersRef = firestore
        .collection('users')
        .doc(targetUserId)
        .collection('followers')
        .doc(currentUserId);

    final currentFollowingRef = firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(targetUserId);

    (await targetFollowersRef.get().then((value) async {
      final isFollowingRef = value.exists;
      if (isFollowingRef) {
        // Unfollow
        await targetFollowersRef.delete();
        await currentFollowingRef.delete();
        if (mounted) {
          setState(() {
            isFollowing = false;
          });
        }
      } else {
        // Follow
        if (mounted) {
          setState(() {
            isFollowing = true;
          });
        }
        await targetFollowersRef
            .set({'followedAt': FieldValue.serverTimestamp()});
        await currentFollowingRef
            .set({'followedAt': FieldValue.serverTimestamp()});
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final s = S.of(context);
    return Stack(
      children: [
        // 🎥 Vidéo
        VisibilityDetector(
          key: const Key('video-feed'),
          onVisibilityChanged: (VisibilityInfo info) {
            final visible = info.visibleFraction > 0.5;
            if (_controller.value.isInitialized) {
              if (visible && !_controller.value.isPlaying) {
                _controller.play();
              } else if (!visible && _controller.value.isPlaying) {
                _controller.pause();
              }
            }
            _isVisible = visible;
          },
          child: Center(
            child: _controller.value.isInitialized
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(
                        color: widget.theme.primaryColor)),
          ),
        ),

        // 👤 Infos vidéo
        Positioned(
          left: 16,
          bottom: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  toggleFollow(
                    targetUserId: widget.target,
                    currentUserId: FirebaseAuth.instance.currentUser!.uid,
                  );
                },
                child: Container(
                  height: 30,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        isFollowing ? Colors.grey.shade800 : Colors.tealAccent,
                  ),
                  child: Center(
                      child: Text(
                    isFollowing ? s.following : s.follow,
                    style: TextStyle(
                        color: isFollowing ? Colors.white : Colors.black),
                  )),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: widget.onProfileTap,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.video.username,
                      style: TextStyle(
                        color: !_controller.value.isInitialized
                            ? !widget.isDarkMode
                                ? Colors.black
                                : Colors.white
                            : widget.isDarkMode
                                ? Colors.black
                                : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (widget.video.isDadader)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(Icons.emoji_events,
                            color: Colors.amber, size: 20),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  widget.video.caption,
                  style: TextStyle(
                      color: !_controller.value.isInitialized
                          ? !widget.isDarkMode
                              ? Colors.black54
                              : Colors.white54
                          : !widget.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                      fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.diamond,
                      size: 21, color: Colors.amberAccent),
                  const SizedBox(width: 6),
                  Text(
                    "$_currentDiamonds",
                    style: TextStyle(
                        color: !_controller.value.isInitialized
                            ? Colors.black87
                            : Colors.white70,
                        fontSize: 14),
                  ),
                  AnimatedOpacity(
                    opacity: _showPlusOne ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        "+1",
                        style:
                            TextStyle(color: Colors.greenAccent, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 💎 + 📤 + 💬 Boutons
        Positioned(
          right: 16,
          bottom: 80,
          child: Column(
            children: [
              // Bouton diamant avec état
              GestureDetector(
                onTap: _handleDiamondTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                    border: _isLiked
                        ? Border.all(color: Colors.amber, width: 2)
                        : null,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.amber,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          _isLiked ? Icons.diamond : Icons.diamond_outlined,
                          color: Colors.amber,
                          size: 28,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Bouton téléchargement
              GestureDetector(
                onTap: _downloadVideo,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.download,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bouton partage
              GestureDetector(
                onTap: _shareVideo,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.share,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bouton commentaire - CORRIGÉ AVEC PARAMÈTRES REQUIS
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CommentSheet(
                      videoId: widget.video.id,
                      videoAuthorId: widget.video.userId,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.comment,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
