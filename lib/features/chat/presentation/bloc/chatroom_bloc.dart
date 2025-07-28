import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/chat/domain/usecases/create_chat_room_usecase.dart';
import 'package:equatable/equatable.dart';

part 'chatroom_event.dart';
part 'chatroom_state.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final CreateChatRoomUseCase _createChatRoomUseCase;

  ChatRoomBloc({required CreateChatRoomUseCase createChatRoomUseCase})
      : _createChatRoomUseCase = createChatRoomUseCase,
        super(ChatRoomInitial()) {
    on<CreateChatRoom>(_onCreateChatRoom);
  }

  void _onCreateChatRoom(
      CreateChatRoom event, Emitter<ChatRoomState> emit) async {
    // 1. Emit a loading state to the UI
    emit(ChatRoomCreating());

    // 2. Call the use case
    final result = await _createChatRoomUseCase(event.userIds);

    // 3. Emit success or error based on the result
    result.fold(
      (failure) => emit(ChatRoomError(message: failure.message)),
      (roomId) => emit(ChatRoomCreated(roomId: roomId)),
    );
  }
}
