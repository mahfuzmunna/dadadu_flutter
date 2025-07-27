part of 'chat_list_bloc.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object> get props => [];
}

/// Dispatched to start listening to the user's chat rooms.
class SubscribeToChatRooms extends ChatListEvent {}

/// Internal event to push updates from the stream into the BLoC.
class _ChatRoomsUpdated extends ChatListEvent {
  final List<ChatRoomEntity> rooms;

  const _ChatRoomsUpdated(this.rooms);
}
