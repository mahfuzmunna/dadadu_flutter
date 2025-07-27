import 'package:dadadu_app/features/auth/data/models/user_model.dart';
import 'package:dadadu_app/features/chat/data/models/chat_message_model.dart';
import 'package:dadadu_app/features/chat/domain/entities/chat_room_entity.dart';

class ChatRoomModel extends ChatRoomEntity {
  const ChatRoomModel({
    required super.id,
    required UserModel super.otherParticipant,
    ChatMessageModel? super.lastMessage,
  });

  factory ChatRoomModel.fromMap(
    Map<String, dynamic> map, {
    required UserModel otherParticipant,
    ChatMessageModel? lastMessage,
  }) {
    return ChatRoomModel(
      id: map['id'] as String,
      otherParticipant: otherParticipant,
      lastMessage: lastMessage,
    );
  }
}
