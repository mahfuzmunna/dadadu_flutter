import 'dart:io';

import 'package:dadadu_app/config/app_config.dart';
import 'package:dadadu_app/core/errors/exceptions.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:minio/minio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../upload/data/models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<void> uploadPost({
    required File videoFile,
    required Uint8List thumbnailBytes,
    required String caption,
    required String intent,
    required String userId,
    Function(double progress)? onUploadProgress,
  });

  Stream<List<PostModel>> streamAllPosts();

  Stream<Tuple2<List<PostModel>, Map<String, UserModel>>> streamFeed();

  Future<List<Map<String, dynamic>>> getPostComments(String postId);

  Future<Either<Failure, List<UserEntity>>> getUsersByIds(List<String> userIds);

  Future<PostModel> getPostById(String postId);

  Stream<PostModel> subscribeToPostChanges(String postId);

  Future<void> sendDiamond(
      {required String senderId, required String receiverId});

  Future<void> unsendDiamond(
      {required String senderId, required String receiverId});
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
    required Uint8List thumbnailBytes,
    required String caption,
    required String intent,
    required String userId,
    Function(double progress)? onUploadProgress,
  }) async {
    File? thumbnailFile;
    try {
      final postId = uuid.v4();
      final videoExt = videoFile.path.split('.').last;

      final tempDir = await getTemporaryDirectory();
      // We'll assume JPEG for the thumbnail.
      thumbnailFile = await File('${tempDir.path}/thumb_$postId.jpg')
          .writeAsBytes(thumbnailBytes);

      final videoObjectKey = 'videos/$userId/$postId.$videoExt';
      final thumbObjectKey = 'thumbnails/$userId/$postId.$thumbnailFile';

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
      await supabaseClient.from(AppConfig.supabasePostTable).insert({
        'id': postId,
        'user_id': userId,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'caption': caption,
        'intent': intent,
        'created_at': DateTime.now().toIso8601String(),
      });

      await supabaseClient.rpc(
        'append_post_to_user',
        params: {
          'target_user_id': userId,
          'new_post_id': postId,
        },
      );

      onUploadProgress?.call(1.0); // 100% progress

      await thumbnailFile.delete();
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
          .from(AppConfig.supabasePostTable)
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
          .from(AppConfig.supabasePostTable)
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
            .from(AppConfig.supabaseUserTable)
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
          .from(AppConfig.supabasePostTable)
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
          .from(AppConfig.supabaseUserTable)
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

  @override
  Future<PostModel> getPostById(String postId) async {
    try {
      final data = await supabaseClient
          .from(AppConfig.supabasePostTable)
          .select()
          .eq('id', postId)
          .single();
      return PostModel.fromMap(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<PostModel> subscribeToPostChanges(String postId) {
    try {
      final stream = supabaseClient
          .from(AppConfig.supabasePostTable)
          .stream(primaryKey: ['id']).eq('id', postId);

      return stream.map((data) {
        if (data.isEmpty) {
          throw ServerException('Post not found in stream.');
        }
        return PostModel.fromMap(data.first);
      });
    } catch (e) {
      throw ServerException('Failed to stream post: ${e.toString()}');
    }
  }

  @override
  Future<void> sendDiamond(
      {required String senderId, required String receiverId}) async {
    try {
      // Assumes you have a Supabase RPC function named 'send_diamond'
      await supabaseClient.rpc(
        'send_diamond',
        params: {
          'p_sender_id': senderId,
          'p_receiver_id': receiverId,
        },
      );
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> unsendDiamond(
      {required String senderId, required String receiverId}) async {
    try {
      // Assumes you have a Supabase RPC function named 'unsend_diamond'
      await supabaseClient.rpc(
        'unsend_diamond',
        params: {
          'p_sender_id': senderId,
          'p_receiver_id': receiverId,
        },
      );
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
