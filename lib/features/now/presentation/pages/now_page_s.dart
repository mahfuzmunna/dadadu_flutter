// lib/features/now/presentation/pages/now_page.dart

import 'package:dadadu_app/features/now/presentation/bloc/feed_bloc.dart';
import 'package:dadadu_app/features/posts/presentation/bloc/diamond_bloc.dart';
import 'package:dadadu_app/features/profile/presentation/bloc/follow_bloc.dart';
import 'package:dadadu_app/injection_container.dart';
import 'package:dadadu_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/scrollable_video_player.dart'; // Import the new widget

class NowPage extends StatelessWidget {
  const NowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => sl<FeedBloc>()..add(SubscribeToFeed())),
        BlocProvider(create: (context) => sl<FollowBloc>()),
        BlocProvider(create: (context) => sl<DiamondBloc>()),
      ],
      child: const _NowPageView(),
    );
  }
}

class _NowPageView extends StatefulWidget {
  const _NowPageView();

  @override
  State<_NowPageView> createState() => _NowPageViewState();
}

class _NowPageViewState extends State<_NowPageView> {
  bool _hasNewNotifications = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        centerTitle: false,
        excludeHeaderSemantics: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light),
        title: _buildNowChip(l10n, colorScheme),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Badge(
                isLabelVisible: _hasNewNotifications,
                child: const Icon(Icons.notifications_none_rounded),
              ),
              tooltip: l10n.notifications,
              onPressed: () => _showNotificationsDialog(context),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.4),
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<FeedBloc, FeedState>(
        listener: (context, state) {
          if (state is FeedLoaded && state.degraded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Partial data: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          if (state is FeedLoading || state is FeedInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FeedError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is FeedLoaded) {
            final posts = state.data.posts;
            final authors = state.data.authors;
            return ScrollableVideoPlayer(
              posts: posts,
              authors: authors,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- UI Helper Methods (No change to logic) ---

  void _showNotificationsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _hasNewNotifications = false);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final notifications = [
          {
            'user': 'mahfuzmunna',
            'action': l10n.likedYourVideo,
            'time': '5m ago'
          },
          {
            'user': 'sakib',
            'action': l10n.startedFollowingYou,
            'time': '1h ago'
          },
          {
            'user': 'john_doe',
            'action': l10n.commentedAwesome,
            'time': '3h ago'
          },
        ];
        return AlertDialog(
          title: Text(l10n.notifications),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                            text: n['user'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' ${n['action']}'),
                      ],
                    ),
                  ),
                  subtitle: Text(n['time']!),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNowChip(AppLocalizations l10n, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.8),
                  colorScheme.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.onPrimary.withOpacity(0.7),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.now,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
