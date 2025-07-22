import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For PUT request
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p; // For path.basename
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs, add uuid: ^latest_version to pubspec.yaml

// Assuming PostEntity is defined and Supabase is initialized

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _pickedVideoFile;
  String? _uploadStatus;
  bool _isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  final SupabaseClient supabase = Supabase.instance.client;
  final Uuid uuid = const Uuid();

  @override
  void dispose() {
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedVideoFile = File(pickedFile.path);
        _uploadStatus = null;
      });
    }
  }

  Future<void> _uploadVideoAndThumbnail() async {
    if (_pickedVideoFile == null) {
      _showSnackBar('Please select a video first.');
      return;
    }
    if (supabase.auth.currentUser == null) {
      _showSnackBar('You must be logged in to upload.');
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadStatus = 'Starting upload...';
    });

    try {
      final String currentUserId = supabase.auth.currentUser!.id;
      final String uniquePostId =
          uuid.v4(); // Generate a unique ID for the post

      // 1. **Initial Post Creation (Optional, but useful for tracking)**
      // Create a pending post entry in the database. You might mark it as 'pending'
      // or only insert final URLs later. For simplicity here, we create it and update.
      _showSnackBar('Creating post entry...');
      final initialPostResponse = await supabase.from('posts').insert({
        'id': uniquePostId,
        'user_id': currentUserId,
        'description': _descriptionController.text.trim(),
        'tag': _tagController.text.trim().isEmpty
            ? 'Entertainment'
            : _tagController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
        // video_url and thumbnail_url will be updated later
      }).select();

      // if (initialPostResponse.error != null) {
      //   throw initialPostResponse.error!;
      // }
      _showSnackBar('Post entry created. Uploading files...');

      final fileName = p.basename(_pickedVideoFile!.path);
      final videoContentType = 'video/mp4'; // Adjust based on actual video type
      final thumbnailContentType = 'image/jpeg'; // Assuming JPEG for thumbnails

      // --- Upload Video ---
      _uploadStatus = 'Getting video upload URL...';
      final videoSignedUrlResponse = await supabase.functions.invoke(
        'create-signed-url',
        body: {
          'filename': fileName,
          'contentType': videoContentType,
        },
      );

      // if (videoSignedUrlResponse.error != null) {
      //   throw videoSignedUrlResponse.error!;
      // }
      final videoSignedUrlData =
          videoSignedUrlResponse.data as Map<String, dynamic>;
      final String videoUploadUrl = videoSignedUrlData['signedUrl'];
      final String videoFileKey =
          videoSignedUrlData['fileKey']; // Path in Wasabi

      setState(() {
        _uploadStatus = 'Uploading video to Wasabi...';
      });
      final videoBytes = await _pickedVideoFile!.readAsBytes();
      final videoUploadResult = await http.put(
        Uri.parse(videoUploadUrl),
        headers: {
          'Content-Type': videoContentType,
        },
        body: videoBytes,
      );

      if (videoUploadResult.statusCode != 200) {
        throw Exception(
            'Failed to upload video to Wasabi: ${videoUploadResult.body}');
      }
      _showSnackBar('Video uploaded. Generating thumbnail...');

      // --- Generate and Upload Thumbnail ---
      // For a real app, you would use a package like 'video_thumbnail'
      // to generate a thumbnail from the picked video file.
      // Example using video_thumbnail:
      // final Uint8List? thumbnailBytes = await VideoThumbnail.thumbnailData(
      //   video: _pickedVideoFile!.path,
      //   imageFormat: ImageFormat.JPEG,
      //   quality: 75,
      // );
      // if (thumbnailBytes == null) throw Exception('Could not generate thumbnail.');
      // final thumbnailFile = File('${_pickedVideoFile!.path}_thumb.jpeg')..writeAsBytesSync(thumbnailBytes);
      // final thumbnailFileName = p.basename(thumbnailFile.path);

      // For this example, let's use a placeholder thumbnail path
      final String thumbnailFileName =
          fileName.replaceFirst('.mp4', '_thumb.jpeg');
      final String thumbnailFileKey = videoFileKey.replaceFirst(
          '.mp4', '_thumb.jpeg'); // Follows same path structure

      // Dummy thumbnail for demonstration. In a real app, this would be a real upload.
      // You'd repeat the signed URL process for the thumbnail here.
      final String dummyThumbnailUploadUrl = videoUploadUrl.replaceFirst(
          fileName, thumbnailFileName); // Simplified
      final dummyThumbnailBytes =
          (await http.get(Uri.parse('https://via.placeholder.com/150')))
              .bodyBytes; // Dummy
      await http.put(
        Uri.parse(dummyThumbnailUploadUrl),
        headers: {'Content-Type': thumbnailContentType},
        body: dummyThumbnailBytes,
      );
      // End dummy thumbnail part

      _showSnackBar('Thumbnail uploaded. Recording URLs...');

      // --- Record asset URLs in Supabase Postgres ---
      final recordAssetResponse = await supabase.functions.invoke(
        'record-post-asset', // Your Edge Function name
        body: {
          'postId': uniquePostId,
          'fileKey': videoFileKey,
          'assetType': 'video',
        },
      );

      // if (recordAssetResponse.error != null) {
      //   throw recordAssetResponse.error!;
      // }

      final recordThumbnailResponse = await supabase.functions.invoke(
        'record-post-asset', // Your Edge Function name
        body: {
          'postId': uniquePostId,
          'fileKey': thumbnailFileKey,
          'assetType': 'thumbnail',
        },
      );

      // if (recordThumbnailResponse.error != null) {
      //   throw recordThumbnailResponse.error!;
      // }

      _showSnackBar('Upload and database update successful!');
      setState(() {
        _pickedVideoFile = null;
        _descriptionController.clear();
        _tagController.clear();
        _uploadStatus = 'Video uploaded successfully!';
      });

      // You can now navigate to another screen or show a success message
    } catch (e) {
      setState(() {
        _uploadStatus = 'Upload failed: ${e.toString()}';
      });
      debugPrint('Upload Error: $e');
      _showSnackBar('Upload failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Video')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_pickedVideoFile != null)
                Text('Selected: ${p.basename(_pickedVideoFile!.path)}'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.video_library),
                label: const Text('Pick Video'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'Tag (e.g., Entertainment, Comedy)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 10),
                        Text(_uploadStatus ?? 'Processing...'),
                      ],
                    )
                  : ElevatedButton.icon(
                      onPressed: _uploadVideoAndThumbnail,
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload Video'),
                    ),
              if (_uploadStatus != null && !_isLoading)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_uploadStatus!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
