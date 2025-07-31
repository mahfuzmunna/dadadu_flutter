import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/comments/presentation/bloc/like_unlike_comment_bloc.dart';
import 'package:dadadu_app/features/posts/domain/usecases/get_post_comments_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../comments/domain/entities/comment_entity.dart';
import '../../../comments/presentation/bloc/comments_bloc.dart';

class CommentsView extends StatelessWidget {
  final ScrollController scrollController;
  final String postId; // To know which post to add the comment to

  const CommentsView({
    super.key,
    required this.scrollController,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    // This padding ensures the input field moves up with the keyboard
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        // Add decoration for rounded corners
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important for keyboard padding
          children: [
            // Handle for dragging the sheet
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            // The main content (tabs and lists)
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
                                    postId: postId,
                                    controller: scrollController),
                                _CommentList(
                                    comments: state.popular,
                                    postId: postId,
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

            const Divider(),
            _CommentInputField(postId: postId),
          ],
        ),
      ),
    );
  }
}

class _CommentInputField extends StatefulWidget {
  final String postId;

  const _CommentInputField({required this.postId});

  @override
  State<_CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<_CommentInputField> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      context.read<CommentsBloc>().add(AddComment(
            CommentParams(
              userId: authState.user.id,
              postId: widget.postId,
              comment: text,
            ),
          ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to comment.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentsBloc, CommentsState>(
      listener: (context, state) {
        if (state is CommentAdded) {
          _textController.clear();
          FocusScope.of(context).unfocus();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comment submitted!')),
          );
        }
        if (state is CommentsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24.0)),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                ),
                onSubmitted: (_) => _submitComment(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send_rounded),
              onPressed: _submitComment,
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentList extends StatefulWidget {
  final List<CommentEntity> comments;
  final ScrollController controller;
  final String postId;

  const _CommentList(
      {required this.comments, required this.controller, required this.postId});

  @override
  State<_CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<_CommentList> {
  bool _isTranslating = false;
  bool _isLiked = false;
  UserEntity? currentUser;

  @override
  void initState() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      currentUser = authState.user;
    }
    super.initState();
  }

  void _likeComment(String commentId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<LikeUnlikeCommentBloc>().add(LikeComment(
            userId: authState.user.id,
            postId: widget.postId,
            commentId: commentId,
          ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to like.')),
      );
    }
  }

  void _unlikeComment(String commentId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<LikeUnlikeCommentBloc>().add(UnlikeComment(
            userId: authState.user.id,
            postId: widget.postId,
            commentId: commentId,
          ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to unlike.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final comments = widget.comments;
    final controller = widget.controller;
    if (comments.isEmpty) {
      return const Center(
          child:
              Text("No comments yet.", style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      controller: controller,
      itemCount: comments.length,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (context, index) {
        _isLiked = comments[index].likedBy.contains(currentUser?.id);
        final comment = comments[index];
        return ListTile(
          key: ValueKey(comment.comment),
          leading: CircleAvatar(
            backgroundImage: comment.author?.profilePhotoUrl != null
                ? CachedNetworkImageProvider(comment.author!.profilePhotoUrl!)
                : null,
            child: comment.author?.profilePhotoUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(comment.author?.username ?? 'Anonymous',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.comment),
              const SizedBox(height: 4),
              TextButton.icon(
                icon: _isTranslating
                    ? const SizedBox(
                        height: 8, width: 8, child: CircularProgressIndicator())
                    : null,
                onPressed: () {
                  setState(() {
                    _isTranslating = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Translating comment: "${comment.comment}"')),
                  );
                },
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    _isTranslating ? 'Translating...' : 'Translate',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          trailing: IconButton(
              onPressed: _isLiked
                  ? () => _unlikeComment(comment.id)
                  : () => _likeComment(comment.id),
              icon: _isLiked
                  ? const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                  : const Icon(Icons.favorite_border)),
        );
      },
    );
  }
}
