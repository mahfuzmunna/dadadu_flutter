import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String roomId;
  final String content;
  final DateTime createdAt;

  const ChatMessageEntity({
    required this.id,
    required this.senderId,
    required this.roomId,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, senderId, roomId, content, createdAt];
}
