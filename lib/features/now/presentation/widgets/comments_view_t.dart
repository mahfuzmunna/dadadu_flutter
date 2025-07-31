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

// Replace your existing _CommentList and _CommentListState with these two widgets.

class _CommentList extends StatelessWidget {
  final List<CommentEntity> comments;
  final ScrollController controller;
  final String postId;

  const _CommentList({
    required this.comments,
    required this.controller,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Center(
        child: Text("No comments yet.", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      controller: controller,
      itemCount: comments.length,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (context, index) {
        final comment = comments[index];
        // ✅ Use the new, self-contained widget for each item.
        return _CommentListItem(
          key: ValueKey(comment.id), // Use a unique key
          comment: comment,
          postId: postId,
        );
      },
    );
  }
}

// ✅ NEW: A dedicated StatefulWidget for each comment item.
class _CommentListItem extends StatefulWidget {
  final CommentEntity comment;
  final String postId;

  const _CommentListItem({
    super.key,
    required this.comment,
    required this.postId,
  });

  @override
  State<_CommentListItem> createState() => _CommentListItemState();
}

class _CommentListItemState extends State<_CommentListItem> {
  bool _isTranslating = false;
  bool _isLikeUnlikeAction = false;

  // This widget now manages its own 'liked' state.
  late bool _isLiked;
  UserEntity? _currentUser;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUser = authState.user;
    }
    // Set the initial liked state for this specific comment.
    _isLiked = widget.comment.likedBy.contains(_currentUser?.id);
  }

  // This ensures the UI updates if the comment data from the BLoC changes.
  @override
  void didUpdateWidget(covariant _CommentListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.comment != oldWidget.comment) {
      setState(() {
        _isLiked = widget.comment.likedBy.contains(_currentUser?.id);
      });
    }
  }

  void _toggleLike() {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to like.')),
      );
      return;
    }

    // Dispatch the correct event based on the current liked state.
    final event = _isLiked
        ? UnlikeComment(
            userId: _currentUser!.id,
            postId: widget.postId,
            commentId: widget.comment.id,
          )
        : LikeComment(
            userId: _currentUser!.id,
            postId: widget.postId,
            commentId: widget.comment.id,
          );

    context.read<LikeUnlikeCommentBloc>().add(event);
    setState(() {
      _isLikeUnlikeAction = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: widget.comment.author?.profilePhotoUrl != null
            ? CachedNetworkImageProvider(
                widget.comment.author!.profilePhotoUrl!)
            : null,
        child: widget.comment.author?.profilePhotoUrl == null
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(widget.comment.author?.username ?? 'Anonymous',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.comment.comment),
          const SizedBox(height: 4),
          TextButton.icon(
            icon: _isTranslating
                ? const SizedBox(
                    height: 12,
                    width: 12,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : null,
            onPressed: () {
              // This setState now only affects this individual widget.
              setState(() => _isTranslating = true);
              // Simulate translation
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) setState(() => _isTranslating = false);
              });
            },
            label: Text(
              _isTranslating ? 'Translating...' : 'Translate',
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
        trailing: _isLikeUnlikeAction
            ? Text('Sent')
            : TextButton.icon(
                onPressed: _toggleLike,
        icon: _isLiked
            ? const Icon(Icons.favorite, color: Colors.red)
            : const Icon(Icons.favorite_border),
                label: Text('${widget.comment.likes}'),
              ));
  }
}
