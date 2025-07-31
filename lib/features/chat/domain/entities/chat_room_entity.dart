import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/chat/domain/entities/chat_message_entity.dart';
import 'package:equatable/equatable.dart';

class ChatRoomEntity extends Equatable {
  final String id;
  final List<String> participantIds;
  final UserEntity otherParticipant; // The user you are chatting with
  final ChatMessageEntity? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatRoomEntity({
    required this.id,
    required this.participantIds,
    required this.otherParticipant,
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props =>
      [id, participantIds, otherParticipant, lastMessage, createdAt, updatedAt];
}
