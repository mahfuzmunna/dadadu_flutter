import 'package:dadadu_app/config/app_config.dart';
import 'package:dadadu_app/core/errors/exceptions.dart';
import 'package:dadadu_app/features/chat/data/models/chat_message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/data/models/user_model.dart';
import '../models/chat_room_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatMessageModel>> streamMessages(String roomId);

  Stream<List<ChatRoomModel>> streamChatRooms();

  Future<void> sendMessage(
      {required String roomId,
      required String content,
      required String senderId});

  Future<String> createChatRoom(
      {required String userIdA, required String userIdB});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient supabaseClient;

  ChatRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Stream<List<ChatMessageModel>> streamMessages(String roomId) {
    try {
      final stream = supabaseClient
          .from('chat_messages')
          .stream(primaryKey: ['id'])
          .eq('room_id', roomId)
          .order('created_at', ascending: false);

      return stream.map(
          (data) => data.map((map) => ChatMessageModel.fromMap(map)).toList());
    } catch (e) {
      throw ServerException('Failed to stream messages: ${e.toString()}');
    }
  }

  @override
  Future<void> sendMessage(
      {required String roomId,
      required String content,
      required String senderId}) async {
    try {
      final message = await supabaseClient
          .from('chat_messages')
          .insert({
            'room_id': roomId,
        'sender_id': senderId,
        'content': content,
          })
          .select()
          .single();
      await supabaseClient
          .from('chat_rooms').update({
        'last_message_id': message['id'],
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', roomId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Stream<List<ChatRoomModel>> streamChatRooms() {
    final currentUserId = supabaseClient.auth.currentUser?.id;
    if (currentUserId == null) {
      // Early failure; return a stream that immediately errors.
      return Stream<List<ChatRoomModel>>.error(
        ServerException('User not authenticated.'),
      );
    }

    Stream<List<dynamic>> rawStream = supabaseClient
        .from('chat_rooms')
        .stream(primaryKey: ['id'])
        .inFilter('participant_ids',
        [currentUserId]) // include only rooms involving current user
    // .eq('is_private', true)
        .order('updated_at');

    return rawStream.asyncMap((listOfRoomMaps) async {
      if (listOfRoomMaps.isEmpty) return <ChatRoomModel>[];

      // 1. Collect other participant IDs and last message IDs.
      final otherParticipantIds = <String>{};
      final lastMessageIds = <String>{};

      for (final dynamic roomRaw in listOfRoomMaps) {
        if (roomRaw is! Map<String, dynamic>) continue;
        final participantIdsRaw = roomRaw['participant_ids'];
        if (participantIdsRaw is! Iterable) continue;
        final participantIds = participantIdsRaw.whereType<String>().toList();
        if (participantIds.isEmpty) continue;
        final otherId = participantIds.firstWhere(
              (id) => id != currentUserId,
          orElse: () => '',
        );
        if (otherId.isNotEmpty) {
          otherParticipantIds.add(otherId);
        }

        final lastMsgId = roomRaw['last_message_id'];
        if (lastMsgId is String && lastMsgId.isNotEmpty) {
          lastMessageIds.add(lastMsgId);
        }
      }

      // 2. Batch fetch required users and messages.
      final futures = <Future<dynamic>>[
        supabaseClient
            .from(AppConfig.supabaseUserTable)
            .select()
            .inFilter('id', otherParticipantIds.toList()),
        lastMessageIds.isNotEmpty
            ? supabaseClient
            .from('chat_messages')
            .select()
            .inFilter('id', lastMessageIds.toList())
            : Future.value(<Map<String, dynamic>>[]),
      ];

      final results = await Future.wait(futures);
      final authorMapsRaw = results[0];
      final messageMapsRaw = results[1];

      final authorsById = <String, UserModel>{};
      if (authorMapsRaw is Iterable) {
        for (final dynamic m in authorMapsRaw) {
          if (m is Map<String, dynamic> && m['id'] is String) {
            try {
              authorsById[m['id'] as String] = UserModel.fromMap(m);
            } catch (_) {
              // skip malformed user
            }
          }
        }
      }

      final messagesById = <String, ChatMessageModel>{};
      if (messageMapsRaw is Iterable) {
        for (final dynamic m in messageMapsRaw) {
          if (m is Map<String, dynamic> && m['id'] is String) {
            try {
              messagesById[m['id'] as String] = ChatMessageModel.fromMap(m);
            } catch (_) {
              // skip malformed message
            }
          }
        }
      }

      // 3. Build final models, skipping any room missing required data.
      final chatRooms = <ChatRoomModel>[];
      for (final dynamic roomRaw in listOfRoomMaps) {
        if (roomRaw is! Map<String, dynamic>) continue;

        final participantIdsRaw = roomRaw['participant_ids'];
        if (participantIdsRaw is! Iterable) continue;
        final participantIds = participantIdsRaw.whereType<String>().toList();
        if (participantIds.isEmpty) continue;

        final otherId = participantIds.firstWhere(
              (id) => id != currentUserId,
          orElse: () => '',
        );
        if (otherId.isEmpty) continue;

        final otherParticipant = authorsById[otherId];
        if (otherParticipant == null)
          continue; // skip if we don't have the other user

        final lastMessageId = roomRaw['last_message_id'];
        final lastMessage =
        (lastMessageId is String) ? messagesById[lastMessageId] : null;

        try {
          final roomModel = ChatRoomModel.fromMap(
            roomRaw,
            otherParticipant: otherParticipant,
            lastMessage: lastMessage,
          );
          chatRooms.add(roomModel);
        } catch (_) {
          // skip malformed room
        }
      }

      return chatRooms;
    });
  }


  @override
  Future<String> createChatRoom(
      {required String userIdA, required String userIdB}) async {
    try {
      // Call the database function we just created.
      final roomId = await supabaseClient.rpc(
        // 'create_get_chat_room',
        'get_or_create_private_chat_room',
        params: {'user_a': userIdA, 'user_b': userIdB},
      );

      // The RPC returns the room ID as a string.
      return roomId as String;
    } catch (e) {
      // Handle potential errors from the RPC call.
      throw ServerException(
          'Failed to create or get chat room: ${e.toString()}');
    }
  }
}