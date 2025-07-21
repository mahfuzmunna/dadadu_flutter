import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// import 'package:dadadu_app/features/auth/presentation/bloc/auth_state.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // The Scaffold provides the basic visual structure, including the AppBar.
    // This is fine to have even when nested inside a ShellRoute's body,
    // as it allows for a page-specific AppBar.
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // In ProfilePage's AppBar actions:
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () {
              context.push('/editProfile'); // <-- Make sure this line is exactly here
            },
          ),
        ],
      ),
      // The body contains the main content of the page.
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // This listener is important for reacting to authentication state changes,
          // for example, when a user signs out.
          if (state is AuthUnauthenticated) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'You have been signed out.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                ),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
              ),
            );
            // The GoRouter redirect in app_router.dart should handle navigation
            // to signIn page.
          }
        },
        builder: (context, state) {
          // Show a loading indicator if the authentication state is still being determined.
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // Display the user's profile if they are authenticated.
          else if (state is AuthAuthenticated) {
            final UserEntity user = state.user;

            // --- IMPORTANT FOR TESTING SCROLLABILITY ---
            // This dummy list ensures that the "My Uploaded Videos" section
            // generates enough items to make the page scroll, even if the
            // actual user.uploadedVideoUrls is empty or short.
            final List<String> dummyVideoUrls = List.generate(
              20, // Generate 20 dummy video entries
                  (index) => 'https://example.com/video_$index.mp4', // Dummy URL
            );
            // -------------------------------------------

            return SingleChildScrollView( // <--- THIS WIDGET MAKES THE CONTENT SCROLLABLE
              padding: const EdgeInsets.all(24.0), // Padding around the entire content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center items horizontally
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      backgroundImage: user.profilePhotoUrl != null && user.profilePhotoUrl!.isNotEmpty
                          ? NetworkImage(user.profilePhotoUrl!)
                          : null,
                      child: user.profilePhotoUrl == null || user.profilePhotoUrl!.isEmpty
                          ? Icon(
                        Icons.person,
                        size: 60,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${user.firstName ?? ''} ${user.lastName ?? ''}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '@${user.username ?? 'No Username'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email ?? 'No Email',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${user.userModeEmoji ?? '😊'} ${user.rank ?? 'Newbie'}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn(context, '${user.followersCount}', 'Followers'),
                      _buildStatColumn(context, '${user.followingCount}', 'Following'),
                      // Use actual user data for video count if available, otherwise dummy.
                      _buildStatColumn(context, '${user.uploadedVideoUrls?.length ?? dummyVideoUrls.length}', 'Videos'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'About Me:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.displayName ?? 'No bio provided.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthSignOutRequested());
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(color: Theme.of(context).colorScheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'My Uploaded Videos (${dummyVideoUrls.length}):', // Display count based on dummy data for demo
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Conditionally display message or GridView
                  if (dummyVideoUrls.isEmpty) // Check dummy list for demo
                    Text(
                      'No videos uploaded yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                  // GridView.builder for displaying uploaded videos
                    GridView.builder(
                      shrinkWrap: true, // Crucial: Makes GridView only take as much space as its children, preventing infinite height errors.
                      physics: const NeverScrollableScrollPhysics(), // Crucial: Disables GridView's own scrolling, allowing the parent SingleChildScrollView to handle it.
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.7, // Adjust aspect ratio of each video thumbnail
                      ),
                      itemCount: dummyVideoUrls.length, // Use dummy list count for demo
                      itemBuilder: (context, index) {
                        // In a real app, you would use user.uploadedVideoUrls[index]
                        // and load a video thumbnail or actual video player.
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.videocam,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          }
          // Fallback if authentication state is not handled, though redirects should prevent this.
          return const Center(child: Text('User data not available or session expired.'));
        },
      ),
    );
  }

  // Helper function to build stat columns (Followers, Following, Videos)
  Widget _buildStatColumn(BuildContext context, String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}