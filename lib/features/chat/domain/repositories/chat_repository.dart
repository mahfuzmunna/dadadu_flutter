import 'package:dadadu_app/core/errors/exceptions.dart';
import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:dadadu_app/features/chat/domain/entities/chat_message_entity.dart';
import 'package:dartz/dartz.dart';

import '../entities/chat_room_entity.dart';

abstract class ChatRepository {
  Either<Failure, Stream<List<ChatMessageEntity>>> streamMessages(
      String roomId);

  Either<Failure, Stream<List<ChatRoomEntity>>> streamChatRooms();

  Future<Either<Failure, void>> sendMessage(
      {required String roomId,
      required String content,
      required String senderId});

  Future<Either<Failure, String>> createChatRoom({required String userIdA, required String userIdB});
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Either<Failure, Stream<List<ChatMessageEntity>>> streamMessages(
      String roomId) {
    try {
      // Call the data source to get the stream.
      // Since ChatMessageModel extends ChatMessageEntity, the stream is compatible.
      final messagesStream = remoteDataSource.streamMessages(roomId);

      // On success, return the stream wrapped in a Right.
      return Right(messagesStream);
    } on ServerException catch (e) {
      // If the data source throws a ServerException, convert it to a ServerFailure.
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required String roomId,
    required String content,
    required String senderId,
  }) async {
    try {
      // Call the data source to send the message.
      await remoteDataSource.sendMessage(
        roomId: roomId,
        content: content,
        senderId: senderId,
      );

      // On success, return Right(null).
      return const Right(null);
    } on ServerException catch (e) {
      // If the data source throws a ServerException, convert it to a ServerFailure.
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Either<Failure, Stream<List<ChatRoomEntity>>> streamChatRooms() {
    try {
      // The data source returns a stream of models, which are compatible with entities.
      final roomsStream = remoteDataSource.streamChatRooms();
      return Right(roomsStream);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, String>> createChatRoom({
    required String userIdA,
    required String userIdB,
  }) async {
    try {
      // Call the data source method.
      final roomId = await remoteDataSource.createChatRoom(
          userIdA: userIdA, userIdB: userIdB);

      // On success, return the room ID wrapped in a Right.
      return Right(roomId);
    } on ServerException catch (e) {
      // If the data source throws a ServerException, convert it to a ServerFailure.
      return Left(ServerFailure(e.message, code: e.code));
    }
  }
}
