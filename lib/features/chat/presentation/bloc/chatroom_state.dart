part of 'chatroom_bloc.dart';

abstract class ChatRoomState extends Equatable {
  const ChatRoomState();

  @override
  List<Object> get props => [];
}

class ChatRoomInitial extends ChatRoomState {}

// State when the chat room is being created (for loading indicators)
class ChatRoomCreating extends ChatRoomState {}

// State when the chat room is successfully created, providing the ID for navigation
class ChatRoomCreated extends ChatRoomState {
  final String roomId;

  const ChatRoomCreated({required this.roomId});

  @override
  List<Object> get props => [roomId];
}

// State for handling any errors during creation
class ChatRoomError extends ChatRoomState {
  final String message;

  const ChatRoomError({required this.message});

  @override
  List<Object> get props => [message];
}
