// ... imports
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class CreateChatRoomUseCase implements UseCase<String, CreateChatRoomParams> {
  final ChatRepository repository;

  CreateChatRoomUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateChatRoomParams params) async {
    // params is a list of the two participant IDs
    return await repository.createChatRoom(
        userIdA: params.userIdA, userIdB: params.userIdB);
  }
}

class CreateChatRoomParams extends Equatable {
  final String userIdA;
  final String userIdB;

  const CreateChatRoomParams({required this.userIdA, required this.userIdB});

  @override
  List<Object> get props => [userIdA, userIdB];
}