part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

/// Dispatched to start listening to a stream of messages for a specific room.
class SubscribeToMessages extends ChatEvent {
  final String roomId;

  const SubscribeToMessages(this.roomId);

  @override
  List<Object> get props => [roomId];
}

/// Dispatched from the UI when the user sends a new message.
class SendMessage extends ChatEvent {
  final String roomId;
  final String content;
  final String senderId;

  const SendMessage({
    required this.roomId,
    required this.content,
    required this.senderId,
  });

  @override
  List<Object> get props => [roomId, content, senderId];
}

/// Internal event used to push updates from the real-time stream into the BLoC.
class _MessagesUpdated extends ChatEvent {
  final String roomId;
  final List<ChatMessageEntity> messages;

  const _MessagesUpdated({required this.roomId, required this.messages});

  @override
  List<Object> get props => [messages, roomId];
}
