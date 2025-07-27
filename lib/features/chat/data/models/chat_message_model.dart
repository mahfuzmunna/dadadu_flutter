import 'package:dadadu_app/features/chat/domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.senderId,
    required super.roomId,
    required super.content,
    required super.createdAt,
  });

  /// Creates a ChatMessageModel from a Supabase database map.
  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] as String,
      senderId: map['sender_id'] as String,
      roomId: map['room_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Converts a ChatMessageModel to a map for inserting into Supabase.
  Map<String, dynamic> toMap() {
    return {
      // 'id' and 'created_at' are handled by the database
      'sender_id': senderId,
      'room_id': roomId,
      'content': content,
    };
  }
}
