import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/chat/domain/entities/chat_message_entity.dart';
import 'package:dadadu_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class StreamMessagesUseCase
    implements UseCase<Stream<List<ChatMessageEntity>>, String> {
  final ChatRepository repository;

  StreamMessagesUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<List<ChatMessageEntity>>>> call(
      String params) async {
    return repository.streamMessages(params);
  }
}
