// lib/features/profile/presentation/pages/profile_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dadadu_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart'; // For sharing content

/// This page is the main entry point for the profile screen.
/// It's driven by the AuthBloc to get the initial user data, which
/// prevents a loading screen when viewing the current user's profile.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          // Pass the currently logged-in user's data as the initial view.
          // The ProfileBloc will then take over with live updates.
          return _ProfileView(initialUser: authState.user);
        }
        // Fallback for when auth state is loading or unauthenticated.
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

/// This is the actual UI for the profile page.
/// It subscribes to live updates from the ProfileBloc.
class _ProfileView extends StatefulWidget {
  final UserEntity initialUser;

  const _ProfileView({required this.initialUser});

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  @override
  void initState() {
    super.initState();
    // Subscribe to live updates for the user being viewed.
    // This is triggered once when the widget is first created.
    context
        .read<ProfileBloc>()
        .add(SubscribeToUserProfile(widget.initialUser.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        // The UI is built from the ProfileBloc's state for live data.
        // It starts with the initial data and updates automatically when new data arrives.
        final UserEntity userToDisplay = (profileState is ProfileLoadedUser)
            ? profileState.user
            : widget.initialUser;

        // Determine if this profile belongs to the currently signed-in user.
        final authState = context.watch<AuthBloc>().state;
        final bool isMyProfile = (authState is AuthAuthenticated)
            ? authState.user.id == userToDisplay.id
            : false;

        final String referralLink =
            'https://dadadu.app/invite/${userToDisplay.id.substring(0, 8)}';

        return Scaffold(
          appBar: AppBar(
            title: Text(
              isMyProfile
                  ? 'My Profile'
                  : (userToDisplay.username ?? 'Profile'),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              if (isMyProfile)
                IconButton(
                  icon: Icon(Icons.settings_rounded,
                      color: Theme.of(context).colorScheme.primary),
                  tooltip: 'Settings',
                  onPressed: () => context.push('/settings'),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileHeader(userToDisplay, isMyProfile),
                const SizedBox(height: 24),
                if (isMyProfile) ...[
                  _buildMoodAndBadgesSection(userToDisplay),
                  const SizedBox(height: 24),
                ],
                _buildStatsRow(userToDisplay),
                const SizedBox(height: 32),
                if (isMyProfile) ...[
                  _buildReferralCard(referralLink),
                  const SizedBox(height: 32),
                ],
                if (isMyProfile) ...[
                  _buildMatchHistory(),
                  const SizedBox(height: 32),
                ],
                _buildVideosGrid(userToDisplay, isMyProfile),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET BUILDER METHODS ---

  Widget _buildProfileHeader(UserEntity user, bool isMyProfile) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: user.profilePhotoUrl != null &&
                      user.profilePhotoUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(user.profilePhotoUrl!)
                  : null,
              child: user.profilePhotoUrl == null ||
                      user.profilePhotoUrl!.isEmpty
                  ? Icon(
                      Icons.person_rounded,
                      size: 70,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Text(user.moodStatus ?? '😊',
                      style: const TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          '@${user.username ?? 'No Username'}',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        if (user.rank.isNotEmpty)
          Chip(
            avatar: Icon(Icons.star_rounded,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                size: 18),
            label: Text(
              user.rank,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),
        const SizedBox(height: 16),
        _buildDynamicActionButton(user, isMyProfile),
      ],
    );
  }

  Widget _buildDynamicActionButton(UserEntity user, bool isMyProfile) {
    if (isMyProfile) {
      return SizedBox(
        width: 200,
        child: FilledButton.icon(
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Edit Profile'),
          onPressed: () => context.push('/editProfile'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
      );
    } else {
      bool isFollowing = false; // Placeholder for FriendsBloc state
      return SizedBox(
        width: 200,
        child: FilledButton.icon(
          icon: Icon(isFollowing
              ? Icons.person_remove_rounded
              : Icons.person_add_rounded),
          label: Text(isFollowing ? 'Unfollow' : 'Follow'),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      '${isFollowing ? 'Unfollowing' : 'Following'} ${user.username}')),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: isFollowing
                ? Colors.grey
                : Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
      );
    }
  }

  Widget _buildMoodAndBadgesSection(UserEntity user) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.sentiment_satisfied_alt_rounded),
            label: Text(user.moodStatus != null
                ? 'Mood: ${user.moodStatus}'
                : 'Set Mood'),
            onPressed: () => _showMoodSelectionBottomSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              foregroundColor:
                  Theme.of(context).colorScheme.onSecondaryContainer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.military_tech_outlined),
            label: const Text('How Badges Work'),
            onPressed: () => _showBadgesInfoDialog(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(UserEntity user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatColumn(context, Icons.people_alt_rounded,
            '${user.followersCount}', 'Followers'),
        _buildStatColumn(context, Icons.person_add_alt_1_rounded,
            '${user.followingCount}', 'Following'),
        _buildStatColumn(context, Icons.ondemand_video_rounded,
            '${user.postCount ?? 0}', 'Videos'),
      ],
    );
  }

  Widget _buildReferralCard(String referralLink) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Share your unique referral link and earn 100 💎 for every friend who signs up!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Text(
                referralLink,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy'),
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: referralLink));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Referral link copied!')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Share'),
                    onPressed: () async {
                      await Share.share(
                          'Join me on Dadadu! Use my link to sign up: $referralLink');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Match History',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            width: double.infinity,
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videogame_asset_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'No match history yet.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideosGrid(UserEntity user, bool isMyProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uploaded Videos (${user.postCount ?? 0})',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (user.postCount == null || user.postCount == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Center(
              child: Text(
                isMyProfile
                    ? 'You haven\'t uploaded any videos yet.'
                    : 'This user has no videos.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
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
            itemCount: user.postCount,
            itemBuilder: (context, index) {
              return Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    /* Navigate to video player */
                  },
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    child: const Center(
                        child: Icon(Icons.play_circle_outline, size: 40)),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // --- HELPER METHODS ---

  Widget _buildStatColumn(
      BuildContext context, IconData icon, String count, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          count,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  void _showMoodSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (bc) => Wrap(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Select Your Mood',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          ListTile(
            leading: const Text('😊', style: TextStyle(fontSize: 24)),
            title: const Text('Happy'),
            onTap: () => Navigator.pop(bc),
          ),
          ListTile(
            leading: const Text('😞', style: TextStyle(fontSize: 24)),
            title: const Text('Sad'),
            onTap: () => Navigator.pop(bc),
          ),
        ],
      ),
    );
  }

  void _showBadgesInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.military_tech_rounded),
            SizedBox(width: 10),
            Text('Dadadu Badge System',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const Text('Earn badges by achieving various milestones!'),
              const SizedBox(height: 10),
              _buildBadgeInfoRow(context, '🍃', 'LEAF (0 - 9,999 diamonds)',
                  'Starting level for new users.'),
              _buildBadgeInfoRow(
                  context,
                  '☘️',
                  'THREELEAF (10K - 999K diamonds)',
                  'Active community member.'),
              _buildBadgeInfoRow(context, '🎀', 'FIVELEAF (1M - 9.9M diamonds)',
                  'Popular creator status.'),
              _buildBadgeInfoRow(context, '👑', 'DADALORD (10M+ diamonds)',
                  'Elite status worth \$10,000+ with +2% per million diamonds.'),
              const SizedBox(height: 16),
              Text(
                '📈 Higher badges = more prestige + marketplace value',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: FilledButton.tonal(
              child: const Text('Got It!'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
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
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
