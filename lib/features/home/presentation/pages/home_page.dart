// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dadadu_app/features/home/presentation/bloc/home_feed_bloc.dart';
import 'package:dadadu_app/features/home/presentation/widgets/video_post_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Ensure HomeFeedBloc is available in the BuildContext at this point.
    context.read<HomeFeedBloc>().add(const FetchPosts(isInitialFetch: true));

    _pageController.addListener(() {
      int newPageIndex = _pageController.page?.round() ?? 0;

      if (newPageIndex != _currentPageIndex) {
        setState(() {
          _currentPageIndex = newPageIndex;
        });

        // Trigger fetch more when user scrolls near the end
        if (_pageController.position.pixels >= _pageController.position.maxScrollExtent * 0.8) {
          final currentState = context.read<HomeFeedBloc>().state;
          if (currentState is HomeFeedLoaded && currentState.hasMore) {
            context.read<HomeFeedBloc>().add(const FetchPosts(isInitialFetch: false));
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No BlocProvider for HomeFeedBloc here as it's provided higher up the widget tree.
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Keep transparent for video overlay
        elevation: 0, // No shadow for a flat, modern look
        title: Text(
          'For You',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white, // Explicitly white for contrast over video
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<HomeFeedBloc, HomeFeedState>(
        builder: (context, state) {
          if (state is HomeFeedInitial || (state is HomeFeedLoading && state.isFirstFetch)) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary, // Uses M3 primary color
              ),
            );
          } else if (state is HomeFeedLoaded) {
            if (state.posts.isEmpty && !state.hasMore) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0), // Added more padding
                  child: Text(
                    'No videos available yet. Be the first to upload!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8), // Using M3 onBackground color with opacity
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: state.posts.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.posts.length) {
                  // Loading indicator at the end of the list if hasMore is true
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                }

                final post = state.posts[index];
                final postUser = state.userCache[post.userId];

                return VideoPostItem(
                  post: post,
                  postUser: postUser,
                  isCurrentPage: index == _currentPageIndex,
                );
              },
            );
          } else if (state is HomeFeedError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0), // Added padding for better spacing
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error, // Uses M3 error color
                      size: 80,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Failed to load posts: ${state.message}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error, // Uses M3 error color for text
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeFeedBloc>().add(const FetchPosts(isInitialFetch: true));
                      },
                      // Let the button inherit its style from the Material 3 theme
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}