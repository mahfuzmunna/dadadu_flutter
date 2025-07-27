import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/features/chat/domain/entities/chat_message_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepository {
  Either<Failure, Stream<List<ChatMessageEntity>>> streamMessages(
      String roomId);

  Future<Either<Failure, void>> sendMessage(
      {required String roomId,
      required String content,
      required String senderId});
}
