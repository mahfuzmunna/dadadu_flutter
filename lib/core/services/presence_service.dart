// services/presence_service.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tracks online users globally using Supabase Presence.
/// Everyone joins the same channel ("global-presence") and tracks themselves.
class PresenceService {
  PresenceService._();

  static final PresenceService instance = PresenceService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  RealtimeChannel? _channel;
  final Map<String, List<Map<String, dynamic>>> _presenceState = {};
  final Set<String> _presenceStateX = {};

  // final StreamController<Set<String>> _onlineUsersController = StreamController.broadcast();
  final StreamController<Set<String>> _onlineUsersController =
      StreamController.broadcast();

  Stream<Set<String>> get onlineUsersStream => _onlineUsersController.stream;

  /// Initialize presence tracking for the given userId. Call after login.
  Future<void> init(String userId, {Map<String, dynamic>? metadata}) async {
    // Tear down existing if any
    if (_channel != null) {
      try {
        await _channel!.unsubscribe();
      } catch (_) {}
    }
    _presenceState.clear();
    _presenceStateX.clear();

    _channel = _supabase.channel(
      'global-presence',
      opts: RealtimeChannelConfig(self: true, key: userId),
    );

    // Full current state

    final userStatus = {
      'user': 'user-1',
      'online_at': DateTime.now().toIso8601String(),
    };
    _channel?.subscribe((status, error) async {
      if (status != RealtimeSubscribeStatus.subscribed) return;
      final presenceTrackStatus = await _channel?.track(userStatus);
      if (kDebugMode) {
        print(presenceTrackStatus);
      }
    });

    _channel?.onPresenceSync((_) {
      final newState = _channel?.presenceState();
      print('sync: $newState');
    }).onPresenceJoin((payload) {
      // _presenceState.addAll(payload.key);
      _presenceStateX.add(payload.key);
      // print(payload.);
      _emitOnlineUsers();
    }).onPresenceLeave((payload) {
      _presenceStateX.remove(payload.key);
      print('leave: $payload');
    }).subscribe();
  }

  void _emitOnlineUsers() {
    // final current = _presenceState.keys.toSet();
    final currentX = _presenceStateX.toSet();
    if (!_onlineUsersController.isClosed) {
      _onlineUsersController.add(currentX);
    }
  }

  /// Check current cached online status
  bool isUserOnline(String userId) {
    return _presenceState.containsKey(userId);
  }

  Future<void> dispose() async {
    if (_channel != null) {
      await _channel!.unsubscribe();
      _channel = null;
    }
    await _onlineUsersController.close();
    _presenceState.clear();
  }
}
