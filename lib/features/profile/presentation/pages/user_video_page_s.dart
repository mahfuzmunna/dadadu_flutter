import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/now/presentation/bloc/feed_bloc.dart';
import 'package:dadadu_app/features/now/presentation/bloc/post_bloc.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:dadadu_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../injection_container.dart' as di;
import '../../../now/presentation/widgets/video_post_item.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
// import 'package:dadadu_app/features/now/presentation/widgets/video_post_item.dart';

class UsersVideoPage extends StatelessWidget {
  final String postId;

  const UsersVideoPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    // Provide the FeedBloc to the widget tree and immediately load the feed.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => sl<FeedBloc>()..add(SubscribeToFeed())),
        BlocProvider(create: (context) => sl<PostBloc>()),
      ],
      child: _UsersVideoView(
        initialPostId: postId,
      ),
    );
  }
}

class _UsersVideoView extends StatefulWidget {
  final String initialPostId;

  const _UsersVideoView({required this.initialPostId});

  @override
  State<_UsersVideoView> createState() => _UsersVideoViewState();
}

class _UsersVideoViewState extends State<_UsersVideoView>
    with WidgetsBindingObserver {
  late PageController _pageController = PageController();
  late PostEntity initialPost;
  List<PostEntity> _usersPosts = [];
  Map<String, UserEntity> _authors = {};
  int _currentPageIndex = 0;

  final int _maxCacheSize =
      3; // Max controllers to keep in memory (current, previous, next)
  final Map<String, VideoPlayerController> _controllerCache = {};
  final Set<String> _initializingControllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPageIndex) {
        _onPageChanged(_usersPosts, newPage);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _disposeAllControllers();
    super.dispose();
  }

  void _onPageChanged(List<PostEntity> posts, int newPage) {
    if (posts.isNotEmpty && _currentPageIndex < posts.length) {
      final oldPostId = posts[_currentPageIndex].id;
      _controllerCache[oldPostId]?.pause();
    }
    setState(() => _currentPageIndex = newPage);
    _manageControllerCache(posts, newPage);
  }

  Future<void> _manageControllerCache(List<PostEntity> posts, int page) async {
    if (page < 0 || page >= posts.length) return;

    await _initializeAndPlay(posts, page);

    if (page + 1 < posts.length) _initializeControllerForIndex(posts, page + 1);
    if (page - 1 >= 0) _initializeControllerForIndex(posts, page - 1);

    final idsToKeep = {posts[page].id};
    if (page > 0) idsToKeep.add(posts[page - 1].id);
    if (page < posts.length - 1) idsToKeep.add(posts[page + 1].id);

    _controllerCache.keys
        .where((id) => !idsToKeep.contains(id))
        .toList()
        .forEach(_disposeController);
  }

  Future<void> _initializeAndPlay(List<PostEntity> posts, int index) async {
    final post = posts[index];
    if (!_controllerCache.containsKey(post.id)) {
      await _initializeControllerForIndex(posts, index);
    }
    final controller = _controllerCache[post.id];
    if (controller?.value.isInitialized ?? false) {
      await controller?.setLooping(true);
      await controller?.play();
      if (mounted) setState(() {});
    }
  }

  Future<void> _disposeController(String postId) async {
    final controller = _controllerCache.remove(postId);
    await controller?.dispose();
  }

  Future<void> _disposeAllControllers() async {
    for (final controller in _controllerCache.values) {
      await controller.dispose();
    }
    _controllerCache.clear();
  }

  Future<void> _initializeControllerForIndex(
      List<PostEntity> posts, int index) async {
    final post = posts[index];
    if (_controllerCache.containsKey(post.id)) return;

    final controller =
        VideoPlayerController.networkUrl(Uri.parse(post.videoUrl));
    _controllerCache[post.id] = controller;
    try {
      await controller.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error pre-caching video for post ${post.id}: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controllerCache[_usersPosts[_currentPageIndex].id];
    if (state == AppLifecycleState.paused) {
      controller?.pause();
    } else if (state == AppLifecycleState.resumed) {
      controller?.play();
    }
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
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // centerTitle: false,
        excludeHeaderSemantics: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          // Add padding for better placement
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            // Style for a modern, adaptive look
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.4),
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.5),
            ),
            tooltip: 'Back',
          ),
        ),
        // title: BlocBuilder<ProfileBloc, ProfileState>(
        //   builder: (context, state) {
        //     if (state is ProfileLoaded) {
        //       final author = state.user;
        //     }
        //     return _buildNowChip(authorFullName!, colorScheme);
        //   },
        // ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.notifications_none_rounded),
        //     tooltip: 'Notifications',
        //     onPressed: () {
        //       _showNotificationsDialog(context);
        //     },
        //     style: IconButton.styleFrom(
        //       foregroundColor: Colors.white,
        //       shadowColor: Colors.black.withOpacity(0.5),
        //       elevation: 4,
        //     ),
        //   ),
        // ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: BlocBuilder<FeedBloc, FeedState>(
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
              final PostEntity initialPost = state.posts
                  .firstWhere((post) => post.id == widget.initialPostId);

              final usersPosts = state.posts
                  .where((post) => post.userId == initialPost.userId)
                  .toList();
              final initialPageIndex =
                  usersPosts.indexWhere((post) => post.id == initialPost.id);

              if (_pageController.initialPage != initialPageIndex) {
                _pageController = PageController(initialPage: initialPageIndex);
                _currentPageIndex = initialPageIndex;
                _pageController.addListener(() {
                  final newPage = _pageController!.page?.round() ?? 0;
                  if (newPage != _currentPageIndex) {
                    _onPageChanged(usersPosts, newPage);
                  }
                });
                // Initial load for the first video
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _manageControllerCache(usersPosts, initialPageIndex);
                });
              }

              if (usersPosts.isEmpty) {
                return const Center(child: Text("This user has no posts."));
              }

              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: usersPosts.length,
                itemBuilder: (context, index) {
                  final post = usersPosts[index];
                  final author = state.authors[post.userId];
                  return BlocProvider<ProfileBloc>(
                      create: (context) => di.sl<ProfileBloc>()
                        ..add(SubscribeToUserProfile(author!.id)),
                      child: BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                        // if (state is ProfileLoaded) {
                        //   setState(() {
                        //     authorFullName = state.user.fullName;
                        //   });
                        // };
                        return VideoPostItem(
                            key: ValueKey(post.id),
                            post: post,
                            author: author,
                            controller: _controllerCache[post.id],
                            isCurrentPage: index == _currentPageIndex,
                            onUserTapped: (userId) {
                              context.pop();
                            });
                      }));
                },
              );
            }

            // Fallback for any other state
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildNowChip(String text, ColorScheme colorScheme) {
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
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    // ✅ Text color is now onPrimary for high contrast
                    color: colorScheme.onPrimary,
                  ),
                ),
                // if (totalPosts < 0)
                //   Text(
                //     ' ${_currentPageIndex + 1}/$totalPosts',
                //     style: TextStyle(
                //       fontSize: 14,
                //       // ✅ Counter text is slightly transparent for a subtle look
                //       color: colorScheme.onPrimary.withOpacity(0.8),
                //       fontWeight: FontWeight.w600,
                //     ),
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
