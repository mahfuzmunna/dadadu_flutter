// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Still needed for context.read and BlocBuilder
// No longer needs GoRouter import unless doing direct navigation from this page
// No longer needs injection_container.dart import as the bloc is read from context

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
    // <<< This is where the HomeFeedBloc is being read
    // It must be available in the BuildContext at this point.
    context.read<HomeFeedBloc>().add(const FetchPosts(isInitialFetch: true));

    _pageController.addListener(() {
      int newPageIndex = _pageController.page?.round() ?? 0;

      if (newPageIndex != _currentPageIndex) {
        setState(() {
          _currentPageIndex = newPageIndex;
        });

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
    // NO BlocProvider FOR HomeFeedBloc HERE!
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'For You',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<HomeFeedBloc, HomeFeedState>(
        builder: (context, state) {
          if (state is HomeFeedInitial || (state is HomeFeedLoading && state.isFirstFetch)) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          } else if (state is HomeFeedLoaded) {
            if (state.posts.isEmpty && !state.hasMore) {
              return const Center(
                child: Text(
                  'No videos available yet. Be the first to upload!',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: state.posts.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.posts.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ));
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 80),
                  const SizedBox(height: 20),
                  Text(
                    'Failed to load posts: ${state.message}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeFeedBloc>().add(const FetchPosts(isInitialFetch: true));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}