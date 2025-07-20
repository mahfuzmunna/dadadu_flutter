import '../../domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart'; // For DocumentSnapshot

class UserModel extends UserEntity {
  const UserModel({
    required String uid,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? username,
    String? profilePhotoUrl,
    String? userModeEmoji,
    int followersCount = 0,
    int followingCount = 0,
    String? rank,
    List<String> uploadedVideoUrls = const [],
  }) : super(
    uid: uid,
    email: email,
    displayName: displayName,
    firstName: firstName,
    lastName: lastName,
    username: username,
    profilePhotoUrl: profilePhotoUrl,
    userModeEmoji: userModeEmoji,
    followersCount: followersCount,
    followingCount: followingCount,
    rank: rank,
    uploadedVideoUrls: uploadedVideoUrls,
  );

  factory UserModel.fromFirebaseUser(firebase_auth.User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      // Default placeholder values, these would be loaded from Firestore
      // or set during sign-up/profile creation
      firstName: null,
      lastName: null,
      username: null,
      profilePhotoUrl: null,
      userModeEmoji: null,
      followersCount: 0,
      followingCount: 0,
      rank: null,
      uploadedVideoUrls: const [],
    );
  }

  // Factory constructor to create UserModel from Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id, // UID is often the document ID
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      username: data['username'] as String?,
      profilePhotoUrl: data['profilePhotoUrl'] as String?,
      userModeEmoji: data['userModeEmoji'] as String?,
      followersCount: data['followersCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      rank: data['rank'] as String?,
      uploadedVideoUrls: (data['uploadedVideoUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          const [],
    );
  }

  // To Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'profilePhotoUrl': profilePhotoUrl,
      'userModeEmoji': userModeEmoji,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'rank': rank,
      'uploadedVideoUrls': uploadedVideoUrls,
    };
  }
}