import 'dart:io';

import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dadadu_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class UploadProfilePhotoPage extends StatefulWidget {
  const UploadProfilePhotoPage({super.key});

  @override
  State<UploadProfilePhotoPage> createState() => _UploadProfilePhotoPageState();
}

class _UploadProfilePhotoPageState extends State<UploadProfilePhotoPage> {
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _onUploadPressed(String userId) {
    if (_pickedImage != null) {
      // Dispatch event to ProfileBloc to handle the upload
      context.read<ProfileBloc>().add(
            UpdateProfilePhoto(userId: userId, photoFile: _pickedImage!),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image first.')));
    }
  }

  void _finalizeOnboarding() {
    // This function transitions the app to the fully authenticated state.
    // The GoRouter redirect logic will then automatically navigate to '/home'.
    final authState = context.read<AuthBloc>().state;
    UserEntity? user;

    if (authState is AuthSignUpSuccess) {
      user = authState.user;
    } else if (authState is AuthAuthenticated) {
      user = authState.user;
    }

    if (user != null) {
      // Dispatching AuthUserChanged ensures the state is AuthAuthenticated,
      // triggering the GoRouter redirect to the home page.
      context.read<AuthBloc>().add(AuthOnboardingComplete(user: user));
    } else {
      // Fallback in case something went wrong
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Get the user from either AuthSignUpSuccess or AuthAuthenticated state.
    final authState = context.watch<AuthBloc>().state;
    UserEntity? user;

    if (authState is AuthSignUpSuccess) {
      user = authState.user;
    } else if (authState is AuthAuthenticated) {
      // The state might have already updated to Authenticated, which is fine.
      user = authState.user;
    }

    // If there's no user in either state, something is wrong.
    if (user == null) {
      // This is a safeguard. You can navigate back or show an error.
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error: User session lost. Please sign in again.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: const Text('Go to Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Prevents a back button
        title: const Text('Add a Profile Photo'),
        centerTitle: true,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            // ✅ FIX: After a successful photo upload, finalize the login process.
            _finalizeOnboarding();
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, profileState) {
          final isLoading = profileState is ProfileLoading;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: isLoading ? null : _pickImage,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : null,
                      child: _pickedImage == null
                          ? Icon(Icons.camera_alt,
                              size: 60,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Make a great first impression!',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 48),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16)),
                            onPressed: _pickedImage == null
                                ? null // Disable button if no image is picked
                                : () => _onUploadPressed(user!.id),
                            child: const Text('Upload and Continue'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          // ✅ FIX: The skip button now also uses the robust finalize function.
                          onPressed: _finalizeOnboarding,
                          child: const Text('Skip for Now'),
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
