import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadadu_app/features/chat/domain/entities/chat_room_entity.dart';
import 'package:dadadu_app/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:dadadu_app/injection_container.dart';
import 'package:dadadu_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/presence_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChatListBloc>()..add(SubscribeToChatRooms()),
      child: const _ChatsPageView(),
    );
  }
}

class _ChatsPageView extends StatefulWidget {
  const _ChatsPageView();

  @override
  State<_ChatsPageView> createState() => _ChatsPageViewState();
}

class _ChatsPageViewState extends State<_ChatsPageView> {
  Set<String> _onlineUserIds = {};
  late final StreamSubscription<Set<String>> _presenceSub;
  List<ChatRoomEntity>? usersRoom;

  @override
  void initState() {
    _presenceSub = PresenceService.instance.onlineUsersStream.listen((online) {
      setState(() {
        _onlineUserIds = online;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _presenceSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.inviteFriendsToUnlockSearch),
            ),
          );
        },
        child: const Icon(Icons.add_comment_rounded),
      ),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.chats),
      ),
      body: BlocBuilder<ChatListBloc, ChatListState>(
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          if (state is ChatListLoading || state is ChatListInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ChatListError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is ChatListLoaded) {
            final rooms = state.rooms;

            if (authState is AuthAuthenticated) {
              usersRoom = rooms.where((room) {
                // This condition keeps the room only if the participant list contains the user's ID
                return room.participantIds.contains(authState.user.id);
              }).toList();
            }

            if (usersRoom != null && usersRoom!.isEmpty) {
              return const _EmptyChatView();
            }

            String selectedFilter = AppLocalizations.of(context)!.all;
            return CustomScrollView(
              slivers: [
                // ✅ Sticky header with filter chips

                SliverPersistentHeader(
                  delegate: _SliverFilterHeader(
                    selectedFilter: selectedFilter,
                    onFilterChanged: (filter) {
                      setState(() {
                        selectedFilter = filter;
                        // TODO: Add BLoC event to filter chats
                      });
                    },
                  ),
                  pinned: true,
                ),
                SliverList.separated(
                  itemCount: usersRoom?.length,
                  itemBuilder: (context, index) {
                    final room = usersRoom?[index];
                    final otherUserId = usersRoom?[index].otherParticipant.id;
                    final isOnline = _onlineUserIds.contains(otherUserId);

                    // ✅ Wrap tile in a Dismissible for swipe actions
                    return Dismissible(
                      key: ValueKey(room?.id),
                      onDismissed: (direction) {
                        // TODO: Add BLoC event to delete or archive chat
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!
                                .userDismissed(
                                    room.otherParticipant.fullName ?? '')),
                            action: SnackBarAction(
                                label: AppLocalizations.of(context)!.undo,
                                onPressed: () {
                                  // TODO: Add BLoC event to undo dismissal
                                }),
                          ),
                        );
                      },
                      background: _buildDismissibleBackground(
                        color: Colors.green.shade700,
                        icon: Icons.archive_rounded,
                        alignment: Alignment.centerLeft,
                      ),
                      secondaryBackground: _buildDismissibleBackground(
                        color: Colors.red.shade800,
                        icon: Icons.delete_forever_rounded,
                        alignment: Alignment.centerRight,
                      ),
                      child: _ChatItemTile(room: room!, isOnline: isOnline),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    indent: 80,
                    endIndent: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.5),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDismissibleBackground({
    required Color color,
    required IconData icon,
    required AlignmentGeometry alignment,
  }) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}

/// A custom widget for displaying a single chat item.
class _ChatItemTile extends StatelessWidget {
  final ChatRoomEntity room;
  final bool isOnline;

  const _ChatItemTile({required this.room, required this.isOnline});

  String _formatTimestamp(BuildContext context, DateTime ts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(ts.year, ts.month, ts.day);

    if (date == today) {
      return DateFormat.jm().format(ts.toLocal());
    } else if (date == yesterday) {
      return AppLocalizations.of(context)!.yesterday;
    } else {
      return DateFormat.MMMd().format(ts.toLocal());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final otherUser = room.otherParticipant;
    // Placeholders for new UI features
    final bool isUnread = false;

    return InkWell(
      onTap: () =>
          context.push('/chat/${room.id}', extra: room.otherParticipant.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // ✅ Avatar with Online Status Indicator
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: otherUser.profilePhotoUrl != null
                      ? CachedNetworkImageProvider(otherUser.profilePhotoUrl!)
                      : null,
                  child: otherUser.profilePhotoUrl == null
                      ? const Icon(Icons.person, size: 28)
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: theme.scaffoldBackgroundColor, width: 2.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUser.fullName ??
                        AppLocalizations.of(context)!.unknownUser,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    room.lastMessage?.content ?? '...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isUnread
                        ? theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          )
                        : theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  room.lastMessage != null
                      ? _formatTimestamp(context, room.lastMessage!.createdAt)
                      : '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isUnread
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                if (isUnread)
                  Container(
                    width: 22,
                    // Make the badge slightly bigger for a count
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text('2', // Placeholder count
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.onPrimary)),
                  )
                else
                  const SizedBox(height: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// A widget to show when the user has no chats.
class _EmptyChatView extends StatelessWidget {
  const _EmptyChatView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.inboxEmpty,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.startConversationPrompt,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A delegate for creating a sticky header with filter chips.
class _SliverFilterHeader extends SliverPersistentHeaderDelegate {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  _SliverFilterHeader(
      {required this.selectedFilter, required this.onFilterChanged});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          AppLocalizations.of(context)!.all,
        ].map((filter) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(filter),
              selected: selectedFilter == filter,
              onSelected: (isSelected) {
                if (isSelected) onFilterChanged(filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(covariant _SliverFilterHeader oldDelegate) {
    return selectedFilter != oldDelegate.selectedFilter;
  }
}