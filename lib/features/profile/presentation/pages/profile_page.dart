// lib/features/profile/presentation/pages/profile_page.dart

import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dadadu_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:dadadu_app/shared/widgets/emoji_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../injection_container.dart' as di; // For sharing content

/// This widget acts as a router.
/// It decides whether to show the current user's profile (passed via constructor)
/// or to use the ProfileBloc to fetch and display another user's profile.
class ProfilePage extends StatelessWidget {
  /// This is used ONLY when viewing the currently logged-in user's profile.
  /// When viewing another user, this will be null.
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // If a viewedUser is passed directly, it's the current user's profile.
    // This happens when navigating to '/profile' from the bottom nav bar.
      return BlocProvider(
        create: (context) =>
          di.sl<ProfileBloc>()..add(SubscribeToUserProfile(userId)),
      child: const _ProfileView(),
      );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (state is ProfileError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }
        if (state is ProfileLoaded) {
          final userToDisplay = state.user;
          final authState = context.watch<AuthBloc>().state;
          final bool isMyProfile = (authState is AuthAuthenticated)
              ? authState.user.id == userToDisplay.id
              : false;
          final String referralLink =
              'https://dadadu.app/invite/${userToDisplay.id.substring(0, 8)}';

          // All UI is now built using the live data from the BLoC state
          return _ProfileContent(
              user: userToDisplay,
              isMyProfile: isMyProfile,
              referralLink: referralLink);
        }
        return const Scaffold(
            body: Center(child: Text('Something went wrong')));
      },
    );
  }
}

/// This is the actual UI for the profile page.
/// It's a StatefulWidget to manage its own helper methods and dialogs.
class _ProfileContent extends StatefulWidget {
  final UserEntity user;
  final bool isMyProfile;
  final String referralLink;

  const _ProfileContent({
    required this.user,
    required this.isMyProfile,
    required this.referralLink,
  });

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _buildDiamondCounter(context, widget.user),
        leadingWidth: 84,
        title: Text(widget.isMyProfile
            ? 'My Profile'
            : (widget.user.fullName ?? 'Profile')),
        centerTitle: true,
        actions: [
          if (widget.isMyProfile)
            IconButton(
              icon: Icon(Icons.settings_rounded,
                  color: Theme.of(context).colorScheme.primary),
              onPressed: () => context.push('/settings'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Profile Header ---
            _buildProfileHeader(widget.isMyProfile),
            const SizedBox(height: 24),

            // --- Mood & Badges Info ---
            if (widget.isMyProfile) ...[
              _buildMoodAndBadgesSection(),
              const SizedBox(height: 24),
            ],

            // --- Stats ---
            _buildStatsRow(),
            const SizedBox(height: 32),

            // --- Referral Card ---
            if (widget.isMyProfile) ...[
              _buildReferralCard(widget.referralLink),
              const SizedBox(height: 32),
            ],

            // --- Match History ---
            if (widget.isMyProfile) ...[
              _buildMatchHistory(),
              const SizedBox(height: 32),
            ],

            // --- Uploaded Videos ---
            _buildVideosGrid(widget.isMyProfile),
          ],
        ),
      ),
    );
  }

  // ✅ NEW WIDGET: Builds the diamond counter.
  Widget _buildDiamondCounter(BuildContext context, UserEntity user) {
    final theme = Theme.of(context);
    // Add a 'diamonds' field to your UserEntity, e.g., final int diamonds;
    final int diamondCount = user.diamonds ?? 0;

    if (!widget.isMyProfile)
      return const SizedBox.shrink(); // Not for other users

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // You can use an emoji or a custom asset image
            const Text('💎', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              diamondCount.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getRankEmoji(String? rank) {
    switch (rank?.toLowerCase()) {
      case 'leaf':
        return '🍃';
      case 'threeleaf':
        return '☘️';
      case 'fiveleaf':
        return '🌟'; // A star for a higher rank
      case 'dadalord':
        return '👑'; // A crown for the highest rank
      default:
        return ''; // Return an empty string for unknown ranks
    }
  }

  IconData getMoodIcon(String? moodStatus) {
    switch (moodStatus?.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied_rounded;
      case 'sad':
        return Icons.sentiment_very_dissatisfied_rounded;
      case 'excited':
        return Icons.celebration_rounded;
      case 'calm':
        return Icons.self_improvement_rounded;
      case 'angry':
        return Icons.sentiment_dissatisfied_rounded;
      default:
        return Icons
            .sentiment_neutral_rounded; // Fallback for null or unknown moods
    }
  }

  // --- WIDGET BUILDER METHODS ---

  Widget _buildProfileHeader(bool isMyProfile) {
    final rank = widget.user.rank;
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: widget.user.profilePhotoUrl != null &&
                      widget.user.profilePhotoUrl!.isNotEmpty
                  ? NetworkImage(widget.user.profilePhotoUrl!)
                  : null,
              child: widget.user.profilePhotoUrl == null ||
                      widget.user.profilePhotoUrl!.isEmpty
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
                  child: Icon(
                    getMoodIcon(widget.user.moodStatus),
                    size: 20,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          '@${widget.user.username ?? 'No Username'}',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        if (rank != null)
          if (rank.isNotEmpty)
            Chip(
              avatar: EmojiIcon(
                getRankEmoji(rank),
                size: 16,
              ),
              label: Text(
                rank,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            ),
        const SizedBox(height: 16),
        _buildDynamicActionButton(isMyProfile),
      ],
    );
  }

  Widget _buildDynamicActionButton(bool isMyProfile) {
    if (isMyProfile) {
      return SizedBox(
        width: 200,
        child: FilledButton.icon(
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Edit Profile'),
          onPressed: () => context.push('/editProfile'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      );
    } else {
      // In a real app, you would check a FriendsBloc state here
      bool isFollowing = false; // Placeholder
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
                      '${isFollowing ? 'Unfollowing' : 'Following'} ${widget.user.username}')),
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

  Widget _buildMoodAndBadgesSection() {
    return Row(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.sentiment_satisfied_alt_rounded),
          label: Text(widget.user.moodStatus != null
              ? 'Mood: ${widget.user.moodStatus}'
              : 'Set Mood'),
          onPressed: () => _showMoodSelectionBottomSheet(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatColumn(context, Icons.people_alt_rounded,
            '${widget.user.followersCount}', 'Followers'),
        _buildStatColumn(context, Icons.person_add_alt_1_rounded,
            '${widget.user.followingCount}', 'Following'),
        _buildStatColumn(context, Icons.ondemand_video_rounded,
            '${widget.user.postCount}', 'Videos'),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
            height: 150, // Give it a fixed height
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

  Widget _buildVideosGrid(bool isMyProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uploaded Videos (${widget.user.postCount})',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (widget.user.postCount == 0)
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
            itemCount: widget.user.postCount,
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

  // --- HELPER METHODS FOR DIALOGS AND BOTTOM SHEETS ---

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
    // This is the currently authenticated user, whose mood we can change.
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final currentUser = authState.user;

    final moods = {
      'Happy': '😊',
      'Sad': '😞',
      'Excited': '🎉',
      'Calm': '😌',
      'Angry': '😠',
    };

    showModalBottomSheet(
      context: context,
      builder: (bc) => Wrap(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Select Your Mood',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          ...moods.entries.map((entry) {
            return ListTile(
              leading: Text(entry.value, style: const TextStyle(fontSize: 24)),
              title: Text(entry.key),
              onTap: () {
                // ✅ Dispatch the event to the ProfileBloc
                context.read<ProfileBloc>().add(
                      UpdateUserMood(userId: currentUser.id, mood: entry.key),
                    );

                // Show immediate feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Mood updated to ${entry.key}!')),
                );
                Navigator.pop(bc);
              },
            );
          }).toList(),
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
            Text(
              'Dadadu Badge System',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            )
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Earn badges by achieving various milestones!'),
              const SizedBox(
                height: 10,
              ),
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
