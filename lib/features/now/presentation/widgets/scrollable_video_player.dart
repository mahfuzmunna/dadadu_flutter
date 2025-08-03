// lib/features/now/presentation/widgets/scrollable_video_player.dart

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/now/presentation/widgets/video_post_item_s.dart';
import 'package:dadadu_app/features/posts/domain/entities/post_entity.dart';
import 'package:dadadu_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:dadadu_app/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../bloc/feed_bloc.dart';

class ScrollableVideoPlayer extends StatefulWidget {
  final List<PostEntity> posts;
  final Map<String, UserEntity> authors;
  final int initialPostIndex;

  const ScrollableVideoPlayer({
    super.key,
    required this.posts,
    required this.authors,
    this.initialPostIndex = 0,
  });

  @override
  State<ScrollableVideoPlayer> createState() => _ScrollableVideoPlayerState();
}

class _ScrollableVideoPlayerState extends State<ScrollableVideoPlayer>
    with WidgetsBindingObserver {
  late final PageController _pageController;
  late GoRouter _router;
  bool _isPageActive = true;
  int _currentPageIndex = 0;

  final Map<String, VideoPlayerController> _controllerCache = {};
  String? _currentPostId;
  final Set<String> _initializingControllers = {};
  final Set<String> _userHasInitiatedPlay = {};

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPostIndex;
    _pageController = PageController(initialPage: _currentPageIndex);

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
      _handleRouteChange(); // Set initial state
      _manageControllerCache(_currentPageIndex); // Initial video load
    });
  }

  void _handleRouteChange() {
    if (!mounted) return;
    final String topRoute =
        _router.routerDelegate.currentConfiguration.fullPath;
    final bool isActive = (topRoute == '/'); // Specific to the main feed

    if (_isPageActive != isActive) {
      setState(() => _isPageActive = isActive);
      final controller = _controllerCache[_currentPostId];
      if (controller == null) return;

      if (isActive && _userHasInitiatedPlay.contains(_currentPostId!)) {
        controller.play();
      } else {
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
    if (widget.posts.isNotEmpty && _currentPageIndex < widget.posts.length) {
      final oldPostId = widget.posts[_currentPageIndex].id;
      _controllerCache[oldPostId]?.pause();
    }
    setState(() => _currentPageIndex = newPage);
    _manageControllerCache(newPage);
  }

  Future<void> _manageControllerCache(int page) async {
    if (page < 0 || page >= widget.posts.length) return;
    await _prepareAndPlayCurrentVideo(page);
    if (page + 1 < widget.posts.length) _initializeControllerForIndex(page + 1);
    if (page - 1 >= 0) _initializeControllerForIndex(page - 1);

    final idsToKeep = {widget.posts[page].id};
    if (page > 0) idsToKeep.add(widget.posts[page - 1].id);
    if (page < widget.posts.length - 1)
      idsToKeep.add(widget.posts[page + 1].id);

    _controllerCache.keys
        .where((id) => !idsToKeep.contains(id))
        .toList()
        .forEach(_disposeController);
  }

  Future<void> _prepareAndPlayCurrentVideo(int index) async {
    if (index < 0 || index >= widget.posts.length) return;
    final post = widget.posts[index];
    _currentPostId = post.id;
    VideoPlayerController? controller = _controllerCache[post.id];

    if (controller == null) {
      await _initializeControllerForIndex(index);
      controller = _controllerCache[post.id];
    }

    if (controller?.value.isInitialized ?? false) {
      await controller?.setLooping(true);
      if (_userHasInitiatedPlay.contains(post.id) && _isPageActive) {
        await controller?.play();
      }
    }
  }

  Future<void> _initializeControllerForIndex(int index) async {
    if (index < 0 || index >= widget.posts.length) return;
    final post = widget.posts[index];
    if (_controllerCache.containsKey(post.id) ||
        _initializingControllers.contains(post.id)) return;

    _initializingControllers.add(post.id ?? '');
    final controller =
        CachedVideoPlayerPlus.networkUrl(Uri.parse(post.videoUrl!));
    try {
      await controller.initialize();
      if (mounted) {
        _controllerCache[post.id ?? ''] = controller.controller;
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_currentPostId == null) return;
    final controller = _controllerCache[_currentPostId!];
    if (state == AppLifecycleState.paused) {
      controller?.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (_isPageActive && _userHasInitiatedPlay.contains(_currentPostId!)) {
        controller?.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) {
      return const Center(child: Text("No posts found."));
    }

    return BlocConsumer<FeedBloc, FeedState>(listener: (context, state) {
      if (state is FeedLoaded && state.degraded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Partial data: ${state.message}')),
        );
      }
    }, builder: (context, state) {
      return PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.posts.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final post = widget.posts[index];

          final author = widget.authors[post.userId];
          final controller = _controllerCache[post.id];

          if (controller == null || author == null) {
                return Container(
                  color: Colors.black,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
          return BlocProvider<ProfileBloc>(
            create: (context) =>
                di.sl<ProfileBloc>()..add(SubscribeToUserProfile(author.id)),
            child: VideoPostItem(
              key: ValueKey(post.id),
              post: post,
              author: author,
              controller: controller,
              isCurrentPage: index == _currentPageIndex,
              onUserTapped: (userId) => context.push('/profile/$userId'),
              onPlayPressed: () {
                if (!_userHasInitiatedPlay.contains(post.id)) {
                  setState(() {
                    _userHasInitiatedPlay.add(post.id ?? '');
                  });
                }
                _controllerCache[post.id]?.play();
              },
            ),
          );
        },
      );
    });
  }
}
