import 'package:dadadu_app/features/posts/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SendDiamondUseCase implements UseCase<void, SendDiamondParams> {
  final PostRepository repository;

  SendDiamondUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SendDiamondParams params) async {
    // You'll need to add sendDiamond to your repository
    return await repository.sendDiamond(
        senderId: params.senderId, receiverId: params.receiverId);
  }
}

class UnsendDiamondUseCase implements UseCase<void, SendDiamondParams> {
  final PostRepository repository;

  UnsendDiamondUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SendDiamondParams params) async {
    // You'll need to add unsendDiamond to your repository
    return await repository.unsendDiamond(
        senderId: params.senderId, receiverId: params.receiverId);
  }
}

class SendDiamondParams extends Equatable {
  final String senderId; // The user sending the diamond
  final String receiverId; // The user receiving the diamond

  const SendDiamondParams({required this.senderId, required this.receiverId});

  @override
  List<Object> get props => [senderId, receiverId];
}
