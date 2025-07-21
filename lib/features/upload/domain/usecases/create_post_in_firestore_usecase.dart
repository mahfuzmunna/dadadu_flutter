// lib/features/upload/domain/usecases/create_post_in_firestore_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:dadadu_app/features/upload/domain/repositories/upload_post_repository.dart';

class CreatePostInFirestoreUseCase implements UseCase<void, CreatePostParams> {
  final UploadPostRepository repository;

  CreatePostInFirestoreUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreatePostParams params) async {
    return await repository.createPost(params.post);
  }
}

class CreatePostParams extends Equatable {
  final PostEntity post;

  const CreatePostParams({required this.post});

  @override
  List<Object> get props => [post];
}