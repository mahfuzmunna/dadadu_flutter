// lib/features/profile/data/datasources/profile_remote_data_source.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

import '../../../../core/errors/exceptions.dart';
import '../../../auth/data/models/user_model.dart'; // Reusing UserModel
import '../../../upload/data/models/post_model.dart'; // Assuming PostModel is here, or create one in Profile feature

abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile(String userId);

  Future<void> updateUserProfile(UserModel user);

  Future<List<PostModel>> getUserPosts(String userId);

  Future<String> uploadProfileImage(
      String userId, String imagePath); // Returns URL
  Future<void> deleteProfileImage(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebaseStorage;
  final Uuid _uuid;

  ProfileRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage firebaseStorage,
    required Uuid uuid,
  })  : _firestore = firestore,
        _firebaseStorage = firebaseStorage,
        _uuid = uuid;

  @override
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists || doc.data() == null) {
        throw ServerException(message: 'User profile not found.');
      }
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(
          message: e.message ?? 'Firestore error fetching profile.');
    } catch (e) {
      throw ServerException(
          message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toMap()..['updatedAt'] = FieldValue.serverTimestamp());
    } on FirebaseException catch (e) {
      throw ServerException(
          message: e.message ?? 'Firestore error updating profile.');
    } catch (e) {
      throw ServerException(
          message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('creatorUid', isEqualTo: userId)
          .orderBy('createdAt',
              descending: true) // Assuming you have a createdAt field
          .get();

      return querySnapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
          message: e.message ?? 'Firestore error fetching user posts.');
    } catch (e) {
      throw ServerException(
          message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, String imagePath) async {
    try {
      final fileExtension = imagePath.split('.').last;
      final fileName =
          'profile_images/$userId/${_uuid.v4()}.$fileExtension'; // Unique filename
      final ref = _firebaseStorage.ref().child(fileName);

      // Upload the file
      final uploadTask =
          ref.putFile(File(imagePath)); // Ensure 'dart:io' is imported for File
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update the user's profile with the new image URL
      await _firestore.collection('users').doc(userId).update({
        'profilePhotoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw ServerException(
          message: e.message ?? 'Firebase Storage error uploading image.');
    } catch (e) {
      throw ServerException(
          message:
              'An unexpected error occurred during image upload: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProfileImage(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final currentImageUrl = UserModel.fromFirestore(userDoc).profilePhotoUrl;

      if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
        // Delete image from storage
        final ref = _firebaseStorage.refFromURL(currentImageUrl);
        await ref.delete();

        // Update user profile to remove image URL
        await _firestore.collection('users').doc(userId).update({
          'profilePhotoUrl': '', // Set to empty string
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseException catch (e) {
      throw ServerException(
          message: e.message ?? 'Firebase Storage error deleting image.');
    } catch (e) {
      throw ServerException(
          message:
              'An unexpected error occurred during image deletion: ${e.toString()}');
    }
  }
}