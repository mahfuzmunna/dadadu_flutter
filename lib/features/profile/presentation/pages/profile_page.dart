import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
// You might need a ProfileBloc or FriendsBloc for Follow/Unfollow logic
// import 'package:dadadu_app/features/profile/presentation/bloc/profile_bloc.dart';
// import 'package:dadadu_app/features/friends/presentation/bloc/friends_bloc.dart';


class ProfilePage extends StatelessWidget {
  // This user will be null if viewing the current authenticated user's profile (from AuthBloc).
  // It will be provided if navigating to another user's profile.
  final UserEntity? viewedUser;

  const ProfilePage({
    super.key,
    this.viewedUser, // Accepts an optional UserEntity
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          viewedUser != null ? '${viewedUser!.username}\'s Profile' : 'My Profile', // Dynamic title
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded, color: Theme.of(context).colorScheme.primary), // Changed to settings icon
            tooltip: 'Settings / Preferences',
            onPressed: () {
              // Navigate to settings or preferences page
              // context.push('/settings'); // Example navigation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings button pressed!')),
              );
            },
          ),
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
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AuthAuthenticated) {
            // Determine which user's profile to display:
            // If viewedUser is provided, use that. Otherwise, use the current authenticated user.
            final UserEntity currentUser = state.user;
            final UserEntity userToDisplay = viewedUser ?? currentUser;

            // Check if this is the current authenticated user's profile
            final bool isCurrentUserProfile = (viewedUser == null || viewedUser?.uid == currentUser.uid);

            // Dummy data for uploaded videos
            final List<String> dummyVideoUrls = List.generate(
              20,
                  (index) => 'https://example.com/video_$index.mp4',
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Photo
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    backgroundImage: userToDisplay.profilePhotoUrl != null && userToDisplay.profilePhotoUrl!.isNotEmpty
                        ? NetworkImage(userToDisplay.profilePhotoUrl!)
                        : null,
                    child: userToDisplay.profilePhotoUrl == null || userToDisplay.profilePhotoUrl!.isEmpty
                        ? Icon(
                      Icons.person_rounded,
                      size: 70,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    )
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // User Names
                  Text(
                    '${userToDisplay.firstName ?? ''} ${userToDisplay.lastName ?? ''}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${userToDisplay.username ?? 'No Username'}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16), // Increased spacing after username

                  // Dynamic Action Button (Edit Profile or Follow/Unfollow)
                  if (isCurrentUserProfile)
                    SizedBox(
                      width: 200, // Fixed width for the button
                      child: FilledButton.icon(
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Edit Profile'),
                        onPressed: () {
                          context.push('/editProfile');
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24), // More rounded corners
                          ),
                        ),
                      ),
                    )
                  else
                  // This section assumes you have a way to determine if you are already following
                  // For now, it's a simple toggle placeholder.
                  // You'd typically need to check `currentUser.following.contains(userToDisplay.uid)`
                  // and dispatch events to a `FriendsBloc` or `ProfileBloc`
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150, // Example width
                          child: FilledButton.icon(
                            icon: const Icon(Icons.person_add_rounded),
                            label: const Text('Follow'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Following ${userToDisplay.username}')),
                              );
                              // context.read<FriendsBloc>().add(FollowUser(userToDisplay.uid));
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 150, // Example width
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.person_remove_rounded),
                            label: const Text('Unfollow'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Unfollowing ${userToDisplay.username}')),
                              );
                              // context.read<FriendsBloc>().add(UnfollowUser(userToDisplay.uid));
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.outline,
                              side: BorderSide(color: Theme.of(context).colorScheme.outline),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24), // Increased spacing after the action button

                  // User Mode/Rank as a Chip
                  Chip(
                    avatar: Icon(
                      Icons.star,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      size: 18,
                    ),
                    label: Text(
                      '${userToDisplay.userModeEmoji ?? '😊'} ${userToDisplay.rank ?? 'Newbie'}',
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
                      _buildStatColumn(context, Icons.people_alt_rounded, '${userToDisplay.followersCount}', 'Followers'),
                      _buildStatColumn(context, Icons.person_add_alt_1_rounded, '${userToDisplay.followingCount}', 'Following'),
                      _buildStatColumn(context, Icons.videocam_rounded, '${userToDisplay.uploadedVideoUrls?.length ?? dummyVideoUrls.length}', 'Videos'),
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
                    elevation: 1,
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          userToDisplay.displayName ?? (isCurrentUserProfile ? 'No bio provided. Click "Edit Profile" to add one!' : 'This user has not provided a bio.'),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign Out Button (Only for current user's profile)
                  if (isCurrentUserProfile)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Sign Out'),
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthSignOutRequested());
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(context).colorScheme.onError,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32), // Add spacing even if button is not there

                  // My Uploaded Videos Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${userToDisplay.username ?? 'User'}\'s Uploaded Videos (${dummyVideoUrls.length})', // Dynamic title
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
                        isCurrentUserProfile ? 'You haven\'t uploaded any videos yet. Start sharing your moments!' : 'This user has no videos uploaded yet.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: dummyVideoUrls.length,
                      itemBuilder: (context, index) {
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          color: Theme.of(context).colorScheme.surfaceContainerHigh,
                          child: InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Tapped video ${index + 1} from ${userToDisplay.username}')),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_circle_filled_rounded,
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
                      'Please sign in to view this profile.', // Changed message
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.go('/signIn'),
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
          return const Center(child: Text('An unexpected error occurred.'));
        },
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, IconData icon, String count, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          count,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}