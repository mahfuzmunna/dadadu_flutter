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
      userId: params.userId,
      postId: params.postId,
      authorId: params.authorId,
    );
  }
}

class UnsendDiamondUseCase implements UseCase<void, SendDiamondParams> {
  final PostRepository repository;

  UnsendDiamondUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SendDiamondParams params) async {
    // You'll need to add unsendDiamond to your repository
    return await repository.unsendDiamond(
      userId: params.userId,
      postId: params.postId,
      authorId: params.authorId,
    );
  }
}

class SendDiamondParams extends Equatable {
  final String userId; // The user sending the diamond
  final String postId; // The post receiving the diamond
  final String authorId; // The author receiving the diamond

  const SendDiamondParams({
    required this.userId,
    required this.postId,
    required this.authorId,
  });

  @override
  List<Object> get props => [userId, postId, authorId];
}
