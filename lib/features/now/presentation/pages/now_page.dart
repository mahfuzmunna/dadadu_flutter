import 'package:dadadu_app/features/now/presentation/bloc/feed_bloc.dart';
import 'package:dadadu_app/features/now/presentation/bloc/post_bloc.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:dadadu_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'video_post_item.dart';
// import 'package:dadadu_app/features/now/presentation/widgets/video_post_item.dart';

class NowPage extends StatelessWidget {
  const NowPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the FeedBloc to the widget tree and immediately load the feed.
    return BlocProvider(
      // create: (context) => sl<FeedBloc>()..add(LoadFeed()),
      create: (context) => sl<FeedBloc>()..add(SubscribeToFeed()),
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
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final int nextPageIndex = _pageController.page?.round() ?? 0;
      if (_currentPageIndex != nextPageIndex) {
        setState(() {
          _currentPageIndex = nextPageIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ✅ NEW: Helper method to show the notifications dialog
  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Dummy data for notifications
        final notifications = [
          {
            'user': 'mahfuzmunna',
            'action': 'liked your video.',
            'time': '5m ago'
          },
          {
            'user': 'sakib',
            'action': 'started following you.',
            'time': '1h ago'
          },
          {
            'user': 'john_doe',
            'action': 'commented: "Awesome!"',
            'time': '3h ago'
          },
        ];

        return AlertDialog(
          title: const Text('Notifications'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                            text: notification['user'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' ${notification['action']}'),
                      ],
                    ),
                  ),
                  subtitle: Text(notification['time']!),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        excludeHeaderSemantics: true,
        title: BlocBuilder<FeedBloc, FeedState>(
          builder: (context, state) {
            final int totalPosts =
                (state is FeedLoaded) ? state.posts.length : 0;

            return _buildNowChip(colorScheme, totalPosts);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifications',
            onPressed: () {
              _showNotificationsDialog(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<FeedBloc, FeedState>(
        builder: (context, state) {
          // LOADING STATE
          if (state is FeedLoading || state is FeedInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          // ERROR STATE
          if (state is FeedError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          // LOADED STATE
          if (state is FeedLoaded) {
            final posts = state.posts;

            if (posts.isEmpty) {
              return const Center(
                  child: Text('No videos yet. Why not upload one?'));
            }

            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final PostEntity post = posts[index];

                // return VideoPostItem(
                //     isCurrentPage: index == _currentPageIndex,
                //     onUserTapped: (userId) {
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         SnackBar(content: Text('Tapped on user: $userId')),
                //       );
                //     },
                //   );
                return BlocProvider<PostBloc>(
                  create: (context) => sl<PostBloc>()..add(LoadPost(post.id)),
                  child: VideoPostItem(
                    initialPost: post,
                    isCurrentPage: index == _currentPageIndex,
                    onUserTapped: (userId) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tapped on user: $userId')),
                      );
                    },
                  ),
                );
              },
            );
          }

          // Fallback for any other state
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNowChip(ColorScheme colorScheme, int totalPosts) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Add an action here, e.g., scroll to the top of the feed
            debugPrint("Now Chip Tapped!");
          },
          borderRadius: BorderRadius.circular(24),
          // Match the container's border radius
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              // ✅ Gradient updated to use the primary blue color
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.8),
                  colorScheme.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24), // Slightly more rounded
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  // Shadow matches the blue theme
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Live indicator dot is now a vibrant white
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary, // Bright white on blue
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
                  'NOW',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    // ✅ Text color is now onPrimary for high contrast
                    color: colorScheme.onPrimary,
                  ),
                ),
                if (totalPosts > 0)
                  Text(
                    ' ${_currentPageIndex + 1}/$totalPosts',
                    style: TextStyle(
                      fontSize: 14,
                      // ✅ Counter text is slightly transparent for a subtle look
                      color: colorScheme.onPrimary.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
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
