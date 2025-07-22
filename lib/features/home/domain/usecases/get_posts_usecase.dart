// lib/features/home/domain/usecases/get_posts_usecase.dart

// Removed: import 'package:cloud_firestore/cloud_firestore.dart'; // No longer needed for DocumentSnapshot

import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart'; // Assuming UseCase and NoParams or similar exist
import 'package:dadadu_app/features/home/domain/repositories/home_repository.dart'; // Import the repository and PostsPaginationResult
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetPostsUseCase implements UseCase<PostsPaginationResult, GetPostsParams> {
  final HomeRepository repository;

  GetPostsUseCase(this.repository);

  @override
  Future<Either<Failure, PostsPaginationResult>> call(GetPostsParams params) async {
    // Pass the new startAfterTimestamp parameter to the repository
    return await repository.getPosts(params.limit,
        startAfterTimestamp: params.startAfterTimestamp);
  }
}

class GetPostsParams extends Equatable {
  final int limit;

  // Changed from DocumentSnapshot? to String? for timestamp-based pagination
  final String? startAfterTimestamp;

  const GetPostsParams({required this.limit, this.startAfterTimestamp});

  @override
  List<Object?> get props => [limit, startAfterTimestamp];
}