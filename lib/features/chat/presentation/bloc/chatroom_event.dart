part of 'chatroom_bloc.dart';

abstract class ChatRoomEvent extends Equatable {
  const ChatRoomEvent();

  @override
  List<Object> get props => [];
}

// Event to trigger the creation of a chat room
class CreateChatRoom extends ChatRoomEvent {
  final CreateChatRoomParams params;

  const CreateChatRoom({required this.params});

  @override
  List<Object> get props => [params];
}
