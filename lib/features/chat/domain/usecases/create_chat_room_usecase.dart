// ... imports
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class CreateChatRoomUseCase implements UseCase<String, List<String>> {
  final ChatRepository repository;

  CreateChatRoomUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(List<String> params) async {
    // params is a list of the two participant IDs
    return await repository.createChatRoom(participantIds: params);
  }
}
