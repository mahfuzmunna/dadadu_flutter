import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/now/presentation/bloc/feed_bloc.dart';
import 'package:dadadu_app/features/now/presentation/bloc/post_bloc.dart';
import 'package:dadadu_app/features/posts/presentation/bloc/diamond_bloc.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:dadadu_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../injection_container.dart' as di;
import '../../../profile/presentation/bloc/follow_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../widgets/video_post_item.dart';

class NowPage extends StatelessWidget {
  const NowPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the FeedBloc to the widget tree and immediately load the feed.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => sl<FeedBloc>()..add(SubscribeToFeed())),
        BlocProvider(create: (context) => sl<PostBloc>()),
        BlocProvider(create: (context) => di.sl<FollowBloc>()),
        BlocProvider(create: (context) => di.sl<DiamondBloc>()),
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

class _NowPageViewState extends State<_NowPageView>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  List<PostEntity> _posts = [];
  Map<String, UserEntity> _authors = {};
  late GoRouter _router;
  bool _isPageActive = true;
  int _currentPageIndex = 0;
  bool _hasNewNotifications = true;

  final Map<String, VideoPlayerController> _controllerCache = {};
  String? _currentPostId;
  final Set<String> _initializingControllers = {};

  // ✅ 1. Keep track of videos the user has manually started playing.
  final Set<String> _userHasInitiatedPlay = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPageIndex) {
        _onPageChanged(newPage);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _router = GoRouter.of(context);
      _router.routerDelegate.addListener(_handleRouteChange);
      // ✅ Set the initial route state correctly
      _handleRouteChange();
    });
  }

  // ✅ 2. Fixed logic to correctly pause/resume video based on route activity.
  void _handleRouteChange() {
    if (!mounted) return;

    final String topRoute =
        _router.routerDelegate.currentConfiguration.fullPath;
    final bool isActive =
        (topRoute == '/'); // Assuming NowPage is at the root '/'

    if (_isPageActive != isActive) {
      setState(() {
        _isPageActive = isActive;
      });

      final controller = _controllerCache[_currentPostId];
      if (controller == null) return;

      if (isActive) {
        // Page is active again. Play only if the user has previously played it.
        if (_userHasInitiatedPlay.contains(_currentPostId!)) {
          controller.play();
        }
      } else {
        // Page is no longer active, so pause the video.
        controller.pause();
      }
    }
  }

  @override
  void dispose() {
    // ✅ Remove the router listener
    _router.routerDelegate.removeListener(_handleRouteChange);
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _disposeAllControllers();
    super.dispose();
  }

  void _onPageChanged(int newPage) {
    if (_posts.isNotEmpty && _currentPageIndex < _posts.length) {
      final oldPostId = _posts[_currentPageIndex].id;
      _controllerCache[oldPostId]?.pause();
    }
    setState(() => _currentPageIndex = newPage);
    _manageControllerCache(newPage);
  }

  Future<void> _manageControllerCache(int page) async {
    if (page < 0 || page >= _posts.length) return;

    // ✅ 3. This function now prepares the video and plays it ONLY if already started by the user.
    await _prepareAndPlayCurrentVideo(page);

    // Pre-initialize neighbors
    if (page + 1 < _posts.length) _initializeControllerForIndex(page + 1);
    if (page - 1 >= 0) _initializeControllerForIndex(page - 1);

    // Dispose of controllers outside the cache window
    final idsToKeep = {_posts[page].id};
    if (page > 0) idsToKeep.add(_posts[page - 1].id);
    if (page < _posts.length - 1) idsToKeep.add(_posts[page + 1].id);

    _controllerCache.keys
        .where((id) => !idsToKeep.contains(id))
        .toList()
        .forEach(_disposeController);
  }

  // Renamed from _initializeAndPlay to be more descriptive
  Future<void> _prepareAndPlayCurrentVideo(int index) async {
    if (index < 0 || index >= _posts.length) return;

    final post = _posts[index];
    _currentPostId = post.id;
    VideoPlayerController? controller = _controllerCache[post.id];

    if (controller == null) {
      await _initializeControllerForIndex(index);
      controller = _controllerCache[post.id];
    }

    if (controller?.value.isInitialized ?? false) {
      await controller?.setLooping(true); // Loop is good for feeds
      // ✅ Play only if the user has previously initiated play for this video.
      if (_userHasInitiatedPlay.contains(post.id) && _isPageActive) {
        await controller?.play();
      }
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

  Future<void> _initializeControllerForIndex(int index) async {
    if (index < 0 || index >= _posts.length) return;
    final post = _posts[index];
    if (_controllerCache.containsKey(post.id) ||
        _initializingControllers.contains(post.id)) return;

    _initializingControllers.add(post.id);
    final controller =
        CachedVideoPlayerPlus.networkUrl(Uri.parse(post.videoUrl));
    try {
      await controller.initialize();
      if (mounted) {
        _controllerCache[post.id] = controller.controller;
        setState(() {});
      } else {
        await controller.dispose();
      }
    } catch (e) {
      debugPrint("Error pre-caching video for post ${post.id}: $e");
    } finally {
      _initializingControllers.remove(post.id);
    }
  }

  // ✅ 4. Fixed app lifecycle logic
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_currentPostId == null) return;
    final controller = _controllerCache[_currentPostId!];

    if (state == AppLifecycleState.paused) {
      controller?.pause();
    } else if (state == AppLifecycleState.resumed) {
      // If the page is active and the user had played this video, resume it.
      if (_isPageActive && _userHasInitiatedPlay.contains(_currentPostId!)) {
        controller?.play();
      }
    }
  }

  // ... (keep the rest of your methods like _showNotificationsDialog and _buildNowChip)

  void _showNotificationsDialog(BuildContext context) {
    setState(() {
      _hasNewNotifications = false;
    });
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
                if (totalPosts < 0)
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
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
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Badge(
                // This makes the dot appear or disappear
                isLabelVisible: _hasNewNotifications,
                // Leaving the label null creates the small red dot
                child: const Icon(Icons.notifications_none_rounded),
              ),
              tooltip: 'Notifications',
              onPressed: () => _showNotificationsDialog(context),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.4),
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: BlocConsumer<FeedBloc, FeedState>(
          listener: (context, state) {
            if (state is FeedLoaded) {
              setState(() {
                _posts = state.posts;
                _authors = state.authors;
              });
              _manageControllerCache(0);
            }
          },
          builder: (context, state) {
            // LOADING STATE
            if (state is FeedLoading || state is FeedInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            // ERROR STATE
            if (state is FeedError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (_posts.isNotEmpty) {
              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: _posts.length,
                physics: const BouncingScrollPhysics(),
                // clipBehavior: Clip.none,

                itemBuilder: (context, index) {
                  final post = _posts[index];
                  final author = _authors[post.userId];
                  return BlocProvider<ProfileBloc>(
                      create: (context) => di.sl<ProfileBloc>()
                        ..add(SubscribeToUserProfile(author!.id)),
                      child: VideoPostItem(
                          key: ValueKey(post.id),
                          post: post,
                          author: author,
                          controller: _controllerCache[post.id],
                          isCurrentPage: index == _currentPageIndex,
                          onUserTapped: (userId) {
                            context.push('/profile/$userId');
                          },
                          // ✅ 5. Add a callback to notify when the user presses play.
                          onPlayPressed: () {
                            if (!_userHasInitiatedPlay.contains(post.id)) {
                              setState(() {
                                _userHasInitiatedPlay.add(post.id);
                              });
                            }
                            _controllerCache[post.id]?.play();
                          }));
                },
              );
            }
            // Fallback for any other state
            return const Center(
              child: Text("No posts found."),
            );
          },
        ),
      ),
    );
  }

// ... Keep the rest of the file the same
}