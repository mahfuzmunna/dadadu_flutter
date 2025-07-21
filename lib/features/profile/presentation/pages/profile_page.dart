// lib/features/profile/presentation/pages/profile_page.dart (UPDATED)

import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_bloc/flutter/material.dart'; // For Flutter_bloc
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart'; // For sharing content
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
    // Access AuthBloc to get current user details for the AppBar title
    final authState = context.watch<AuthBloc>().state;
    String appBarTitle = 'My Profile'; // Default title

    if (viewedUser != null) {
      // Viewing another user's profile
      appBarTitle =
          '${viewedUser!.displayName ?? viewedUser!.username}\'s Profile';
    } else if (authState is AuthAuthenticated) {
      // Viewing current authenticated user's profile
      appBarTitle =
          '${authState.user.displayName ?? authState.user.username}\'s Profile';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .primary), // Changed to settings icon
            tooltip: 'Settings / Preferences',
            onPressed: () {
              // Navigate to settings or preferences page
              context.push('/settings'); // <--- Updated to push to /settings
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
                content: Text(
                  'You have been signed out.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer),
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
            final bool isCurrentUserProfile =
                (viewedUser == null || viewedUser?.uid == currentUser.uid);

            // Dummy data for uploaded videos
            final List<String> dummyVideoUrls = List.generate(
              20,
              (index) => 'https://example.com/video_$index.mp4',
            );

            // Dummy referral link (replace with actual generated link from your backend/logic)
            final String referralLink =
                'https://dadadu.app/invite/${userToDisplay.uid.substring(0, 8)}';

            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Photo with Mood Icon
                  Stack(
                    alignment: Alignment.bottomRight,
                    // Position the mood icon at the bottom-right
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        backgroundImage:
                            userToDisplay.profilePhotoUrl != null &&
                                    userToDisplay.profilePhotoUrl!.isNotEmpty
                                ? NetworkImage(userToDisplay.profilePhotoUrl!)
                                : null,
                        child: userToDisplay.profilePhotoUrl == null ||
                                userToDisplay.profilePhotoUrl!.isEmpty
                            ? Icon(
                                Icons.person_rounded,
                                size: 70,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              )
                            : null,
                      ),
                      // User Mood Icon
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surface, // Background for the mood icon
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .shadow
                                    .withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(
                                    0, 2), // changes position of shadow
                              ),
                            ],
                            border: Border.all(
                              color: Theme.of(context).colorScheme.background,
                              // A border color to create a "cutout" effect
                              width:
                                  3, // Thicker border for more pronounced cutout look
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20, // Smaller radius for the mood icon
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondary, // Background for the actual emoji
                            child: Text(
                              userToDisplay.userModeEmoji ?? '😊',
                              // Use the user's emoji or a default
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontSize:
                                          20), // Adjust font size for consistency
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // User Names
                  // Display Name (Removed, username will be more prominent)
                  // Text(
                  //   '${userToDisplay.firstName ?? ''} ${userToDisplay.lastName ?? ''}',
                  //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  //         // Reduced from displaySmall
                  //         fontWeight: FontWeight.bold,
                  //         color: Theme.of(context).colorScheme.onSurface,
                  //       ),
                  //   textAlign: TextAlign.center,
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                  // const SizedBox(height: 4),
                  // Username
                  Text(
                    '@${userToDisplay.username ?? 'No Username'}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        // Increased from titleMedium to headlineSmall
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        // color: Theme.of(context).colorScheme.onSurface, // Make it more prominent
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Spacing after username

                  // Rank Chip (moved below username)
                  if (userToDisplay.rank != null &&
                      userToDisplay.rank!.isNotEmpty)
                    Chip(
                      avatar: Icon(Icons.star_rounded,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          size: 18),
                      label: Text(userToDisplay.rank!,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer)),
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5), // Adjusted padding
                    ),
                  const SizedBox(
                      height: 16), // Increased spacing after username

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
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                24), // More rounded corners
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
                                SnackBar(
                                    content: Text(
                                        'Following ${userToDisplay.username}')),
                              );
                              // context.read<FriendsBloc>().add(FollowUser(userToDisplay.uid));
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
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
                                SnackBar(
                                    content: Text(
                                        'Unfollowing ${userToDisplay.username}')),
                              );
                              // context.read<FriendsBloc>().add(UnfollowUser(userToDisplay.uid));
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.outline,
                              side: BorderSide(
                                  color: Theme.of(context).colorScheme.outline),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(
                      height: 24), // Increased spacing after the action button

                  // --- Start of New Mood Switch and Badges Section ---
                  if (isCurrentUserProfile)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Mood Switch (Dropdown Menu)
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(
                                Icons.sentiment_satisfied_alt_rounded),
                            label: Text(userToDisplay.userModeEmoji != null
                                ? 'Mood: ${userToDisplay.userModeEmoji}'
                                : 'Set Mood'),
                            onPressed: () {
                              _showMoodSelectionBottomSheet(
                                  context, userToDisplay);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // How Badges Work Button
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.military_tech_outlined),
                            label: const Text('How Badges Work'),
                            onPressed: () {
                              _showBadgesInfoDialog(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              side: BorderSide(
                                  color: Theme.of(context).colorScheme.outline),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  // --- End of New Mood Switch and Badges Section ---

                  // Stats (Followers, Following) - Rank is now shown next to display name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn(context, Icons.people_alt_rounded,
                          '${userToDisplay.followersCount}', 'Followers'),
                      _buildStatColumn(context, Icons.person_add_alt_1_rounded, '${userToDisplay.followingCount}', 'Following'),
                      _buildStatColumn(context, Icons.ondemand_video_rounded,
                          '${dummyVideoUrls.length}', 'Videos'), // Videos count moved to the right
                      // Rank is now displayed next to the name, but you could add 'Badges' or other stats here
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Referral Link Card (Only for current user's profile)
                  if (isCurrentUserProfile)
                    Card(
                      elevation: 2,
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invite Friends & Earn Diamonds!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium // Kept as titleMedium, good for card titles
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Share your unique referral link and earn 100 💎 for every friend who signs up using your link!',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium // Kept as bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant),
                              ),
                              width: double.infinity,
                              child: Text(
                                referralLink,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge // Kept as bodyLarge
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                overflow:
                                    TextOverflow.ellipsis, // Handle long links
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.copy_rounded),
                                    label: const Text('Copy Link'),
                                    onPressed: () async {
                                      await Clipboard.setData(
                                          ClipboardData(text: referralLink));
                                      ScaffoldMessenger.of(context)
                                          .hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Referral link copied to clipboard!')),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: FilledButton.icon(
                                    icon: const Icon(Icons.share_rounded),
                                    label: const Text('Share'),
                                    onPressed: () async {
                                      await Share.share(
                                          'Join me on Dadadu! Use my referral link to sign up and get started: $referralLink');
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  // Spacing after referral card

                  // Match History Card (Only for current user's profile)
                  if (isCurrentUserProfile)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Match History',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                // Reduced from headlineSmall
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 1,
                          color:
                              Theme.of(context).colorScheme.surfaceContainerLow,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.videogame_asset_rounded,
                                    size: 48,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No match history yet.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          // Reduced from titleMedium for better hierarchy
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Play some games to see your results here!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          // Kept bodyMedium
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(
                      height: 32), // Spacing after match history card

                  // My Uploaded Videos Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${userToDisplay.username ?? 'User'}\'s Uploaded Videos (${dummyVideoUrls.length})', // Dynamic title
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            // Reduced from headlineSmall
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
                        isCurrentUserProfile
                            ? 'You haven\'t uploaded any videos yet. Start sharing your moments!'
                            : 'This user has no videos uploaded yet.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              // Kept bodyMedium
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                          child: InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Tapped video ${index + 1} from ${userToDisplay.username}')),
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        // Adjusted from labelMedium
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
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
          } else if (state is AuthUnauthenticated || state is AuthError) {
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
                      'Please sign in to view this profile.',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
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

  Widget _buildStatColumn(
      BuildContext context, IconData icon, String count, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          count,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                // Reduced from headlineMedium
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

  // New method to show the mood selection bottom sheet
  void _showMoodSelectionBottomSheet(BuildContext context, UserEntity user) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Wrap(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select Your Mood',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            ListTile(
              leading: const Text('😊', style: TextStyle(fontSize: 24)),
              title: const Text('Happy'),
              onTap: () {
                // TODO: Dispatch an event to AuthBloc/ProfileBloc to update userModeEmoji
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mood set to Happy!')),
                );
                Navigator.pop(bc);
              },
            ),
            ListTile(
              leading: const Text('😞', style: TextStyle(fontSize: 24)),
              title: const Text('Sad'),
              onTap: () {
                // TODO: Dispatch an event to AuthBloc/ProfileBloc to update userModeEmoji
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mood set to Sad.')),
                );
                Navigator.pop(bc);
              },
            ),
            ListTile(
              leading: const Text('🤩', style: TextStyle(fontSize: 24)),
              title: const Text('Excited'),
              onTap: () {
                // TODO: Dispatch an event to AuthBloc/ProfileBloc to update userModeEmoji
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mood set to Excited!')),
                );
                Navigator.pop(bc);
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  // New method to show the badges info dialog
  void _showBadgesInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.military_tech_rounded,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded( // Added Expanded to allow text to wrap if needed
                child: Text(
                  'Dadadu Badge System',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  overflow: TextOverflow.ellipsis, // Optional: Handle overflow
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Earn badges by achieving various milestones in Dadadu!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 10),
                _buildBadgeInfoRow(context, '🍃', 'LEAF (0 - 9,999 diamonds)',
                    'Starting level for new users.'),
                _buildBadgeInfoRow(
                    context,
                    '☘️',
                    'THREELEAF (10K - 999K diamonds)',
                    'Active community member.'),
                _buildBadgeInfoRow(context, '🎀',
                    'FIVELEAF (1M - 9.9M diamonds)', 'Popular creator status.'),
                _buildBadgeInfoRow(context, '👑', 'DADALORD (10M+ diamonds)',
                    'Elite status worth \$10,000+ with +2% per million diamonds.'),
                const SizedBox(height: 16),
                Text(
                  '📈 Higher badges = more prestige + marketplace value',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                // Text(
                //   '- **First Win Badge**: Awarded for your first game victory.',
                //   style: Theme.of(context).textTheme.bodyMedium,
                // ),
                // Text(
                //   '- **Social Butterfly**: Earned by following 10 friends.',
                //   style: Theme.of(context).textTheme.bodyMedium,
                // ),
                // Text(
                //   '- **Video Creator**: Upload 5 videos to your profile.',
                //   style: Theme.of(context).textTheme.bodyMedium,
                // ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Got It!',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadgeInfoRow(
      BuildContext context, String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
