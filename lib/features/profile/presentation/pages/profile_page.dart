import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
// Ensure your AuthState is correctly defined, likely in auth_bloc.dart itself
// import 'package:dadadu_app/features/auth/presentation/bloc/auth_state.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic visual structure, allowing for a page-specific AppBar.
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true, // Center the app bar title for a cleaner look
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
            tooltip: 'Edit Profile',
            onPressed: () {
              context.push('/editProfile'); // Navigate to edit profile page
            },
          ),
          // Adding a small gap to the edge for better visual balance
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('You have been signed out.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                ),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
              ),
            );
            // The GoRouter redirect in app_router.dart should handle navigation to signIn page.
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AuthAuthenticated) {
            final UserEntity user = state.user;

            // Dummy data for uploaded videos to ensure scrollability and visual demo
            final List<String> dummyVideoUrls = List.generate(
              20, // Generate 20 dummy video entries
                  (index) => 'https://example.com/video_$index.mp4', // Dummy URL
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Photo
                  CircleAvatar(
                    radius: 70, // Slightly larger avatar
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    backgroundImage: user.profilePhotoUrl != null && user.profilePhotoUrl!.isNotEmpty
                        ? NetworkImage(user.profilePhotoUrl!)
                        : null,
                    child: user.profilePhotoUrl == null || user.profilePhotoUrl!.isEmpty
                        ? Icon(
                      Icons.person_rounded, // Rounded person icon
                      size: 70,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    )
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // User Names
                  Text(
                    '${user.firstName ?? ''} ${user.lastName ?? ''}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith( // Larger, more prominent name
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.username ?? 'No Username'}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
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

                  // User Mode/Rank as a Chip
                  Chip(
                    avatar: Icon(
                      Icons.star, // Example icon for rank/mode
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      size: 18,
                    ),
                    label: Text(
                      '${user.userModeEmoji ?? '😊'} ${user.rank ?? 'Newbie'}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats (Followers, Following, Videos)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn(context, Icons.people_alt_rounded, '${user.followersCount}', 'Followers'),
                      _buildStatColumn(context, Icons.person_add_alt_1_rounded, '${user.followingCount}', 'Following'),
                      _buildStatColumn(context, Icons.videocam_rounded, '${user.uploadedVideoUrls?.length ?? dummyVideoUrls.length}', 'Videos'),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // About Me Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'About Me',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1, // Subtle elevation for the card
                    color: Theme.of(context).colorScheme.surfaceContainerLow, // Material 3 surface color
                    margin: EdgeInsets.zero, // Remove default card margin
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity, // Expand to fill width
                        child: Text(
                          user.displayName ?? 'No bio provided. Click edit profile to add one!',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon( // Using FilledButton for more prominence
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign Out'),
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthSignOutRequested());
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error, // Error color for sign out
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // My Uploaded Videos Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'My Uploaded Videos (${dummyVideoUrls.length})', // Display count based on dummy data for demo
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (dummyVideoUrls.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No videos uploaded yet. Start sharing your moments!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                  // GridView for displaying uploaded videos
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10, // Increased spacing
                        mainAxisSpacing: 10, // Increased spacing
                        childAspectRatio: 0.7, // Adjust aspect ratio of each video thumbnail
                      ),
                      itemCount: dummyVideoUrls.length,
                      itemBuilder: (context, index) {
                        return Card( // Use Card for each video thumbnail
                          clipBehavior: Clip.antiAlias, // For rounded corners on image/content
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          color: Theme.of(context).colorScheme.surfaceContainerHigh,
                          child: InkWell( // Make the card tappable
                            onTap: () {
                              // Handle video tap, e.g., navigate to video player
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Tapped video ${index + 1}')),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_circle_filled_rounded, // Play icon
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Video ${index + 1}',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          }
          // Fallback for unauthenticated or error state (though redirects should handle auth status)
          else if (state is AuthUnauthenticated || state is AuthError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_person_rounded,
                      size: 80,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Please sign in to view your profile.',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.go('/signIn'), // Use go for full redirect
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Go to Sign In'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          // Generic fallback
          return const Center(child: Text('An unexpected error occurred.'));
        },
      ),
    );
  }

  // Helper function to build stat columns (Followers, Following, Videos) with an icon
  Widget _buildStatColumn(BuildContext context, IconData icon, String count, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary), // Added icon
        const SizedBox(height: 4),
        Text(
          count,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith( // Slightly larger count
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith( // Smaller label
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}