part of 'chatroom_bloc.dart';

abstract class ChatRoomEvent extends Equatable {
  const ChatRoomEvent();

  @override
  List<Object> get props => [];
}

// Event to trigger the creation of a chat room
class CreateChatRoom extends ChatRoomEvent {
  final List<String> userIds;

  const CreateChatRoom({required this.userIds});

  @override
  List<Object> get props => [userIds];
}
