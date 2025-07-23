// lib/features/profile/presentation/pages/edit_profile_page.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dadadu_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_editor_plus/options.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _bioController;

  File? _editedImageFile;
  UserEntity? _currentUser;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUser = authState.user;
    }
    _usernameController = TextEditingController(text: _currentUser?.username ?? '');
    _fullNameController =
        TextEditingController(text: _currentUser?.fullName ?? '');
    _bioController = TextEditingController(text: _currentUser?.bio ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndEditImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (pickedFile == null) return;

    final imageData = await File(pickedFile.path).readAsBytes();

    if (!mounted) return;
    final Uint8List? editedImageBytes = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageEditor(
          image: imageData,
          cropOption: const CropOption(),
        ),
      ),
    );

    if (editedImageBytes != null) {
      final tempDir = await getTemporaryDirectory();
      final tempFile = await File(
              '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg')
          .writeAsBytes(editedImageBytes);

      setState(() {
        _editedImageFile = tempFile;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentUser == null) return;

      if (_editedImageFile != null) {
        context.read<ProfileBloc>().add(UpdateProfilePhoto(
            userId: _currentUser!.id, photoFile: _editedImageFile!));
      }

      final updatedUserData = _currentUser!.copyWith(
        username: _usernameController.text.trim(),
        fullName: _fullNameController.text.trim(),
        bio: _bioController.text.trim(),
      );

      context
          .read<ProfileBloc>()
          .add(UpdateUserProfileData(user: updatedUserData));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
          body: Center(child: Text('User not authenticated.')));
    }
    _currentUser = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        // ✅ The 'Save' button has been removed from here.
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, profileState) {
          if (profileState is ProfileUpdateSuccess) {
            context.read<AuthBloc>().add(const AuthRefreshCurrentUser());
            // Show a success message before popping
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (profileState is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed to update: ${profileState.message}')),
            );
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            final isLoading = profileState is ProfileLoading;

            return AbsorbPointer(
              absorbing: isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickAndEditImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 70,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              backgroundImage: _editedImageFile != null
                                  ? FileImage(_editedImageFile!)
                                      as ImageProvider
                                  : (_currentUser?.profilePhotoUrl != null &&
                                          _currentUser!.profilePhotoUrl!.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                          _currentUser!.profilePhotoUrl!)
                                      : null),
                              child: (_editedImageFile == null &&
                                      (_currentUser?.profilePhotoUrl == null ||
                                          _currentUser!
                                              .profilePhotoUrl!.isEmpty))
                                  ? Icon(
                                      Icons.person,
                                      size: 70,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.edit,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder()),
                        validator: (v) =>
                            v!.isEmpty ? 'Username cannot be empty' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                            labelText: 'Bio', border: OutlineInputBorder()),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                      // ✅ NEW: Save button moved here and styled
                      if (isLoading)
                        const CircularProgressIndicator()
                      else
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _saveProfile,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Save Changes',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}