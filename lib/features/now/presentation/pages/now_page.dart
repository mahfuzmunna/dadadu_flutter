import 'package:dadadu_app/features/now/presentation/bloc/feed_bloc.dart';
import 'package:dadadu_app/features/now/presentation/bloc/post_bloc.dart';
import 'package:dadadu_app/features/now/presentation/widgets/video_post_item.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:dadadu_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NowPage extends StatelessWidget {
  const NowPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the FeedBloc to the widget tree and immediately load the feed.
    return BlocProvider(
      create: (context) => sl<FeedBloc>()..add(LoadFeed()),
      child: const _HomePageView(),
    );
  }
}

class _HomePageView extends StatefulWidget {
  const _HomePageView();

  @override
  State<_HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<_HomePageView> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FeedBloc, FeedState>(
        builder: (context, state) {
          // LOADING STATE
          if (state is FeedLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // ERROR STATE
          if (state is FeedError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          // LOADED STATE
          if (state is FeedLoaded) {
            final List<PostEntity> posts = state.posts;

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

                return BlocProvider<PostBloc>(
                  create: (context) => sl<PostBloc>()..add(LoadPost(post.id)),
                  child: VideoPostItem(
                    isCurrentPage: index == _currentPageIndex,
                    onUserTapped: (userId) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tapped on user: $userId')),
                      );
                    },
                  ),
                );

                // CORRECT: Do NOT wrap this in a BlocProvider<FeedBloc>.
                // If you need a bloc for a single item, it should be a PostBloc.
                // For now, we remove the incorrect provider.
                /*return VideoPostItem(
                  post: post,
                  postUser: post.author,
                  isCurrentPage: index == _currentPageIndex,
                  onUserTapped: (userId) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped on user: $userId')),
                    );
                  },
                );*/
              },
            );
          }

          // Fallback for any other state
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
