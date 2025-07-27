import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

import '../entities/chat_room_entity.dart';

class StreamChatRoomsUseCase
    implements UseCase<Stream<List<ChatRoomEntity>>, void> {
  final ChatRepository repository;

  StreamChatRoomsUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<List<ChatRoomEntity>>>> call(
      void params) async {
    return repository.streamChatRooms();
  }
}
