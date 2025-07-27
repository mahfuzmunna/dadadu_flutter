import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/chat/domain/entities/chat_room_entity.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/stream_chat_rooms_usecase.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final StreamChatRoomsUseCase _streamChatRoomsUseCase;
  StreamSubscription? _roomsSubscription;

  ChatListBloc({required StreamChatRoomsUseCase streamChatRoomsUseCase})
      : _streamChatRoomsUseCase = streamChatRoomsUseCase,
        super(ChatListInitial()) {
    on<SubscribeToChatRooms>(_onSubscribeToChatRooms);
    on<_ChatRoomsUpdated>(_onChatRoomsUpdated);
  }

  Future<void> _onSubscribeToChatRooms(
    SubscribeToChatRooms event,
    Emitter<ChatListState> emit,
  ) async {
    emit(ChatListLoading());
    await _roomsSubscription?.cancel();
    final result = await _streamChatRoomsUseCase(null);
    result.fold(
      (failure) => emit(ChatListError(failure.message)),
      (stream) {
        _roomsSubscription = stream.listen((rooms) {
          add(_ChatRoomsUpdated(rooms));
        });
      },
    );
  }

  void _onChatRoomsUpdated(
      _ChatRoomsUpdated event, Emitter<ChatListState> emit) {
    emit(ChatListLoaded(event.rooms));
  }

  @override
  Future<void> close() {
    _roomsSubscription?.cancel();
    return super.close();
  }
}
// Remember to create the corresponding event and state files for this BLoC.