// lib/features/profile/presentation/pages/edit_profile_page.dart

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart'; // For displaying existing network images
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dadadu_app/features/profile/presentation/bloc/profile_bloc.dart'; // Import ProfileBloc
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _lastNameController;
  late TextEditingController
      _bioController; // Renamed for clarity (was _displayNameController)

  File? _pickedImageFile;
  UserEntity? _currentUser; // Holds the user data initially loaded from AuthBloc

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data from AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // Corrected state name
      _currentUser = authState.user;
    }

    _usernameController = TextEditingController(text: _currentUser?.username ?? '');
    _fullNameController =
        TextEditingController(text: _currentUser?.fullName ?? '');
    _bioController =
        TextEditingController(text: _currentUser?.bio ?? ''); // Use bio field
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImageFile = File(image.path);
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No current user to update.')),
        );
        return;
      }
      if (_currentUser != null) {
        // Create an updated UserEntity from the form inputs
        final updatedUser = _currentUser!.copyWith(
          username: _usernameController.text,
          fullName: _fullNameController.text,
          bio: _bioController.text,
          // Update bio
          profilePhotoUrl: _currentUser?.profilePhotoUrl,
          isEmailConfirmed: _currentUser!.isEmailConfirmed,
          moodStatus: _currentUser!.moodStatus as String,
          language: _currentUser!.language,
          discoverMode: _currentUser!.discoverMode,
          followersCount: _currentUser!.followersCount,
          followingCount: _currentUser!.followingCount,
          postCount: _currentUser!.postCount as int,
          createdAt: _currentUser!.createdAt,
          updatedAt: _currentUser!.updatedAt,
          rank: _currentUser!.rank,
          referralLink: _currentUser!.referralLink,
          id: _currentUser!.id,
          email: _currentUser!.email as String,
          latitude: _currentUser!.latitude,
          longitude: _currentUser!.longitude,
          location: _currentUser!.location,
        );

        // Dispatch the UpdateUserProfile event to ProfileBloc
        context.read<ProfileBloc>().add(UpdateUserProfile(user: updatedUser));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile Error')),
        body: const Center(
          child: Text('User not authenticated. Please log in to edit your profile.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      // BlocListener for ProfileBloc to handle save success/failure
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, profileState) {
          if (profileState is ProfileLoading) {
            // Show a loading indicator (e.g., a full-screen overlay or dialog)
            // For simplicity, we'll just show a snackbar here, but a modal dialog is better.
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saving profile...')),
            );
          } else if (profileState is ProfileUpdating) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Profile updated successfully!',
                  style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                ),
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
              ),
            );
            // After successful update, tell AuthBloc to refresh its user data
            context.read<AuthBloc>().add(const AuthRefreshCurrentUser());
            context.pop(); // Go back to ProfilePage
          } else if (profileState is ProfileError) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to update profile: ${profileState.message}',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer),
                ),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
              ),
            );
          }
        },
        // BlocListener for AuthBloc to react to global auth changes (like sign out)
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            if (authState is AuthUnauthenticated) {
              // Corrected state name
              context.go('/signIn'); // Redirect to sign in if unauthenticated
            } else if (authState is AuthAuthenticated &&
                authState.user != _currentUser) {
              // If the user data in AuthBloc updates (e.g., another device updated profile),
              // refresh the local controllers to reflect the latest data.
              // Note: This might cause issues if user is actively typing.
              // A more robust solution might involve a "refresh" button or
              // only updating if not actively editing.
              setState(() {
                _currentUser = authState.user;
                _usernameController.text = _currentUser?.username ?? '';
                _fullNameController.text = _currentUser?.fullName ?? '';
                _bioController.text = _currentUser?.bio ?? ''; // Update bio
                _pickedImageFile =
                    null; // Clear picked file if data came from external update
              });
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      backgroundImage: _pickedImageFile != null
                          ? FileImage(_pickedImageFile!) as ImageProvider
                          : (_currentUser?.profilePhotoUrl != null &&
                                  _currentUser!.profilePhotoUrl!.isNotEmpty
                              ? CachedNetworkImageProvider(_currentUser!
                                  .profilePhotoUrl!) // Use CachedNetworkImage
                              : null),
                      child: (_pickedImageFile == null &&
                              (_currentUser?.profilePhotoUrl == null ||
                                  _currentUser!.profilePhotoUrl!.isEmpty))
                          ? Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            )
                          : null,
                    ),
                  ),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text('Change Profile Picture'),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                        labelText: 'Username', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                        labelText: 'First Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),

                  // Bio TextFormField
                  TextFormField(
                    controller: _bioController, // Use _bioController
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell us about yourself...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save Profile',
                        style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}