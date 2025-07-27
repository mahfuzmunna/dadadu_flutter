part of 'chat_list_bloc.dart';

abstract class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object> get props => [];
}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<ChatRoomEntity> rooms;

  const ChatListLoaded(this.rooms);

  @override
  List<Object> get props => [rooms];
}

class ChatListError extends ChatListState {
  final String message;

  const ChatListError(this.message);

  @override
  List<Object> get props => [message];
}
