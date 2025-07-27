import 'dart:io';

import 'package:dadadu_app/core/errors/exceptions.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:minio/minio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../upload/data/models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<void> uploadPost({
    required File videoFile,
    required File thumbnailFile,
    required String caption,
    required String intent,
    required String userId,
    Function(double progress)? onUploadProgress,
  });

  Stream<List<PostModel>> streamAllPosts();

  Stream<Tuple2<List<PostModel>, Map<String, UserModel>>> streamFeed();

  Future<List<Map<String, dynamic>>> getPostComments(String postId);

  Future<Either<Failure, List<UserEntity>>> getUsersByIds(List<String> userIds);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final SupabaseClient supabaseClient;
  final Minio minioClient;
  final Uuid uuid;
  final String wasabiBucketName;
  final String cdnHostname;

  PostRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.minioClient,
    required this.uuid,
    required this.wasabiBucketName,
    required this.cdnHostname,
  });

  @override
  Future<void> uploadPost({
    required File videoFile,
    required File thumbnailFile,
    required String caption,
    required String intent,
    required String userId,
    Function(double progress)? onUploadProgress,
  }) async {
    try {
      final postId = uuid.v4();
      final videoExt = videoFile.path.split('.').last;
      final thumbExt = thumbnailFile.path.split('.').last;

      final videoObjectKey = 'videos/$userId/$postId.$videoExt';
      final thumbObjectKey = 'thumbnails/$userId/$postId.$thumbExt';

      // 1. Upload Video
      onUploadProgress?.call(0.1); // 10% progress
      final videoUrl =
          await _uploadFile(wasabiBucketName, videoObjectKey, videoFile);
      onUploadProgress?.call(0.5); // 50% progress

      // 2. Upload Thumbnail
      final thumbnailUrl =
          await _uploadFile(wasabiBucketName, thumbObjectKey, thumbnailFile);
      onUploadProgress?.call(0.8); // 80% progress

      // 3. Insert into Supabase 'posts' table
      await supabaseClient.from('posts').insert({
        'id': postId,
        'user_id': userId,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'caption': caption,
        'intent': intent,
        'created_at': DateTime.now().toIso8601String(),
      });
      onUploadProgress?.call(1.0); // 100% progress
    } catch (e) {
      throw ServerException('Upload failed: ${e.toString()}');
    }
  }

  Future<String> _uploadFile(String bucket, String key, File file) async {
    final mimeType = lookupMimeType(file.path);
    await minioClient.putObject(
      bucket,
      key,
      file.openRead().cast<Uint8List>(),
      size: file.lengthSync(),
      metadata: {if (mimeType != null) 'Content-Type': mimeType},
    );
    return 'https://$cdnHostname/$key';
  }

  @override
  Stream<List<PostModel>> streamAllPosts() {
    try {
      // Use .stream() to listen to the entire 'posts' table, ordered by creation time.
      final stream = supabaseClient
          .from('posts')
          .stream(primaryKey: ['id']).order('created_at', ascending: false);

      // Transform the raw data into a Stream of PostModels
      return stream.map((data) {
        return data.map((map) => PostModel.fromMap(map)).toList();
      });
    } catch (e) {
      throw ServerException('Failed to stream posts: ${e.toString()}');
    }
  }

  @override
  Stream<Tuple2<List<PostModel>, Map<String, UserModel>>> streamFeed() {
    try {
      final postStream = supabaseClient
          .from('posts')
          .stream(primaryKey: ['id']).order('created_at', ascending: false);

      // Use asyncMap to process the posts and fetch their authors
      return postStream.asyncMap((listOfPostMaps) async {
        if (listOfPostMaps.isEmpty) {
          return const Tuple2([], {});
        }

        final posts =
            listOfPostMaps.map((map) => PostModel.fromMap(map)).toList();

        // 1. Collect all unique user IDs from the posts
        final userIds = posts.map((post) => post.userId).toSet().toList();

        // 2. Fetch all required author profiles in a single query
        final authorMaps = await supabaseClient
            .from('profiles')
            .select()
            .filter('id', 'in', '(${userIds.join(',')})');
        // .in_('id', userIds);

        // 3. Create a map of authors for easy lookup
        final authors = {
          for (var map in authorMaps)
            map['id'] as String: UserModel.fromMap(map)
        };

        // 4. Return both the posts and the authors
        return Tuple2(posts, authors);
      });
    } catch (e) {
      throw ServerException('Failed to stream feed: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPostComments(String postId) async {
    try {
      final response = await supabaseClient
          .from('posts')
          .select('comments')
          .eq('id', postId)
          .single();

      // The comments are returned as a List<dynamic> which we cast
      return List<Map<String, dynamic>>.from(response['comments'] ?? []);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getUsersByIds(
      List<String> userIds) async {
    try {
      final authorMaps = await supabaseClient
          .from('profiles')
          .select()
          .filter('id', 'in', '(${userIds.join(',')})');

      return Right(authorMaps.map((map) => UserModel.fromMap(map)).toList());
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get user profile: ${e.message}',
          code: e.code ?? 'POSTGREST_ERROR');
    } catch (e) {
      throw ServerException('An unexpected error occurred: ${e.toString()}',
          code: 'UNKNOWN_ERROR');
    }
  }
}
