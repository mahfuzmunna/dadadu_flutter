import 'package:cloud_firestore/cloud_firestore.dart'; // For DocumentSnapshot
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.email,
    super.displayName,
    super.firstName,
    super.lastName,
    super.username,
    super.bio,
    super.profilePhotoUrl,
    super.userModeEmoji,
    super.followersCount,
    super.followingCount = 0,
    super.postCount,
    super.rank,
    super.uploadedVideoUrls,
    super.profilePhotoFile,
  });

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
      bio: null,
      profilePhotoUrl: null,
      userModeEmoji: null,
      followersCount: 0,
      followingCount: 0,
      postCount: null,
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
      bio: data['bio'] as String?,
      profilePhotoUrl: data['profilePhotoUrl'] as String?,
      userModeEmoji: data['userModeEmoji'] as String?,
      followersCount: data['followersCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      postCount: data['postCount'] as int?,
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
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'userModeEmoji': userModeEmoji,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postCount': postCount,
      'rank': rank,
      'uploadedVideoUrls': uploadedVideoUrls,
    };
  }
}