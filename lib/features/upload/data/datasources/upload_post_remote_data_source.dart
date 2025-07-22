// lib/features/upload/data/datasources/upload_post_remote_data_source.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dadadu_app/core/errors/exceptions.dart';
import 'package:dadadu_app/features/upload/data/models/post_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class UploadPostRemoteDataSource {
  Future<String> uploadVideoToStorage(File videoFile, String userId, String postId);
  Future<void> createPostInFirestore(PostModel post);
  Future<void> updateUserUploadedVideosList(String userId, String videoUrl);
}

class UploadPostRemoteDataSourceImpl implements UploadPostRemoteDataSource {
  final FirebaseStorage _firebaseStorage;
  final FirebaseFirestore _firestore;

  UploadPostRemoteDataSourceImpl(this._firebaseStorage, this._firestore);

  @override
  Future<String> uploadVideoToStorage(File videoFile, String userId, String postId) async {
    try {
      final String filePath = 'videos/$userId/$postId.mp4'; // Path in Firebase Storage
      final Reference ref = _firebaseStorage.ref().child(filePath);
      final UploadTask uploadTask = ref.putFile(videoFile);

      final TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        final String downloadUrl = await ref.getDownloadURL();
        return downloadUrl;
      } else {
        throw ServerException('Video upload failed: ${snapshot.state}',
            code: snapshot.state.toString());
      }
    } on FirebaseException catch (e) {
      throw ServerException('Firebase Storage Error: ${e.message}',
          code: e.code);
    } catch (e) {
      throw ServerException('Unexpected video upload error: ${e.toString()}',
          code: 'UNKNOWN_VIDEO_UPLOAD_ERROR');
    }
  }

  @override
  Future<void> createPostInFirestore(PostModel post) async {
    try {
      await _firestore.collection('posts').doc(post.id).set(post.toMap());
    } on FirebaseException catch (e) {
      throw ServerException('Firestore Error: ${e.message}', code: e.code);
    } catch (e) {
      throw ServerException('Unexpected post creation error: ${e.toString()}',
          code: 'UNKNOWN_POST_CREATION_ERROR');
    }
  }

  @override
  Future<void> updateUserUploadedVideosList(String userId, String videoUrl) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      await userRef.update({
        'uploadedVideoUrls': FieldValue.arrayUnion([videoUrl]), // Add video URL to user's list
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
          'Firestore Error updating user videos: ${e.message}',
          code: e.code);
    } catch (e) {
      throw ServerException(
          'Unexpected error updating user videos: ${e.toString()}',
          code: 'UNKNOWN_USER_VIDEO_UPDATE_ERROR');
    }
  }
}