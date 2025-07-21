// lib/features/home/data/datasources/home_remote_data_source.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dadadu_app/core/errors/exceptions.dart';
import 'package:dadadu_app/features/upload/data/models/post_model.dart'; // Assuming PostModel exists
import 'package:dadadu_app/features/auth/data/models/user_model.dart'; // Assuming UserModel exists

abstract class HomeRemoteDataSource {
  /// Fetches a raw QuerySnapshot for posts, enabling robust pagination.
  Future<QuerySnapshot> fetchPostsSnapshot(int limit, {DocumentSnapshot? startAfterDocument});

  /// Fetches a UserModel by UID.
  Future<UserModel> fetchUserInfo(String uid);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore _firestore;

  HomeRemoteDataSourceImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  @override
  Future<QuerySnapshot> fetchPostsSnapshot(int limit, {DocumentSnapshot? startAfterDocument}) async {
    try {
      Query query = _firestore.collection('posts')
          .orderBy('timestamp', descending: true); // Order by timestamp for feed

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      return await query.limit(limit).get(); // Return the raw QuerySnapshot
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Firestore Error fetching posts: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error fetching posts: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> fetchUserInfo(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw ServerException(message: 'User not found for UID: $uid');
      }
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Firestore Error fetching user info for $uid: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error fetching user info for $uid: ${e.toString()}');
    }
  }
}