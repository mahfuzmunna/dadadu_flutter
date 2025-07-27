import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/chat/domain/entities/chat_message_entity.dart';
import 'package:equatable/equatable.dart';

class ChatRoomEntity extends Equatable {
  final String id;

  // Details of the OTHER person in the chat
  final UserEntity otherParticipant;

  // The most recent message for preview
  final ChatMessageEntity? lastMessage;

  const ChatRoomEntity({
    required this.id,
    required this.otherParticipant,
    this.lastMessage,
  });

  @override
  List<Object?> get props => [id, otherParticipant, lastMessage];
}
