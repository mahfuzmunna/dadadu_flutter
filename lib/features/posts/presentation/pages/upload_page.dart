import 'dart:io';

import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../bloc/upload_bloc.dart'; // Assume BLoC files are in the same folder

class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<UploadBloc>(),
      // Assuming `sl` from GetIt
      child: const _UploadView(),
    );
  }
}

class _UploadView extends StatefulWidget {
  const _UploadView();

  @override
  State<_UploadView> createState() => __UploadViewState();
}

class __UploadViewState extends State<_UploadView> {
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo(BuildContext context) async {
    final XFile? result =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (result != null && context.mounted) {
      context.read<UploadBloc>().add(UploadVideoSelected(File(result.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Post'),
        centerTitle: true,
        actions: [
          BlocBuilder<UploadBloc, UploadState>(
            builder: (context, state) {
              final isReady =
                  state.videoFile != null && state.caption.isNotEmpty;
              return TextButton(
                onPressed: isReady && state.status != UploadStatus.uploading
                    ? () {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthAuthenticated) {
                          context
                              .read<UploadBloc>()
                              .add(UploadSubmitted(authState.user.id));
                        }
                      }
                    : null,
                child: const Text('Publish'),
              );
            },
          )
        ],
      ),
      body: BlocConsumer<UploadBloc, UploadState>(
        listener: (context, state) {
          // Handle video controller initialization
          if (state.videoFile != _videoController?.dataSource) {
            _videoController?.dispose();
            if (state.videoFile != null) {
              _videoController = VideoPlayerController.file(state.videoFile!)
                ..initialize().then((_) {
                  _videoController?.setLooping(true);
                  setState(() {}); // Rebuild to show video
                });
            }
          }
          // Handle navigation on success
          if (state.status == UploadStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upload successful!')));
            // context.go('/home'); // Example navigation
          }
          // Handle errors
          if (state.status == UploadStatus.failure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Video Preview and Picker
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: GestureDetector(
                    onTap: () => _pickVideo(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        image: state.thumbnailFile != null
                            ? DecorationImage(
                                image: FileImage(state.thumbnailFile!),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: state.status == UploadStatus.loadingThumbnail
                          ? const Center(child: CircularProgressIndicator())
                          : (state.videoFile == null
                              ? Center(
                                  child: Icon(Icons.video_call_rounded,
                                      size: 60,
                                      color: colorScheme.onSurfaceVariant))
                              : (_videoController?.value.isInitialized ?? false)
                                  ? VideoPlayer(_videoController!)
                                  : const SizedBox.shrink()),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Caption Field
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Add a caption...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  onChanged: (value) => context
                      .read<UploadBloc>()
                      .add(UploadCaptionChanged(value)),
                ),
                const SizedBox(height: 16),
                // Intent Selector
                _IntentSelector(
                  selectedIntent: state.intent,
                  onIntentSelected: (intent) => context
                      .read<UploadBloc>()
                      .add(UploadIntentChanged(intent)),
                ),
                const SizedBox(height: 24),
                // Upload Progress
                if (state.status == UploadStatus.uploading)
                  Column(
                    children: [
                      LinearProgressIndicator(value: state.progress),
                      const SizedBox(height: 8),
                      Text(
                          '${(state.progress * 100).toStringAsFixed(0)}% Uploaded'),
                    ],
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}

// A helper widget for the intent selector for better readability
class _IntentSelector extends StatelessWidget {
  final String selectedIntent;
  final ValueChanged<String> onIntentSelected;

  const _IntentSelector(
      {required this.selectedIntent, required this.onIntentSelected});

  @override
  Widget build(BuildContext context) {
    final intents = {
      'love': Icons.favorite,
      'business': Icons.business_center,
      'entertainment': Icons.movie
    };
    return Row(
      children: intents.entries.map((entry) {
        final isSelected = selectedIntent == entry.key;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: OutlinedButton.icon(
              icon: Icon(entry.value),
              label: Text(entry.key[0].toUpperCase() + entry.key.substring(1)),
              onPressed: () => onIntentSelected(entry.key),
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
