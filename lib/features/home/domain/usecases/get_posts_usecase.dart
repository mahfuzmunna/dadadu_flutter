// lib/features/home/domain/usecases/get_posts_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for DocumentSnapshot
import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart'; // Assuming UseCase and NoParams or similar exist
import 'package:dadadu_app/features/home/domain/repositories/home_repository.dart'; // Import the repository and PostsPaginationResult

class GetPostsUseCase implements UseCase<PostsPaginationResult, GetPostsParams> {
  final HomeRepository repository;

  GetPostsUseCase(this.repository);

  @override
  Future<Either<Failure, PostsPaginationResult>> call(GetPostsParams params) async {
    return await repository.getPosts(params.limit, startAfterDocument: params.startAfterDocument);
  }
}

class GetPostsParams extends Equatable {
  final int limit;
  final DocumentSnapshot? startAfterDocument;

  const GetPostsParams({required this.limit, this.startAfterDocument});

  @override
  List<Object?> get props => [limit, startAfterDocument];
}