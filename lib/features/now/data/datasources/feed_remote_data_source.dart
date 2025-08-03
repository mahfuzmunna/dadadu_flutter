// lib/features/now/data/datasources/feed_remote_data_source.dart

import 'dart:async';

import 'package:dadadu_app/config/app_config.dart';
import 'package:dadadu_app/core/errors/exceptions.dart';
import 'package:dadadu_app/features/posts/data/models/post_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/data/models/user_model.dart';

class FeedData {
  final List<PostModel> posts;
  final Map<String, UserModel> authors;

  const FeedData(this.posts, this.authors);
}

class FeedResult {
  final FeedData data;
  final String? errorMessage; // non-null means partial failure

  const FeedResult({required this.data, this.errorMessage});

  bool get isPartial => errorMessage != null;
}

abstract class FeedRemoteDataSource {
  Stream<FeedResult> streamFeed();

  void dispose();
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final SupabaseClient _supabaseClient;

  // Simple in-memory author cache to avoid refetching same user repeatedly.
  final Map<String, UserModel> _authorCache = {};
  StreamSubscription<dynamic>? _authorChangeSub;

  FeedRemoteDataSourceImpl(this._supabaseClient) {
    _subscribeToAuthorUpdates();
  }

  @override
  Stream<FeedResult> streamFeed() {
    final postStream = _supabaseClient
        .from(AppConfig.supabasePostTable)
        .stream(primaryKey: ['id']).order('created_at', ascending: false);

    return postStream.asyncMap((listOfPostMaps) async {
      if (listOfPostMaps.isEmpty) {
        return FeedResult(
            data: FeedData(const [], Map.unmodifiable(_authorCache)));
      }

      final posts = listOfPostMaps
          .map(
              (raw) => PostModel.fromMap(Map<String, dynamic>.from(raw as Map)))
          .toList();

      final userIds = posts.map((p) => p.userId).toSet();
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

      return FeedResult(
        data: FeedData(posts, authorsSnapshot),
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
