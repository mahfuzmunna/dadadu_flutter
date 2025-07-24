import 'dart:io';

import 'package:dadadu_app/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:minio/minio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class PostRemoteDataSource {
  Future<void> uploadPost({
    required File videoFile,
    required File thumbnailFile,
    required String caption,
    required String intent,
    required String userId,
    Function(double progress)? onUploadProgress,
  });
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
}
