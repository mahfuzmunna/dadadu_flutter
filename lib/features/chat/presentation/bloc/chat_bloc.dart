import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/chat/domain/entities/chat_message_entity.dart';
import 'package:dadadu_app/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:dadadu_app/features/chat/domain/usecases/stream_messages_usecase.dart';
import 'package:equatable/equatable.dart';

part 'chat_event.dart';

part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final StreamMessagesUseCase _streamMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  StreamSubscription? _messagesSubscription;

  ChatBloc({
    required StreamMessagesUseCase streamMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
  })  : _streamMessagesUseCase = streamMessagesUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        super(ChatInitial()) {
    on<SubscribeToMessages>(_onSubscribeToMessages);
    on<SendMessage>(_onSendMessage);
    on<_MessagesUpdated>(_onMessagesUpdated);
  }

  Future<void> _onSubscribeToMessages(
    SubscribeToMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    await _messagesSubscription?.cancel();
    final result = await _streamMessagesUseCase(event.roomId);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (stream) {
        _messagesSubscription = stream.listen((messages) {
          add(_MessagesUpdated(messages: messages, roomId: event.roomId));
        });
      },
    );
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    await _sendMessageUseCase(SendMessageParams(
      senderId: event.senderId,
      roomId: event.roomId,
      content: event.content,
    ));
    // Real-time stream handles the UI update
  }

  void _onMessagesUpdated(_MessagesUpdated event, Emitter<ChatState> emit) {
    emit(ChatLoaded(event.messages, event.roomId));
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
