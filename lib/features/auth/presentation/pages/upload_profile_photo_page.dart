import 'dart:io';
import 'dart:typed_data';

import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dadadu_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart' hide AspectRatio;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_editor_plus/options.dart';
import 'package:image_picker/image_picker.dart'; // Keep image_picker for selecting
import 'package:path_provider/path_provider.dart';

import '../../../../l10n/app_localizations.dart';

class UploadProfilePhotoPage extends StatefulWidget {
  const UploadProfilePhotoPage({super.key});

  @override
  State<UploadProfilePhotoPage> createState() => _UploadProfilePhotoPageState();
}

class _UploadProfilePhotoPageState extends State<UploadProfilePhotoPage> {
  File? _editedImageFile;
  final ImagePicker _picker = ImagePicker();

  // ✅ UPDATED: A new robust method to handle both picking and editing
  Future<void> _pickAndEditImage() async {
    // 1. Pick an image using the standard image_picker
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90, // Use higher quality for editing
    );

    if (pickedFile == null) return; // User cancelled the picker

    // 2. Read the picked image file as bytes
    final imageData = await File(pickedFile.path).readAsBytes();

    // 3. Push to the ImageEditor page, now providing the image data
    final Uint8List? editedImageBytes = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageEditor(
          image: imageData, // Pass the image data to the editor
          cropOption: CropOption(ratios: [AspectRatio(title: '1:1')]),
        ),
      ),
    );

    if (editedImageBytes != null) {
      // 4. Save the edited image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = await File(
              '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg')
          .writeAsBytes(editedImageBytes);

      setState(() {
        _editedImageFile = tempFile;
      });
    }
  }

  // No changes needed to your BLoC interaction logic
  void _onUploadPressed(String userId) {
    if (_editedImageFile != null) {
      context.read<ProfileBloc>().add(
            UpdateProfilePhoto(userId: userId, photoFile: _editedImageFile!),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context)!.pleaseSelectAndEditImage)));
    }
    _finalizeOnboarding();
  }

  void _finalizeOnboarding() {
    final authState = context.read<AuthBloc>().state;
    UserEntity? user;
    if (authState is AuthSignUpSuccess) {
      user = authState.user;
    } else if (authState is AuthAuthenticated) {
      user = authState.user;
    }
    if (user != null) {
      context.read<AuthBloc>().add(AuthOnboardingComplete(user: user));
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This logic for getting the user is correct
    final authState = context.watch<AuthBloc>().state;
    UserEntity? user;
    if (authState is AuthSignUpSuccess) {
      user = authState.user;
    } else if (authState is AuthAuthenticated) {
      user = authState.user;
    }
    if (user == null) {
      return Scaffold(/* ... your error UI ... */);
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.setYourProfilePhoto),
        centerTitle: true,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            _finalizeOnboarding();
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, profileState) {
          final isLoading = profileState is ProfileLoading;
          final ColorScheme colorScheme = Theme.of(context).colorScheme;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: isLoading ? null : _pickAndEditImage,
                    // Use the new method
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: colorScheme.primaryContainer,
                      backgroundImage: _editedImageFile != null
                          ? FileImage(_editedImageFile!)
                          : null,
                      child: _editedImageFile == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 40,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context)!.addPhoto,
                                  style: TextStyle(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.greatFirstImpression,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 48),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.icon(
                          icon: const Icon(Icons.cloud_upload_rounded),
                          label: Text(
                              AppLocalizations.of(context)!.uploadAndContinue),
                          style: FilledButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16)),
                          onPressed: _editedImageFile == null
                              ? null
                              : () => _onUploadPressed(user!.id),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _finalizeOnboarding,
                          child: Text(AppLocalizations.of(context)!.skipForNow),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}