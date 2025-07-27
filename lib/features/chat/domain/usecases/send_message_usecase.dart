import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class SendMessageUseCase implements UseCase<void, SendMessageParams> {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SendMessageParams params) async {
    return await repository.sendMessage(
      roomId: params.roomId,
      content: params.content,
      senderId: params.senderId,
    );
  }
}

class SendMessageParams extends Equatable {
  final String roomId;
  final String content;
  final String senderId;

  const SendMessageParams(
      {required this.roomId, required this.content, required this.senderId});

  @override
  List<Object> get props => [roomId, content, senderId];
}
