// lib/features/profile/presentation/pages/edit_profile_page.dart

import 'dart:io'; // Required for File class when handling picked images
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart'; // For picking images from gallery
import 'package:go_router/go_router.dart'; // For navigation
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart'; // To access AuthBloc
// import 'package:dadadu_app/features/auth/presentation/bloc/auth_state.dart'; // To access AuthState
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart'; // To access UserEntity

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>(); // Key for the form to validate inputs
  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _displayNameController; // Used for a general 'Display Name' or 'Bio'

  File? _pickedImageFile; // Stores the File object of the newly picked image
  UserEntity? _currentUser; // Holds the user data initially loaded from AuthBloc

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data from AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUser = authState.user;
    }

    // Assign initial values to text controllers. Use null-aware operator
    // to provide empty string if data is null to avoid issues.
    _usernameController = TextEditingController(text: _currentUser?.username ?? '');
    _firstNameController = TextEditingController(text: _currentUser?.firstName ?? '');
    _lastNameController = TextEditingController(text: _currentUser?.lastName ?? '');
    _displayNameController = TextEditingController(text: _currentUser?.displayName ?? '');
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImageFile = File(image.path); // Update the state with the new image file
      });
    }
  }

  // Function to handle saving the profile (placeholder for now)
  void _saveProfile() {
    if (_formKey.currentState!.validate()) { // Validate all form fields
      _formKey.currentState!.save(); // Save the form (though not strictly necessary for TextEditingControllers)

      // TODO: Implement actual save logic here in the next phase.
      // This will typically involve:
      // 1. Dispatching an event to a ProfileBloc/Cubit (e.g., UpdateProfileRequested).
      // 2. If _pickedImageFile is not null, upload it to Firebase Storage first.
      // 3. Update user data in Firestore with new text field values and the new photo URL.
      // 4. Update the AuthBloc's state with the new UserEntity.

      print('--- Saving Profile Details (Dummy) ---');
      print('Username: ${_usernameController.text}');
      print('First Name: ${_firstNameController.text}');
      print('Last Name: ${_lastNameController.text}');
      print('Display Name (Bio): ${_displayNameController.text}');
      print('New Profile Image Path: ${_pickedImageFile?.path ?? "No new image selected"}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved (dummy). Real save coming soon!')),
      );
      // Uncomment the line below to pop back to the previous screen (ProfilePage)
      // once the actual save logic is implemented and successful.
      // context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If _currentUser is null, it means the AuthBloc state was not Authenticated
    // when this page was initialized. This is a safety check.
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
      // BlocListener is used here to react to state changes in AuthBloc.
      // For instance, if the user logs out from another part of the app
      // while on the edit profile page, this listener can redirect them.
      // It can also be used to refresh fields if the AuthBloc's user state updates.
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            // If user becomes unauthenticated, navigate to sign in
            context.go('/signIn');
          } else if (state is Authenticated && state.user != _currentUser) {
            // If the user data in AuthBloc updates (e.g., after a successful save),
            // refresh the local controllers to reflect the latest data.
            _currentUser = state.user;
            _usernameController.text = _currentUser?.username ?? '';
            _firstNameController.text = _currentUser?.firstName ?? '';
            _lastNameController.text = _currentUser?.lastName ?? '';
            _displayNameController.text = _currentUser?.displayName ?? '';
            // If the profile photo URL changed externally (not via this page yet), update it.
            // _pickedImageFile = null; // Clear picked file if data came from external update
            setState(() {}); // Rebuild the widget to show updated info/image
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Associate the form key
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage, // Tapping the avatar area also triggers image picker
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    // Display either the newly picked image or the current network image
                    backgroundImage: _pickedImageFile != null
                        ? FileImage(_pickedImageFile!) as ImageProvider // New image from gallery
                        : (_currentUser?.profilePhotoUrl != null && _currentUser!.profilePhotoUrl!.isNotEmpty
                        ? NetworkImage(_currentUser!.profilePhotoUrl!) // Existing network image
                        : null), // No image available
                    child: (_pickedImageFile == null && (_currentUser?.profilePhotoUrl == null || _currentUser!.profilePhotoUrl!.isEmpty))
                        ? Icon(
                      Icons.camera_alt, // Show camera icon if no image
                      size: 50,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    )
                        : null,
                  ),
                ),
                TextButton(
                  onPressed: _pickImage, // Button to explicitly pick image
                  child: const Text('Change Profile Picture'),
                ),
                const SizedBox(height: 24),

                // Username TextFormField
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username cannot be empty'; // Validation for username
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // First Name TextFormField
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),

                // Last Name TextFormField
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),

                // Display Name/Bio TextFormField
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Bio / Display Name',
                    hintText: 'Tell us about yourself...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3, // Allow multiple lines for bio
                ),
                const SizedBox(height: 32),

                // Save Profile Button
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // Make button full width
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save Profile', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}