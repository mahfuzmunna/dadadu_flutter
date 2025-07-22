// lib/features/upload/presentation/pages/create_post_page.dart

import 'dart:io';

import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart'; // To get current user ID
// import 'package:dadadu_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:dadadu_app/features/upload/presentation/bloc/upload_post_bloc.dart'; // Upload Bloc
import 'package:dadadu_app/injection_container.dart'; // For GetIt
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // For navigation
import 'package:video_player/video_player.dart';

class CreatePostPage extends StatefulWidget {
  final String videoPath;

  const CreatePostPage({super.key, required this.videoPath});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late VideoPlayerController _videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedTag = 'Entertainment'; // Default tag
  final List<String> _tags = ['Love', 'Business', 'Entertainment'];

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));
    _initializeVideoPlayerFuture = _videoPlayerController.initialize().then((_) {
      _videoPlayerController.setLooping(true);
      _videoPlayerController.play();
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onPublishPressed(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (_descriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please add a description for your post.',
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
        return;
      }

      // Dispatch the upload event
      context.read<UploadPostBloc>().add(
        UploadVideoAndPost(
          videoFile: File(widget.videoPath),
          description: _descriptionController.text.trim(),
          tag: _selectedTag,
          userId: authState.user.uid, // Get current user ID from AuthBloc
              thumbnailUrl: '', // Placeholder for thumbnail URL
            ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You must be logged in to publish a post.',
            style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UploadPostBloc>(
      create: (context) => sl<UploadPostBloc>(), // Provide UploadPostBloc
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Post'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: BlocListener<UploadPostBloc, UploadPostState>(
          listener: (context, state) {
            if (state is UploadPostLoading) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      CircularProgressIndicator(
                        value: state.progress,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Uploading... ${(state.progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ],
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  duration: const Duration(minutes: 5), // Keep showing during upload
                ),
              );
            } else if (state is UploadPostSuccess) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Post published successfully!',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                ),
              );
              // Navigate back to home or profile after successful upload
              context.go('/home');
            } else if (state is UploadPostError) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Upload Failed: ${state.message}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Video Preview:',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Post Description Input
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'What\'s on your mind?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  maxLines: 5,
                  minLines: 3,
                ),
                const SizedBox(height: 24),

                // Tags Selection
                Text(
                  'Select Tag:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _tags.map((tag) {
                    return ChoiceChip(
                      label: Text(tag),
                      selected: _selectedTag == tag,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTag = tag;
                        });
                      },
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      labelStyle: TextStyle(
                        color: _selectedTag == tag
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _selectedTag == tag
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Publish Button
                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<UploadPostBloc, UploadPostState>(
                    builder: (context, state) {
                      final bool isLoading = state is UploadPostLoading;
                      return FilledButton.icon(
                        onPressed: isLoading ? null : () => _onPublishPressed(context),
                        icon: isLoading
                            ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                          ),
                        )
                            : const Icon(Icons.publish),
                        label: Text(
                          isLoading ? 'Publishing...' : 'Publish Post',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}