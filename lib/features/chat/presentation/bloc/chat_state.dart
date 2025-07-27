part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

/// State emitted when messages have been successfully loaded.
class ChatLoaded extends ChatState {
  final List<ChatMessageEntity> messages;

  const ChatLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

/// State emitted when an error occurs while fetching messages.
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
