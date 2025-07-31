import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadadu_app/features/discover/domain/usecases/find_users_by_vibe_usecase.dart';
import 'package:dadadu_app/features/discover/presentation/bloc/discover_bloc.dart';
import 'package:dadadu_app/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart'; // NEW: Import for navigation

import '../../../auth/presentation/bloc/auth_bloc.dart';

// UPDATED: Converted to a StatefulWidget to manage the PageController
class VibeUsersPage extends StatefulWidget {
  final String vibe;
  final Position currentPosition;
  final double maxDistance;
  final VoidCallback onBackPressed;

  const VibeUsersPage({
    super.key,
    required this.vibe,
    required this.currentPosition,
    required this.maxDistance,
    required this.onBackPressed,
  });

  @override
  State<VibeUsersPage> createState() => _VibeUsersPageState();
}

class _VibeUsersPageState extends State<VibeUsersPage> {
  // NEW: Controller to manage the PageView's appearance
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // viewportFraction allows us to see a glimpse of the next/previous cards
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<DiscoverBloc>()
        ..add(FindUsersByVibe(
            vibe: widget.vibe,
            position: widget.currentPosition,
            distance: widget.maxDistance)),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBackPressed,
          ),
          title: Text('${widget.vibe} Vibe'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        // Use a dark background for better contrast with the cards
        backgroundColor: Theme.of(context).scaffoldBackgroundColor.withBlue(20),
        body: BlocBuilder<DiscoverBloc, DiscoverState>(
          builder: (context, state) {
            final authState = context.select((AuthBloc bloc) => bloc.state);
            if (state is DiscoverLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DiscoverError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is DiscoverUsersLoaded &&
                authState is AuthAuthenticated) {
              final users = state.users
                  .where((user) => user.user.id != authState.user.id)
                  .toList();
              if (users.isEmpty) {
                return const Center(
                    child: Text('No users found nearby with this vibe.'));
              }

              // UPDATED: Using PageView.builder for a swipeable layout
              return PageView.builder(
                controller: _pageController,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final userWithDistance = users[index];
                  // Pass data to the redesigned _UserCard
                  return KeyedSubtree(
                      key: ValueKey(users[index].user.username),
                      child: _UserCard(
                          key: ValueKey(users[index].user.username),
                          userWithDistance: userWithDistance));
                },
              );
            }
            return const Center(child: Text('Finding users...'));
          },
        ),
      ),
    );
  }
}

// UPDATED: Complete redesign of the User Card
class _UserCard extends StatelessWidget {
  final UserWithDistance userWithDistance;

  const _UserCard({required this.userWithDistance, required Key key});

  @override
  Widget build(BuildContext context) {
    final user = userWithDistance.user;
    final distance =
        '${userWithDistance.distanceInKm < 1 ? (userWithDistance.distanceInKm * 1000).round() : userWithDistance.distanceInKm.toStringAsFixed(1)} ${userWithDistance.distanceInKm < 1 ? 'm' : 'km'}';

    return Padding(
      // Padding adds space between the cards
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
      child: Card(
        clipBehavior: Clip.antiAlias, // Ensures content respects the border
        elevation: 8.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Background Image
            _buildBackgroundImage(user.profilePhotoUrl),
            // Layer 2: Gradient Overlay for text readability
            _buildGradientOverlay(),
            // Layer 3: User Info and Action Button
            _buildUserInfo(context, user, distance),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade700, Colors.grey.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
            child: Icon(Icons.person, color: Colors.white54, size: 100)),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: Colors.grey.shade800),
      errorWidget: (context, url, error) =>
          const Center(child: Icon(Icons.broken_image)),
    );
  }

  Widget _buildGradientOverlay() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87],
          stops: [0.5, 1.0], // Gradient starts halfway down
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, dynamic user, String distance) {
    // Get theme and color scheme from context for cleaner M3 implementation
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Constrain the column's size to its children, important for stacking
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- USER IDENTITY ---
            // Using more expressive M3 typography roles for better hierarchy.
            Text(
              user.fullName ?? 'Unknown User',
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                shadows: [const Shadow(blurRadius: 4, color: Colors.black54)],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (user.username != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '@${user.username!}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // --- ADAPTIVE INFO CHIPS ---
            // A Wrap widget is adaptive: it automatically moves chips to the
            // next line on smaller screens to prevent overflow errors.
            Wrap(
              spacing: 8.0, // Horizontal space between chips
              runSpacing: 8.0, // Vertical space between lines of chips
              children: [
                // Distance Chip
                Chip(
                  avatar: Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  label: Text(
                    '$distance away',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  backgroundColor: colorScheme.surfaceVariant.withOpacity(0.85),
                  side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                ),
                // Location Chip (only shows if location exists)
                if (user.location != null && user.location!.isNotEmpty)
                  Chip(
                    avatar: Icon(
                      Icons.public_outlined,
                      size: 18,
                      color: colorScheme.secondary,
                    ),
                    label: Text(
                      user.location!,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    backgroundColor:
                        colorScheme.surfaceVariant.withOpacity(0.85),
                    side:
                        BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // --- BIO SECTION ---
            // With improved readability using line height (height property).
            if (user.bio != null && user.bio!.isNotEmpty)
              Text(
                user.bio!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                  height: 1.5, // Increased line spacing for readability
                ),
                maxLines: 3, // Allow for a slightly longer bio preview
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 24),

            // --- ACTION BUTTON ---
            // A high-emphasis M3 FilledButton for the primary action.
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.person_search_outlined),
                label: const Text('View Profile'),
                onPressed: () {
                  // Logic remains unchanged
                  context.push('/profile/${user.id}');
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  textStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                  // A modern, fully rounded "pill" shape
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
