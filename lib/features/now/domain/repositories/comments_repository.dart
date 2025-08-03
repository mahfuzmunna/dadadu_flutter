// lib/features/now/data/repositories/feed_repository_impl.dart

import 'package:dadadu_app/features/now/data/datasources/comments_remote_data_source.dart';

abstract class CommentsRepository {
  Stream<CommentsResult> streamComments({required String postId});
}

class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsRemoteDataSource _remote;

  CommentsRepositoryImpl(this._remote);

  @override
  Stream<CommentsResult> streamComments({required String postId}) =>
      _remote.streamComments(postId: postId);
}
