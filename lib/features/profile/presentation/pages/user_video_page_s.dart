import 'package:cached_video_player_plus/cached_video_player_plus.dart';
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
import '../../../posts/presentation/bloc/diamond_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../bloc/follow_bloc.dart';
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
        BlocProvider(create: (context) => di.sl<FollowBloc>()),
        BlocProvider(create: (context) => di.sl<DiamondBloc>()),
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
  UserEntity? _author;
  int _currentPageIndex = 0;
  final Map<String, VideoPlayerController> _controllerCache = {};
  final Set<String> _initializingControllers = {};
  List<PostEntity> _posts = [];
  late GoRouter _router;
  bool _isPageActive = true;
  bool _hasNewNotifications = true;

  String? _currentPostId;

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
            icon: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded)),
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
            // LOADED STATE
            if (_posts.isNotEmpty) {
              final PostEntity initialPost =
                  _posts.firstWhere((post) => post.id == widget.initialPostId);
              _author = _authors[initialPost.userId];

              final usersPosts = _posts
                  .where((post) => post.userId == initialPost.userId)
                  .toList();
              final initialPageIndex =
                  usersPosts.indexWhere((post) => post.id == initialPost.id);

              // if (_pageController.initialPage != initialPageIndex) {
              //   _pageController = PageController(initialPage: initialPageIndex);
              //   _currentPageIndex = initialPageIndex;
              //   _pageController.addListener(() {
              //     final newPage = _pageController!.page?.round() ?? 0;
              //     if (newPage != _currentPageIndex) {
              //       _onPageChanged(usersPosts, newPage);
              //     }
              //   });
              //   // Initial load for the first video
              //   WidgetsBinding.instance.addPostFrameCallback((_) {
              //     _manageControllerCache(usersPosts, initialPageIndex);
              //   });
              // }

              if (usersPosts.isEmpty) {
                return const Center(child: Text("This user has no posts."));
              }

              return PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: usersPosts.length,
                  itemBuilder: (context, index) {
                    final post = usersPosts[index];
                    final author = _author;
                    return BlocProvider<ProfileBloc>(
                      create: (context) => di.sl<ProfileBloc>()
                        ..add(SubscribeToUserProfile(author!.id)),
                      child: VideoPostItem(
                        key: ValueKey(post.id),
                        post: post,
                        author: author,
                        controller: _controllerCache[post.id],
                        isCurrentPage: index == _currentPageIndex,
                        onPlayPressed: () {
                          if (!_userHasInitiatedPlay.contains(post.id)) {
                            setState(() {
                              _userHasInitiatedPlay.add(post.id);
                            });
                          }
                          _controllerCache[post.id]?.play();
                        },
                        onUserTapped: (userId) =>
                            context.push('/profile/${userId}'),
                      ),
                    );
                  });
            }
            // Fallback for any other state
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
