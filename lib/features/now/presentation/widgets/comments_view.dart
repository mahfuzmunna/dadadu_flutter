import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../comments/domain/entities/comment_entity.dart';
import '../../../comments/presentation/bloc/comments_bloc.dart';

class CommentsView extends StatelessWidget {
  final ScrollController scrollController;

  const CommentsView({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<CommentsBloc, CommentsState>(
              builder: (context, state) {
                if (state is CommentsLoading || state is CommentsInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CommentsError) {
                  return Center(child: Text(state.message));
                }
                if (state is CommentsLoaded) {
                  return DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'Recent'),
                            Tab(text: 'Popular'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _CommentList(
                                  comments: state.recent,
                                  controller: scrollController),
                              _CommentList(
                                  comments: state.popular,
                                  controller: scrollController),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentList extends StatelessWidget {
  final List<CommentEntity> comments;
  final ScrollController controller;

  const _CommentList({required this.comments, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Center(child: Text("No comments yet."));
    }
    return ListView.builder(
      controller: controller,
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: comment.author?.profilePhotoUrl != null
                ? CachedNetworkImageProvider(comment.author!.profilePhotoUrl!)
                : null,
            child: comment.author?.profilePhotoUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(comment.author?.username ?? 'Anonymous'),
          subtitle: Text(comment.comment),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_border, size: 16),
              Text(comment.likes.toString()),
            ],
          ),
        );
      },
    );
  }
}
