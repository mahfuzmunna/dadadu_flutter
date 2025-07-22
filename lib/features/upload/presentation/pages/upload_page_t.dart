// lib/features/upload/presentation/pages/upload_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart'; // For dependency injection
import 'package:image_picker/image_picker.dart'; // For picking video and images

import '../bloc/upload_bloc.dart'; // Your UploadBloc
import 'widgets/custom_button.dart'; // Assuming you have a custom button widget
import 'widgets/custom_text_field.dart'; // Assuming you have a custom text field widget

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _videoFile;
  File? _thumbnailFile;
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // Function to pick a video file
  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _videoFile = File(video.path);
      });
    }
  }

  // Function to pick an image file for the thumbnail
  Future<void> _pickThumbnail() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _thumbnailFile = File(image.path);
      });
    }
  }

  // Function to trigger the upload process
  void _uploadPost(BuildContext context) {
    if (_videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video.')),
      );
      return;
    }
    if (_thumbnailFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a thumbnail image.')),
      );
      return;
    }

    // Dispatch the UploadPostRequested event
    BlocProvider.of<UploadBloc>(context).add(
      UploadPostRequested(
        videoFile: _videoFile!,
        thumbnailFile: _thumbnailFile!,
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Provide the UploadBloc using GetIt
      create: (context) => GetIt.instance<UploadBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Upload New Post'),
          centerTitle: true,
        ),
        body: BlocConsumer<UploadBloc, UploadState>(
          listener: (context, state) {
            if (state is UploadSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post uploaded successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Optionally navigate back or to another page
              Navigator.of(context).pop();
            } else if (state is UploadError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Upload failed: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Video Selection
                    GestureDetector(
                      onTap: _pickVideo,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        alignment: Alignment.center,
                        child: _videoFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.video_library,
                                      size: 50, color: Colors.grey[600]),
                                  const SizedBox(height: 8),
                                  const Text('Tap to select video',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 50),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Video Selected: ${_videoFile!.path.split('/').last}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextButton(
                                    onPressed: _pickVideo,
                                    child: const Text('Change Video'),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Thumbnail Selection
                    GestureDetector(
                      onTap: _pickThumbnail,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        alignment: Alignment.center,
                        child: _thumbnailFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image,
                                      size: 40, color: Colors.grey[600]),
                                  const SizedBox(height: 8),
                                  const Text('Tap to select thumbnail',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.file(
                                    _thumbnailFile!,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Thumbnail Selected: ${_thumbnailFile!.path.split('/').last}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextButton(
                                    onPressed: _pickThumbnail,
                                    child: const Text('Change Thumbnail'),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description Input
                    CustomTextField(
                      // Using your assumed CustomTextField
                      controller: _descriptionController,
                      hintText: 'Enter description...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),

                    // Upload Button
                    state is UploadLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            // Using your assumed CustomButton
                            text: 'Upload Post',
                            onPressed: () => _uploadPost(context),
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
