import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dadadu_app/core/errors/exceptions.dart';
import 'package:dadadu_app/features/auth/data/models/user_model.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailPassword(String email, String password);
  Future<UserModel> signUpWithEmailPassword(
      String email, String password, String firstName, String lastName, String username);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);
  // Add this new method:
  Stream<firebase_auth.User?> authStateChanges(); // This exposes the FirebaseAuth stream
}

class FirebaseAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRemoteDataSourceImpl(this._firebaseAuth, this._firestore);

  @override
  Stream<firebase_auth.User?> authStateChanges() {
    return _firebaseAuth.authStateChanges(); // Directly return the stream from FirebaseAuth
  }

  @override
  Future<UserModel> signInWithEmailPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw ServerException(message: 'Sign-in failed: User is null.');
      }
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        final UserModel newUser = UserModel.fromFirebaseUser(userCredential.user!);
        await _firestore.collection('users').doc(newUser.uid).set(
          newUser.toMap()..addAll({
            'firstName': newUser.firstName ?? '',
            'lastName': newUser.lastName ?? '',
            'username': newUser.username ?? newUser.email?.split('@').first ?? 'unknown_user',
            'profilePhotoUrl': '',
            'userModeEmoji': '😊', // Default emoji
            'followersCount': 0,
            'followingCount': 0,
            'rank': 'Newbie',
            'uploadedVideoUrls': [],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }),
          SetOptions(merge: true),
        );
        return newUser;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? 'An unknown authentication error occurred.');
    } catch (e) {
      throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword(
      String email, String password, String firstName, String lastName, String username) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final firebase_auth.User firebaseUser = userCredential.user!;

        final UserModel newUserModel = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          displayName: '$firstName $lastName',
          firstName: firstName,
          lastName: lastName,
          username: username,
          profilePhotoUrl: '',
          userModeEmoji: '😊',
          followersCount: 0,
          followingCount: 0,
          rank: 'Newbie',
          uploadedVideoUrls: const [],
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set(
          newUserModel.toMap()..addAll({
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }),
        );

        return newUserModel;
      } else {
        throw ServerException(message: 'Sign-up failed: User creation returned null.');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? 'An unknown authentication error occurred during sign-up.');
    } catch (e) {
      throw ServerException(message: 'An unexpected error occurred during sign-up: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ServerException(message: 'Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebase_auth.User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return null;
      }
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        final UserModel newUser = UserModel.fromFirebaseUser(firebaseUser);
        await _firestore.collection('users').doc(newUser.uid).set(
          newUser.toMap()..addAll({
            'firstName': newUser.firstName ?? '',
            'lastName': newUser.lastName ?? '',
            'username': newUser.username ?? newUser.email?.split('@').first ?? 'unknown_user',
            'profilePhotoUrl': '',
            'userModeEmoji': '😊',
            'followersCount': 0,
            'followingCount': 0,
            'rank': 'Newbie',
            'uploadedVideoUrls': [],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }),
          SetOptions(merge: true),
        );
        return newUser;
      }
    } catch (e) {
      throw ServerException(message: 'Error getting current user: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to send password reset email.');
    } catch (e) {
      throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }
}