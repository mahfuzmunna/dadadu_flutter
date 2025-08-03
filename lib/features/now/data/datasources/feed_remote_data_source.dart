// feed_remote_data_source.dart
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

/// A richer result so caller can know if authors partially failed.
class FeedResult {
  final FeedData data;
  final String? errorMessage; // null if clean

  const FeedResult({required this.data, this.errorMessage});

  bool get isPartial => errorMessage != null;
}

abstract class FeedRemoteDataSource {
  /// Streams the feed: posts + authors. Emits incremental updates.
  Stream<FeedResult> streamFeed();
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final SupabaseClient _supabaseClient;

  // Simple in-memory author cache
  final Map<String, UserModel> _authorCache = {};

  // Tracks listeners for author changes to invalidate
  StreamSubscription<dynamic>? _authorChangeSub;

  FeedRemoteDataSourceImpl(this._supabaseClient);

  @override
  Stream<FeedResult> streamFeed() {
    // Start listening to user changes for cached authors to invalidate stale entries
    _setupAuthorInvalidation();

    return _supabaseClient
        .from(AppConfig.supabasePostTable)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((listOfPostMaps) async {
          if (listOfPostMaps.isEmpty) {
            return FeedResult(
              data: FeedData(const [], Map.unmodifiable(_authorCache)),
            );
          }

          final posts = listOfPostMaps
          .map((map) =>
          PostModel.fromMap(Map<String, dynamic>.from(map as Map)))
          .toList();

          final userIds = posts.map((p) => p.userId).toSet();

          // Determine which authors are missing
      final missingAuthorIds =
      userIds.difference(_authorCache.keys.toSet()).toList();

          String? partialError;

          if (missingAuthorIds.isNotEmpty) {
        try {
          final authorMaps = await _supabaseClient
              .from(AppConfig.supabaseUserTable)
              .select()
              .filter('id', 'in', '(${missingAuthorIds.join(',')})');
          // .in_('id', missingAuthorIds);
          for (var map in authorMaps) {
            final safe = Map<String, dynamic>.from(map as Map);
            final id = safe['id'] as String;
            _authorCache[id] = UserModel.fromMap(safe);
          }
        } catch (e) {
          // fetch failed, but we can still proceed with whatever is cached
          partialError =
          'Failed to fetch some author profiles: ${e.toString()}';
          debugPrint(partialError);
        }
      }

      // Build snapshot copy (immutable externally)
      final authorsSnapshot = Map<String, UserModel>.unmodifiable(
        Map.of(_authorCache),
      );

      return FeedResult(
        data: FeedData(posts, authorsSnapshot),
        errorMessage: partialError,
      );
    }).handleError((e) {
      // Surface full-stream failures by wrapping in FeedResult with exception propagated via throw
      throw ServerException('Feed stream error: ${e.toString()}');
    });
  }

  void _setupAuthorInvalidation() {
    // If already subscribed, skip
    if (_authorChangeSub != null) return;

    // Listen to changes on users table for any author in cache
    _authorChangeSub = _supabaseClient
        .from(AppConfig.supabaseUserTable)
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .listen((userMaps) {
      if (userMaps.isEmpty) return;

      bool shouldNotify = false;

      for (var raw in userMaps) {
        final map = Map<String, dynamic>.from(raw as Map);
        final id = map['id'] as String;
        if (_authorCache.containsKey(id)) {
          // Replace with fresh copy
          _authorCache[id] = UserModel.fromMap(map);
          shouldNotify = true;
        }
      }

      if (shouldNotify) {
        // No-op: the feed stream will eventually emit again because posts may not change.
        // If you want immediate re-emission you could expose a controller and re-add last posts.
      }
    });
  }

  void dispose() {
    _authorChangeSub?.cancel();
    _authorChangeSub = null;
  }
}
