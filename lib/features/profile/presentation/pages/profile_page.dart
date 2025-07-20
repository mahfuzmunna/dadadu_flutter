import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart'; // For emojis
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../../../../injection_container.dart'; // For ProfileBloc
// import '../../../../url_launcher.dart'; // For launching URLs

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Referral Link (you'd generate this dynamically in a real app)
  final String _referralLink = "https://your.app.com/invite?ref=USER_ID_HERE";

  @override
  void initState() {
    super.initState();
    // Dispatch event to load user profile when the page is initialized
    // Ensure AuthBloc has provided the current user UID
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ProfileBloc>().add(LoadUserProfile(uid: authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    // We'll primarily listen to ProfileBloc for profile data
    // AuthBloc is used to get the initial UID and for sign out
    final authState = context.watch<AuthBloc>().state;

    return BlocProvider(
      // Provide ProfileBloc specific to this subtree
      create: (context) => sl<ProfileBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                BlocProvider.of<AuthBloc>(context).add(SignOutRequested());
              },
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            UserEntity? userProfile;
            if (profileState is ProfileLoaded) {
              userProfile = profileState.user;
            } else if (profileState is ProfileLoading &&
                context.read<AuthBloc>().state is Authenticated) {
              // Show a loading indicator if the initial fetch is happening
              // but we have a logged-in user to avoid a flash of error
              return const Center(child: CircularProgressIndicator());
            } else if (profileState is ProfileError) {
              return Center(
                child: Text('Error loading profile: ${profileState.message}'),
              );
            }

            // Fallback to AuthBloc's user if ProfileBloc hasn't loaded yet
            // This ensures some data is shown even if profile isn't fully loaded
            final UserEntity? currentUser = (authState is Authenticated)
                ? (userProfile ?? authState.user)
                : null;

            if (currentUser == null) {
              return const Center(child: Text('Please sign in to view your profile.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Photo and User Mode Emoji
                  _buildProfilePhotoSection(context, currentUser),
                  const SizedBox(height: 16),

                  // Profile Name and Username
                  Text(
                    '${currentUser.firstName ?? currentUser.displayName ?? 'User'} ${currentUser.lastName ?? ''}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '@${currentUser.username ?? currentUser.email?.split('@').first ?? 'username'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Edit Profile Button
                  FilledButton.tonal(
                    onPressed: () {
                      // Navigate to an edit profile page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit Profile Pressed')),
                      );
                    },
                    child: const Text('Edit Profile'),
                  ),
                  const SizedBox(height: 24),

                  // Followers, Following, and Rank Status
                  _buildStatsSection(context, currentUser),
                  const SizedBox(height: 24),

                  // Refer Friends Placeholder
                  _buildReferFriendsSection(context, currentUser.uid),
                  const SizedBox(height: 24),

                  // User Uploaded Videos (Grid View)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your Videos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildUserVideosGrid(context, currentUser.uploadedVideoUrls),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection(BuildContext context, UserEntity user) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage: user.profilePhotoUrl != null && user.profilePhotoUrl!.isNotEmpty
              ? NetworkImage(user.profilePhotoUrl!)
              : null, // Fallback to child if no image
          child: user.profilePhotoUrl == null || user.profilePhotoUrl!.isEmpty
              ? Icon(
            Icons.person,
            size: 80,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _showEmojiSelectionDialog(context, user),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              child: Text(
                user.userModeEmoji ?? '😊',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEmojiSelectionDialog(BuildContext context, UserEntity user) {
    final List<String> emojis = ['😊', '😎', '🎉', '😴', '🔥', '💻', '💡', '🎵']; // Example emojis

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Select your mood'),
          content: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: emojis.map((emoji) {
              return ChoiceChip(
                label: Text(emoji, style: const TextStyle(fontSize: 24)),
                selected: user.userModeEmoji == emoji,
                onSelected: (selected) {
                  if (selected) {
                    // Dispatch update event
                    final updatedUser = user.copyWith(userModeEmoji: emoji);
                    BlocProvider.of<ProfileBloc>(context).add(UpdateUserModeEmoji(uid: user.uid, emoji: emoji));
                    Navigator.of(dialogContext).pop();
                  }
                },
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              );
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsSection(BuildContext context, UserEntity user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatColumn(context, user.followersCount.toString(), 'Followers'),
        _buildStatColumn(context, user.followingCount.toString(), 'Following'),
        _buildStatColumn(context, user.rank ?? 'Newbie', 'Rank'),
      ],
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildReferFriendsSection(BuildContext context, String userId) {
    final String personalizedReferralLink = "https://your.app.com/invite?ref=$userId";
    return Card(
      elevation: 1, // Material 3 uses subtle elevation for cards
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(MdiIcons.shareVariant, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Refer Friends',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Share your unique referral link and invite friends to join!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: SelectableText(
                personalizedReferralLink,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: () async {
                  // await launchUrl(Uri.parse(personalizedReferralLink));
                },
                icon: const Icon(Icons.send),
                label: const Text('Share Link'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserVideosGrid(BuildContext context, List<String> videoUrls) {
    if (videoUrls.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.videocam_off, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 8),
            Text(
              'No videos uploaded yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // To allow parent scroll
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.75, // Adjust as needed for video aspect ratio
      ),
      itemCount: videoUrls.length,
      itemBuilder: (context, index) {
        final videoUrl = videoUrls[index];
        // In a real app, you'd load video thumbnails here.
        // For simplicity, using a placeholder image for now.
        return Card(
          clipBehavior: Clip.antiAlias, // For rounded corners on image
          elevation: 1,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: InkWell(
            onTap: () {
              // Navigate to video player page or play video
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Playing video: $videoUrl')),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.network(
                    'https://via.placeholder.com/150/0000FF/FFFFFF?text=Video+${index + 1}', // Placeholder thumbnail
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(Icons.broken_image, color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Video Title ${index + 1}', // Replace with actual video title
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}