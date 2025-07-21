// lib/features/upload/domain/repositories/upload_post_repository.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';

abstract class UploadPostRepository {
  Future<Either<Failure, String>> uploadVideo(File videoFile, String userId, String postId);
  Future<Either<Failure, void>> createPost(PostEntity post);
  Future<Either<Failure, void>> updateUserUploadedVideos(String userId, String videoUrl);
}