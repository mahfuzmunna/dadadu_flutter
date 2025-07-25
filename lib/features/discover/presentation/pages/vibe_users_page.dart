import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadadu_app/features/discover/domain/usecases/find_users_by_vibe_usecase.dart';
import 'package:dadadu_app/features/discover/presentation/bloc/discover_bloc.dart';
import 'package:dadadu_app/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

class VibeUsersPage extends StatelessWidget {
  final String vibe;
  final Position currentPosition;

  const VibeUsersPage({
    super.key,
    required this.vibe,
    required this.currentPosition,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<DiscoverBloc>()
        ..add(FindUsersByVibe(vibe: vibe, position: currentPosition)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('$vibe Vibe'),
        ),
        body: BlocBuilder<DiscoverBloc, DiscoverState>(
          builder: (context, state) {
            if (state is DiscoverLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DiscoverError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is DiscoverUsersLoaded) {
              if (state.users.isEmpty) {
                return const Center(
                    child: Text('No users found nearby with this vibe.'));
              }
              return ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  final userWithDistance = state.users[index];
                  return _UserCard(userWithDistance: userWithDistance);
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

class _UserCard extends StatelessWidget {
  final UserWithDistance userWithDistance;

  const _UserCard({required this.userWithDistance});

  @override
  Widget build(BuildContext context) {
    final user = userWithDistance.user;
    final distance = userWithDistance.distanceInKm.toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: user.profilePhotoUrl != null &&
                      user.profilePhotoUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(user.profilePhotoUrl!)
                  : null,
              child:
                  user.profilePhotoUrl == null || user.profilePhotoUrl!.isEmpty
                      ? const Icon(Icons.person)
                      : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName ?? 'No Name',
                      style: Theme.of(context).textTheme.titleLarge),
                  if (user.username != null)
                    Text('@${user.username!}',
                        style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  if (user.bio != null && user.bio!.isNotEmpty)
                    Text(user.bio!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$distance km away - ${user.location ?? 'Unknown Location'}',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
