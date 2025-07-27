import 'package:dadadu_app/core/errors/exceptions.dart';
import 'package:dadadu_app/features/chat/data/models/chat_message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatMessageModel>> streamMessages(String roomId);

  Future<void> sendMessage(
      {required String roomId,
      required String content,
      required String senderId});
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
      await supabaseClient.from('chat_messages').insert({
        'room_id': roomId,
        'sender_id': senderId,
        'content': content,
      });
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}