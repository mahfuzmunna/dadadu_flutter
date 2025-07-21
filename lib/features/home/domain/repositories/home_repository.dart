// lib/features/home/domain/repositories/home_repository.dart

import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for DocumentSnapshot for pagination
import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';

// Helper class for pagination results (can be in a separate file like pagination_result.dart)
class PostsPaginationResult {
  final List<PostEntity> posts;
  final DocumentSnapshot? lastDocument; // The last document fetched for next query
  final bool hasMore; // Indicates if there are more posts to load

  PostsPaginationResult({required this.posts, this.lastDocument, required this.hasMore});
}

abstract class HomeRepository {
  /// Fetches a batch of posts, optionally starting after a given document.
  Future<Either<Failure, PostsPaginationResult>> getPosts(int limit, {DocumentSnapshot? startAfterDocument});

  /// Fetches a single user's information by their UID.
  Future<Either<Failure, UserEntity>> getUserInfo(String uid);
}