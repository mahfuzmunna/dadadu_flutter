import 'package:dadadu_app/features/chat/domain/entities/chat_room_entity.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatRoomModel extends ChatRoomEntity {
  const ChatRoomModel({
    required super.id,
    required super.participantIds,
    required super.otherParticipant,
    super.lastMessage,
    required super.createdAt,
    required super.updatedAt,
  });

  /// This factory constructor is built directly from the logic in your
  /// `streamChatRooms` method. It combines data from three different
  /// sources (the room, the other participant's profile, and the last message)
  /// to build the final object.
  factory ChatRoomModel.fromMap(Map<String, dynamic> map, {
    required UserEntity otherParticipant,
    ChatMessageEntity? lastMessage,
  }) {
    return ChatRoomModel(
      id: map['id'] as String,
      participantIds: List<String>.from(map['participant_ids'] as List),
      otherParticipant: otherParticipant,
      lastMessage: lastMessage,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}