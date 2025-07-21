import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dadadu_app/core/errors/exceptions.dart'; // Make sure you have AuthException defined here
import 'package:dadadu_app/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
// import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart'; // UserEntity is typically used in the domain layer, not directly here, but it's harmless.

/// Abstract class defining the contract for authentication-related remote data operations.
abstract class AuthRemoteDataSource {
  /// Signs in a user with email and password.
  /// Throws [AuthException] for authentication-specific errors.
  /// Throws [ServerException] for other server-related issues.
  Future<UserModel> signInWithEmailPassword(String email, String password);

  /// Registers a new user with email, password, and basic profile info.
  /// Throws [AuthException] for authentication-specific errors.
  /// Throws [ServerException] for other server-related issues.
  Future<UserModel> signUpWithEmailPassword(
      String email, String password, String firstName, String lastName, String username);

  /// Signs out the current user.
  /// Throws [ServerException] if sign out fails.
  Future<void> signOut();

  /// Retrieves the current authenticated user's profile data.
  /// Returns null if no user is authenticated or profile not found in Firestore.
  /// Throws [ServerException] for any errors during retrieval.
  Future<UserModel?> getCurrentUser();

  /// Sends a password reset email to the given email address.
  /// Throws [AuthException] for authentication-specific errors.
  /// Throws [ServerException] for other server-related issues.
  Future<void> sendPasswordResetEmail(String email);

  /// Provides a stream of authentication state changes from Firebase.
  Stream<firebase_auth.User?> authStateChanges();
}

/// Concrete implementation of [AuthRemoteDataSource] using Firebase Authentication and Firestore.
class FirebaseAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  /// Constructor for [FirebaseAuthRemoteDataSourceImpl].
  /// Requires instances of [firebase_auth.FirebaseAuth] and [FirebaseFirestore].
  FirebaseAuthRemoteDataSourceImpl(this._firebaseAuth, this._firestore);

  @override
  Stream<firebase_auth.User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
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
        throw AuthException(
            message: 'Sign-in failed: User credential is null.');
      }

      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        // If user authenticates but no Firestore profile exists (e.g., deleted or external auth)
        final UserModel newUser = UserModel.fromFirebaseUser(userCredential.user!);
        await _firestore.collection('users').doc(newUser.uid).set(
          newUser.toMap()..addAll({
            'firstName': newUser.firstName ?? '',
            'lastName': newUser.lastName ?? '',
            'username': newUser.username ?? newUser.email?.split('@').first ?? 'unknown_user',
                  'profilePhotoUrl': '',
                  // Default to empty
                  'userModeEmoji': '😊', // Default emoji
            'followersCount': 0,
            'followingCount': 0,
                  'postCount': 0,
                  'rank': 'Leaf',
                  'uploadedVideoUrls': const [],
                  'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }),
              SetOptions(
                  merge:
                      true), // Merge to avoid overwriting existing data if any
            );
        return newUser;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
          message: e.message ?? 'Authentication error during sign-in.');
    } on FirebaseException catch (e) {
      throw ServerException(
          message: 'Firestore error during sign-in: ${e.message}');
    } catch (e) {
      throw ServerException(
          message:
              'An unexpected error occurred during sign-in: ${e.toString()}');
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
          // Consider a more robust display name logic
          firstName: firstName,
          lastName: lastName,
          username: username,
          profilePhotoUrl: '',
          // Default empty
          userModeEmoji: '😊',
          followersCount: 0,
          followingCount: 0,
          postCount: 0,
          rank: 'Leaf',
          uploadedVideoUrls: const [], // Empty list for new user
        );

        // Save user profile to Firestore
        await _firestore.collection('users').doc(firebaseUser.uid).set(
          newUserModel.toMap()..addAll({
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }),
        );

        return newUserModel;
      } else {
        throw AuthException(
            message: 'Sign-up failed: User creation returned null.');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
          message: e.message ?? 'Authentication error during sign-up.');
    } on FirebaseException catch (e) {
      throw ServerException(
          message: 'Firestore error during sign-up: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'An unexpected error occurred during sign-up: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Even though signOut rarely throws FirebaseAuthException, handle it for consistency
      throw AuthException(
          message: e.message ?? 'Authentication error during sign out.');
    } catch (e) {
      throw ServerException(
          message:
              'An unexpected error occurred during sign out: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebase_auth.User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return null; // No user is currently authenticated
      }
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        // If Firebase Auth has a user, but no corresponding Firestore profile, create one.
        // This can happen if a user signs up via another method (e.g., Google)
        // or if profile creation failed during initial signup.
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
                  'postCount': 0,
                  'rank': 'Newbie',
                  'uploadedVideoUrls': const [],
                  'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }),
          SetOptions(merge: true),
        );
        return newUser;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Catch specific auth errors, though currentUser usually doesn't throw them.
      throw AuthException(
          message: e.message ?? 'Authentication error getting current user.');
    } on FirebaseException catch (e) {
      throw ServerException(
          message: 'Firestore error getting current user: ${e.message}');
    } catch (e) {
      throw ServerException(
          message:
              'An unexpected error occurred getting current user: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
          message: e.message ??
              'Authentication error sending password reset email.');
    } on FirebaseException catch (e) {
      // Catch Firestore errors, though unlikely for sendPasswordResetEmail
      throw ServerException(
          message: 'Server error sending password reset email: ${e.message}');
    } catch (e) {
      throw ServerException(
          message:
              'An unexpected error occurred sending password reset email: ${e.toString()}');
    }
  }
}