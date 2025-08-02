// lib/features/posts/presentation/pages/create_post_page.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:dadadu_app/features/posts/domain/entities/post_draft.dart';
import 'package:dadadu_app/l10n/app_localizations.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/post_bloc.dart';

class CreatePostPage extends StatefulWidget {
  final String videoPath;
  final PostDraft initialDraft;

  const CreatePostPage(
      {super.key, required this.videoPath, required this.initialDraft});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  // This controller is used to get video duration for thumbnail generation
  late VideoPlayerController _videoController;
  late TextEditingController _captionController;

  bool _isProcessing = false;

  List<Uint8List> _thumbnails = [];
  Uint8List? _selectedThumbnail;
  bool _isLoadingThumbnails = true;
  String _selectedIntent = 'Entertainment';

  @override
  void initState() {
    super.initState();
    _captionController =
        TextEditingController(text: widget.initialDraft.caption);
    _selectedIntent = widget.initialDraft.intent;
    _selectedThumbnail = widget.initialDraft.selectedThumbnail;
    _initialize();
  }

  Future<void> _initialize() async {
    _videoController = VideoPlayerController.file(File(widget.videoPath));
    await _videoController.initialize();
    await _generateThumbnails();
  }

  Future<void> _generateThumbnails() async {
    try {
      final List<Uint8List> generatedThumbnails = [];
      final int videoDurationMs =
          _videoController.value.duration.inMilliseconds;

      // Generate 6 thumbnails for a better selection
      final List<int> timeStamps = List.generate(
          6, (index) => (videoDurationMs * (index + 1) / 7).round());

      for (final timeMs in timeStamps) {
        final thumbnail = await VideoThumbnail.thumbnailData(
          video: widget.videoPath,
          imageFormat: ImageFormat.JPEG,
          timeMs: timeMs,
          quality: 50,
        );
        if (thumbnail != null) {
          generatedThumbnails.add(thumbnail);
        }
      }

      if (mounted && _thumbnails.isNotEmpty && _selectedThumbnail == null) {
        setState(() {
          _selectedThumbnail = _thumbnails.first;
        });
      }
      ;

      if (mounted && generatedThumbnails.isNotEmpty) {
        setState(() {
          _thumbnails = generatedThumbnails;
          _selectedThumbnail = generatedThumbnails.first;
          _isLoadingThumbnails = false;
        });
      }
    } catch (e) {
      debugPrint("Error generating thumbnails: $e");
      if (mounted) {
        setState(() => _isLoadingThumbnails = false);
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  void _goBackToEditor() {
    if (context.canPop()) {
      // ✅ Create an updated draft with the current UI state
      final updatedDraft = PostDraft(
        caption: _captionController.text,
        intent: _selectedIntent,
        selectedThumbnail: _selectedThumbnail,
      );
      // ✅ Pass the updated draft back when popping
      context.pop(updatedDraft);
    }
  }

  Future<void> _publishPost() async {
    if (_selectedThumbnail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.pleaseSelectAThumbnail)),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final processedVideoPath =
          '${tempDir.path}/processed.${DateTime.now().millisecondsSinceEpoch}.mp4';
      // reduces file size
      final command =
          '-y -i "${widget.videoPath}" -c:v libx264 -preset veryfast -crf 28 -c:a aac "$processedVideoPath"';

      // final command = '-y -i "${widget.videoPath}" -c:v libx264 -preset medium -crf 23 -vf "scale=-2:1080" -c:a aac -b:a 128k -movflags +faststart "$processedVideoPath".mp4';

      // final command = '-y -i "${widget.videoPath}" -c:v libx264 -preset ultrafast -crf 23 -c:a aac "$processedVideoPath".mp4';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          // ✅ Dispatch the event to the UploadBloc
          context.read<PostBloc>().add(UploadPost(
                // videoFile: File(widget.videoPath),
                videoFile: File(processedVideoPath),
                thumbnailBytes: _selectedThumbnail!,
            caption: _captionController.text.trim(),
            intent: _selectedIntent,
            userId: authState.user.id,
          ));
        }
      } else {
        debugPrint('FFmpeg process failed with return code: $returnCode');
        final logs = await session.getAllLogsAsString();
        debugPrint('FFmpeg logs: $logs');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.couldNotProcessVideo)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.errorPublishingPost(''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<PostBloc, PostState>(listener: (context, state) {
      // ✅ This listener handles the navigation after the upload is complete.
      if (state is UploadSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.postPublishedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home'); // Navigate to the home feed
      } else if (state is UploadFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.uploadFailed('')),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }, builder: (context, state) {
      final isUploading = state is UploadInProgress;
      final isBusy = _isProcessing || isUploading;
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.newPost),
          centerTitle: true,
          // The publish button is now at the bottom of the page
        ),
        body: AbsorbPointer(
          absorbing: isUploading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Top Section: Thumbnail Preview & Caption ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildThumbnailPreview(),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCaptionField()),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Thumbnail Selector ---
                Text(AppLocalizations.of(context)!.chooseACover,
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                    _buildThumbnailSelector(),
                    const SizedBox(height: 24),

                // --- Intent/Category Selector ---
                Text(AppLocalizations.of(context)!.selectAnIntent,
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _buildIntentSelector(),
                const SizedBox(height: 48), // Extra space before button

                // --- Publish Button ---
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                    icon: isUploading
                        ? const SizedBox.shrink()
                            : const Icon(Icons.publish_rounded),
                    label: Text(
                      _isProcessing
                          ? AppLocalizations.of(context)!.processing
                          : isUploading
                              ? AppLocalizations.of(context)!.publishing(
                                  (state.progress * 100).toStringAsFixed(0))
                              : AppLocalizations.of(context)!.publish,
                    ),
                    onPressed: isBusy ? null : _publishPost,
                    style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                if (isUploading) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: isUploading ? state.progress : null,
                  ),
                ]
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  Widget _buildThumbnailPreview() {
    return GestureDetector(
      onTap: _goBackToEditor,
      child: Card(
        elevation: 4,
        shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 110,
          height: 180,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            image: _selectedThumbnail != null
                ? DecorationImage(
                    image: MemoryImage(_selectedThumbnail!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Semi-transparent overlay for better icon visibility
              Container(color: Colors.black.withOpacity(0.2)),
              // Large play icon
              Icon(
                Icons.play_arrow_rounded,
                color: Colors.white.withOpacity(0.8),
                size: 60,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 10)],
              ),
              if (_selectedThumbnail == null) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaptionField() {
    return SizedBox(
      height: 180, // Match the height of the thumbnail preview
      child: TextFormField(
        controller: _captionController,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.addACaption,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(12),
        ),
        maxLength: 200,
        maxLines: null,
        // Allows the field to expand vertically
        expands: true,
        // Makes the field fill the available height
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }

  Widget _buildThumbnailSelector() {
    if (_isLoadingThumbnails) {
      return const SizedBox(
          height: 100, child: Center(child: CircularProgressIndicator()));
    }
    if (_thumbnails.isEmpty) {
      return SizedBox(
          height: 100,
          child: Center(
              child: Text(
                  AppLocalizations.of(context)!.couldNotGenerateThumbnails)));
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _thumbnails.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final thumbnailBytes = _thumbnails[index];
          final isSelected = _selectedThumbnail == thumbnailBytes;

          return GestureDetector(
            onTap: () => setState(() => _selectedThumbnail = thumbnailBytes),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 3,
                ),
                image: DecorationImage(
                  image: MemoryImage(thumbnailBytes),
                  fit: BoxFit.cover,
                ),
              ),
              child: isSelected
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        // Adjust to inner radius
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.4),
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildIntentSelector() {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<String>(
        segments: [
          ButtonSegment(
              value: 'Love',
              label: Text(AppLocalizations.of(context)!.love),
              icon: Icon(Icons.favorite_border)),
          ButtonSegment(
              value: 'Business',
              label: Text(AppLocalizations.of(context)!.business),
              icon: Icon(Icons.business_center_outlined)),
          ButtonSegment(
              value: 'Entertainment',
              label: Text(AppLocalizations.of(context)!.entertainment),
              icon: Icon(Icons.movie_outlined)),
        ],
        selected: {_selectedIntent},
        onSelectionChanged: (newSelection) {
          setState(() {
            _selectedIntent = newSelection.first;
          });
        },
      ),
    );
  }
}
