// lib/features/now/data/datasources/feed_remote_data_source.dart

import 'dart:async';

import 'package:dadadu_app/config/app_config.dart';
import 'package:dadadu_app/core/errors/exceptions.dart';
import 'package:dadadu_app/features/now/data/models/comment_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/data/models/user_model.dart';

class CommentsData {
  final List<CommentModel> comments;
  final Map<String, UserModel> authors;

  const CommentsData(this.comments, this.authors);
}

class CommentsResult {
  final CommentsData data;
  final String? errorMessage; // non-null means partial failure

  const CommentsResult({required this.data, this.errorMessage});

  bool get isPartial => errorMessage != null;
}

abstract class CommentsRemoteDataSource {
  Stream<CommentsResult> streamComments({required String postId});

  void dispose();
}

class CommentsRemoteDataSourceImpl implements CommentsRemoteDataSource {
  final SupabaseClient _supabaseClient;

  // Simple in-memory author cache to avoid refetching same user repeatedly.
  final Map<String, UserModel> _authorCache = {};
  StreamSubscription<dynamic>? _authorChangeSub;

  CommentsRemoteDataSourceImpl(this._supabaseClient) {
    _subscribeToAuthorUpdates();
  }

  @override
  Stream<CommentsResult> streamComments({required String postId}) {
    final commentStream = _supabaseClient
        .from(AppConfig.supabaseCommentsTable)
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at', ascending: false);

    return commentStream.asyncMap((listOfCommentMaps) async {
      if (listOfCommentMaps.isEmpty) {
        return CommentsResult(
            data: CommentsData(const [], Map.unmodifiable(_authorCache)));
      }

      final comments = listOfCommentMaps
          .map((raw) =>
              CommentModel.fromMap(Map<String, dynamic>.from(raw as Map)))
          .toList();

      final userIds = comments.map((p) => p.userId).toSet();
      final missingAuthorIds = userIds.difference(_authorCache.keys.toSet());

      String? partialError;

      if (missingAuthorIds.isNotEmpty) {
        try {
          final authorMaps = await _supabaseClient
              .from(AppConfig.supabaseUserTable)
              .select()
              .inFilter('id', missingAuthorIds.toList());

          for (var raw in authorMaps) {
            final map = Map<String, dynamic>.from(raw as Map);
            final id = map['id'] as String;
            _authorCache[id] = UserModel.fromMap(map);
          }
        } catch (e) {
          partialError = 'Failed to load some author profiles: ${e.toString()}';
          debugPrint(partialError);
        }
      }

      final authorsSnapshot = Map<String, UserModel>.unmodifiable(
        Map.of(_authorCache),
      );

      return CommentsResult(
        data: CommentsData(comments, authorsSnapshot),
        errorMessage: partialError,
      );
    }).handleError((e) {
      throw ServerException('Failed to stream feed: ${e.toString()}');
    });
  }

  void _subscribeToAuthorUpdates() {
    if (_authorChangeSub != null) return;

    // Listen to changes on users to refresh cached author entries.
    _authorChangeSub = _supabaseClient
        .from(AppConfig.supabaseUserTable)
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .listen((userMaps) {
          if (userMaps.isEmpty) return;
          var replaced = false;
          for (var raw in userMaps) {
            final map = Map<String, dynamic>.from(raw as Map);
            final id = map['id'] as String;
            if (_authorCache.containsKey(id)) {
              _authorCache[id] = UserModel.fromMap(map);
              replaced = true;
            }
          }
          if (replaced) {
            // no direct emitter here; feedStream will re-run when posts change.
            // For immediate refresh you could add logic to push a synthetic event.
          }
        });
  }

  @override
  void dispose() {
    _authorChangeSub?.cancel();
    _authorChangeSub = null;
  }
}
