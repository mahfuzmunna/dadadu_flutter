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
    try {
      final currentUserId = supabaseClient.auth.currentUser?.id;
      if (currentUserId == null)
        throw ServerException('User not authenticated.');

      final stream = supabaseClient
          .from('chat_rooms')
          .stream(primaryKey: ['id'])
          // .contains('participant_ids', [currentUserId])
          // .in_('column', [value1, value2])
          .eq('is_private', true)
          .order('updated_at')
          .map((listOfRoomMaps) async {
            if (listOfRoomMaps.isEmpty) return <ChatRoomModel>[];

            // 1. Get all participant and last message IDs
            final otherParticipantIds = <String>{};
            final lastMessageIds = <String>{};
            for (final roomMap in listOfRoomMaps) {
              final participantIds =
                  List<String>.from(roomMap['participant_ids']);
              otherParticipantIds
                  .add(participantIds.firstWhere((id) => id != currentUserId));
              if (roomMap['last_message_id'] != null) {
                lastMessageIds.add(roomMap['last_message_id']);
              }
            }

            // 2. Fetch all required profiles and messages in batch
            final [authorMaps, messageMaps] = await Future.wait([
              supabaseClient
                  .from(AppConfig.supabaseUserTable)
                  .select()
                  .filter('id', 'in', '(${otherParticipantIds.join(',')})'),
              if (lastMessageIds.isNotEmpty)
                supabaseClient
                    .from('chat_messages')
                    .select()
                    .filter('id', 'in', '(${lastMessageIds.join(',')})')
              else
                Future.value(<Map<String, dynamic>>[])
            ]);

            final authorsById = {
              for (var map in authorMaps) map['id']: UserModel.fromMap(map)
            };
            final messagesById = {
              for (var map in messageMaps)
                map['id']: ChatMessageModel.fromMap(map)
            };

            // 3. Build the final ChatRoomModel list
            return listOfRoomMaps.map((roomMap) {
              final participantIds =
                  List<String>.from(roomMap['participant_ids']);
              final otherId =
                  participantIds.firstWhere((id) => id != currentUserId);
              return ChatRoomModel.fromMap(
                roomMap,
                otherParticipant: authorsById[otherId]!,
                lastMessage: messagesById[roomMap['last_message_id']],
              );
            }).toList();
          });

      // Since the inner map is async, the stream returns Future<List<ChatRoomModel>>.
      // We need to flatten it.
      return stream.asyncExpand((futureList) => Stream.fromFuture(futureList));
    } catch (e) {
      throw ServerException(e.toString());
    }
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