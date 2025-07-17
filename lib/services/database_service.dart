import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _messaging = FirebaseMessaging.instance;

  // 👤 CRÉATION UTILISATEUR (Auth + Firestore + FCM)
  Future<void> createUser({
    required String email,
    required String username,
    required String language,
  }) async {
    final uid = _auth.currentUser!.uid;

    // Générer code de parrainage unique
    final referralCode = uid.substring(0, 8).toUpperCase();

    // Obtenir token FCM pour notifications
    String? fcmToken;
    try {
      fcmToken = await _messaging.getToken();
    } catch (e) {
      debugPrint('Erreur token FCM: $e');
    }

    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'username': username,
      'language': language,
      'bio': '',
      'profilePicture': '',
      'mood': 'Happy',
      'intent': 'love',
      'isOnline': true,
      'totalDiamonds': 0,
      'diamonds': 0, // Compatibilité
      'matchedUsers': [],
      'referralCode': referralCode,
      'referralCount': 0,
      'fcmToken': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
      'rank': 'Leaf',
      'pushToken': '', // Compatibilité
      'followersCount': 0,
      'followingCount': 0,
      // ✅ NOUVEAUX CHAMPS POUR MATCHING GÉOLOCALISÉ
      'latitude': 0.0,
      'longitude': 0.0,
      'isSearching': false,
      'lastActive': FieldValue.serverTimestamp(),
      'interestedBy': [],
    });
  }

  // 🎬 UPLOAD VIDÉO (Auth + Firestore)
  Future<void> uploadVideo({
    required String url,
    required String thumbnailUrl,
    required String caption,
    required String intent,
    required String language,
  }) async {
    final uid = _auth.currentUser!.uid;

    // Récupérer le username depuis Firestore
    final userDoc = await _db.collection('users').doc(uid).get();
    final username = userDoc.data()?['username'] ?? 'Utilisateur';

    await _db.collection('videos').add({
      'uid': uid,
      'username': username,
      'videoUrl': url,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'intent': intent,
      'language': language,
      'diamonds': 0,
      'status': 'pending', 
      'visibilityLevel': 0,
      'moderationStatus': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 💎 SYSTÈME DIAMANTS (Auth + Firestore avec transactions)
  Future<void> giveDiamond(String videoId, String authorId, String giverId) async {
    if (authorId == giverId) {
      throw Exception('Impossible de se donner des diamants');
    }

    final videoRef = _db.collection('videos').doc(videoId);
    final likeRef = videoRef.collection('likes').doc(giverId);
    final authorRef = _db.collection('users').doc(authorId);

    await _db.runTransaction((transaction) async {
      final likeDoc = await transaction.get(likeRef);
      final videoDoc = await transaction.get(videoRef);
      final authorDoc = await transaction.get(authorRef);

      if (likeDoc.exists) {
        throw Exception('Diamant déjà donné');
      }

      final currentVideoDiamonds = videoDoc.data()?['diamonds'] ?? 0;
      final authorTotalDiamonds = authorDoc.data()?['totalDiamonds'] ?? 0;

      // Ajouter le like
      transaction.set(likeRef, {
        'timestamp': FieldValue.serverTimestamp(),
        'userId': giverId,
      });

      // Mettre à jour compteurs
      transaction.update(videoRef, {'diamonds': currentVideoDiamonds + 1});
      transaction.update(authorRef, {'totalDiamonds': authorTotalDiamonds + 1});
    });
  }

  Future<void> removeDiamond(String videoId, String authorId, String giverId) async {
    final videoRef = _db.collection('videos').doc(videoId);
    final likeRef = videoRef.collection('likes').doc(giverId);
    final authorRef = _db.collection('users').doc(authorId);

    await _db.runTransaction((transaction) async {
      final likeDoc = await transaction.get(likeRef);
      final videoDoc = await transaction.get(videoRef);
      final authorDoc = await transaction.get(authorRef);

      if (!likeDoc.exists) {
        throw Exception('Aucun diamant à retirer');
      }

      final currentVideoDiamonds = videoDoc.data()?['diamonds'] ?? 0;
      final authorTotalDiamonds = authorDoc.data()?['totalDiamonds'] ?? 0;

      // Retirer le like
      transaction.delete(likeRef);

      // Mettre à jour compteurs (éviter négatifs)
      final newVideoDiamonds = currentVideoDiamonds > 0 ? currentVideoDiamonds - 1 : 0;
      final newTotalDiamonds = authorTotalDiamonds > 0 ? authorTotalDiamonds - 1 : 0;

      transaction.update(videoRef, {'diamonds': newVideoDiamonds});
      transaction.update(authorRef, {'totalDiamonds': newTotalDiamonds});
    });
  }

  Future<bool> hasUserLikedVideo(String userId, String videoId) async {
    try {
      final likeDoc = await _db
          .collection('videos')
          .doc(videoId)
          .collection('likes')
          .doc(userId)
          .get();
      return likeDoc.exists;
    } catch (e) {
      return false;
    }
  }

  // 👥 SYSTÈME FOLLOWERS (Auth + Firestore avec transactions)
  Future<void> followUser(String targetUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || targetUserId == currentUserId) return;

    final followRef = _db.collection('followers').doc('${currentUserId}_$targetUserId');
    final targetUserRef = _db.collection('users').doc(targetUserId);
    final currentUserRef = _db.collection('users').doc(currentUserId);

    await _db.runTransaction((transaction) async {
      final followDoc = await transaction.get(followRef);

      if (followDoc.exists) {
        throw Exception('Utilisateur déjà suivi');
      }

      // Créer la relation de follow
      transaction.set(followRef, {
        'followerId': currentUserId,
        'followedUserId': targetUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Incrémenter les compteurs
      transaction.update(targetUserRef, {'followersCount': FieldValue.increment(1)});
      transaction.update(currentUserRef, {'followingCount': FieldValue.increment(1)});
    });

    // Notification au suivi
    await _sendNotification(
      recipientId: targetUserId,
      title: '👥 Nouveau follower !',
      body: 'Quelqu\'un vous suit maintenant sur Dadadu !',
    );
  }

  Future<void> unfollowUser(String targetUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || targetUserId == currentUserId) return;

    final followRef = _db.collection('followers').doc('${currentUserId}_$targetUserId');
    final targetUserRef = _db.collection('users').doc(targetUserId);
    final currentUserRef = _db.collection('users').doc(currentUserId);

    await _db.runTransaction((transaction) async {
      final followDoc = await transaction.get(followRef);

      if (!followDoc.exists) {
        throw Exception('Utilisateur non suivi');
      }

      // Supprimer la relation de follow
      transaction.delete(followRef);

      // Décrémenter les compteurs (éviter négatifs)
      transaction.update(targetUserRef, {'followersCount': FieldValue.increment(-1)});
      transaction.update(currentUserRef, {'followingCount': FieldValue.increment(-1)});
    });
  }

  Future<bool> isFollowing(String targetUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || targetUserId == currentUserId) return false;

    try {
      final followDoc = await _db
          .collection('followers')
          .doc('${currentUserId}_$targetUserId')
          .get();
      return followDoc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<int> getFollowersCount(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      return userDoc.data()?['followersCount'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getFollowersList(String userId) async {
    try {
      final followersSnapshot = await _db
          .collection('followers')
          .where('followedUserId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      final followers = <Map<String, dynamic>>[];
      for (var doc in followersSnapshot.docs) {
        final followerId = doc.data()['followerId'];
        final userDoc = await _db.collection('users').doc(followerId).get();
        if (userDoc.exists) {
          followers.add({
            ...userDoc.data()!,
            'followTimestamp': doc.data()['timestamp'],
          });
        }
      }
      return followers;
    } catch (e) {
      debugPrint('Erreur récupération followers: $e');
      return [];
    }
  }

  // 🏪 MARKETPLACE BADGES (Auth + Firestore avec transactions)
  Future<void> createBadgeListing({
    required String badgeType,
    required double price,
    String? description,
  }) async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) return;

    await _db.collection('marketplace_badges').add({
      'sellerId': sellerId,
      'badgeType': badgeType,
      'price': price,
      'description': description ?? '',
      'status': 'available',
      'createdAt': FieldValue.serverTimestamp(),
      'buyerId': null,
      'soldAt': null,
    });
  }

  Future<void> purchaseBadge(String badgeId) async {
    final buyerId = _auth.currentUser?.uid;
    if (buyerId == null) return;

    final badgeRef = _db.collection('marketplace_badges').doc(badgeId);
    final buyerRef = _db.collection('users').doc(buyerId);

    await _db.runTransaction((transaction) async {
      final badgeDoc = await transaction.get(badgeRef);
      final buyerDoc = await transaction.get(buyerRef);

      if (!badgeDoc.exists) {
        throw Exception('Badge non trouvé');
      }

      final badgeData = badgeDoc.data()!;
      if (badgeData['status'] != 'available') {
        throw Exception('Badge non disponible');
      }

      final sellerId = badgeData['sellerId'];
      if (sellerId == buyerId) {
        throw Exception('Impossible d\'acheter son propre badge');
      }

      final price = badgeData['price'];
      final buyerDiamonds = buyerDoc.data()?['totalDiamonds'] ?? 0;

      if (buyerDiamonds < price) {
        throw Exception('Pas assez de diamants');
      }

      // Effectuer la transaction
      transaction.update(badgeRef, {
        'status': 'sold',
        'buyerId': buyerId,
        'soldAt': FieldValue.serverTimestamp(),
      });

      // Transférer les diamants
      transaction.update(buyerRef, {'totalDiamonds': FieldValue.increment(-price.toInt())});

      final sellerRef = _db.collection('users').doc(sellerId);
      transaction.update(sellerRef, {'totalDiamonds': FieldValue.increment(price.toInt())});
    });

    // Notifications
    final badgeDoc = await _db.collection('marketplace_badges').doc(badgeId).get();
    final sellerId = badgeDoc.data()?['sellerId'];

    if (sellerId != null) {
      await _sendNotification(
        recipientId: sellerId,
        title: '🎉 Badge vendu !',
        body: 'Votre badge a été acheté !',
      );
    }
  }

  Future<void> removeBadgeListing(String badgeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final badgeDoc = await _db.collection('marketplace_badges').doc(badgeId).get();
    if (badgeDoc.exists && badgeDoc.data()?['sellerId'] == userId) {
      await _db.collection('marketplace_badges').doc(badgeId).delete();
    }
  }

  Future<List<Map<String, dynamic>>> getMarketplaceBadges({String? sellerId}) async {
    try {
      Query query = _db.collection('marketplace_badges')
          .where('status', isEqualTo: 'available')
          .orderBy('createdAt', descending: true);

      if (sellerId != null) {
        query = query.where('sellerId', isEqualTo: sellerId);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      debugPrint('Erreur récupération marketplace: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserBadgeHistory(String userId) async {
    try {
      final purchasedSnapshot = await _db
          .collection('marketplace_badges')
          .where('buyerId', isEqualTo: userId)
          .orderBy('soldAt', descending: true)
          .get();

      final soldSnapshot = await _db
          .collection('marketplace_badges')
          .where('sellerId', isEqualTo: userId)
          .where('status', isEqualTo: 'sold')
          .orderBy('soldAt', descending: true)
          .get();

      final history = <Map<String, dynamic>>[];

      for (var doc in purchasedSnapshot.docs) {
        history.add({
          'id': doc.id,
          'type': 'purchased',
          ...doc.data(),
        });
      }

      for (var doc in soldSnapshot.docs) {
        history.add({
          'id': doc.id,
          'type': 'sold',
          ...doc.data(),
        });
      }

      // Trier par date
      history.sort((a, b) {
        final aTime = (a['soldAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        final bTime = (b['soldAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });

      return history;
    } catch (e) {
      debugPrint('Erreur récupération historique badges: $e');
      return [];
    }
  }

  // 🔗 PARRAINAGE (Auth + Firestore + FCM pour notification)
  Future<void> processReferral(String referralCode, String newUserId) async {
    try {
      // Trouver utilisateur avec ce code
      final referrerQuery = await _db
          .collection('users')
          .where('referralCode', isEqualTo: referralCode)
          .limit(1)
          .get();

      if (referrerQuery.docs.isEmpty) return;

      final referrerId = referrerQuery.docs.first.id;
      if (referrerId == newUserId) return; // Éviter auto-parrainage

      await _db.runTransaction((transaction) async {
        final referrerRef = _db.collection('users').doc(referrerId);
        final newUserRef = _db.collection('users').doc(newUserId);

        // +100 diamants pour chacun
        transaction.update(referrerRef, {
          'totalDiamonds': FieldValue.increment(100),
          'referralCount': FieldValue.increment(1),
        });

        transaction.update(newUserRef, {
          'totalDiamonds': FieldValue.increment(100),
          'referredBy': referrerId,
        });
      });

      // Notification parrain
      await _sendNotification(
        recipientId: referrerId,
        title: '🎉 Parrainage réussi !',
        body: 'Vous avez gagné 100 💎 !',
      );

    } catch (e) {
      debugPrint('Erreur parrainage: $e');
    }
  }

  // 🌍 FONCTIONS MATCHING GÉOLOCALISÉ
  Future<void> updateUserLocation(double latitude, double longitude) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).update({
      'latitude': latitude,
      'longitude': longitude,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setSearchingStatus(bool isSearching, {String? intent}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final updates = <String, dynamic>{
      'isSearching': isSearching,
      'lastActive': FieldValue.serverTimestamp(),
    };

    if (intent != null) {
      updates['intent'] = intent;
    }

    await _db.collection('users').doc(uid).update(updates);
  }

  Future<void> expressInterest(String targetUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || targetUserId == currentUserId) return;

    final targetUserRef = _db.collection('users').doc(targetUserId);

    await _db.runTransaction((transaction) async {
      final targetDoc = await transaction.get(targetUserRef);

      if (!targetDoc.exists) return;

      final targetData = targetDoc.data()!;
      final interestedBy = List<String>.from(targetData['interestedBy'] ?? []);

      if (!interestedBy.contains(currentUserId)) {
        interestedBy.add(currentUserId);
        transaction.update(targetUserRef, {'interestedBy': interestedBy});

        // Notification d'intérêt
        await _sendNotification(
          recipientId: targetUserId,
          title: '💖 Quelqu\'un s\'intéresse à vous !',
          body: 'Une nouvelle connexion vous attend sur Dadadu !',
        );
      }
    });
  }

  Future<void> createMutualMatch(String user1Id, String user2Id, String intent) async {
    final timestamp = FieldValue.serverTimestamp();

    await _db.runTransaction((transaction) async {
      // Historique pour user1
      transaction.set(
        _db.collection('users').doc(user1Id).collection('matchHistory').doc(),
        {
          'matchedWith': user2Id,
          'intent': intent,
          'mutual': true,
          'timestamp': timestamp,
        },
      );

      // Historique pour user2
      transaction.set(
        _db.collection('users').doc(user2Id).collection('matchHistory').doc(),
        {
          'matchedWith': user1Id,
          'intent': intent,
          'mutual': true,
          'timestamp': timestamp,
        },
      );
    });

    // Notifications mutuelles
    await _sendNotification(
      recipientId: user1Id,
      title: '🎉 Match mutuel !',
      body: 'Vous avez un nouveau match sur Dadadu !',
    );

    await _sendNotification(
      recipientId: user2Id,
      title: '🎉 Match mutuel !',
      body: 'Vous avez un nouveau match sur Dadadu !',
    );
  }

  // 🔔 NOTIFICATIONS (Firestore + FCM)
  Future<void> _sendNotification({
    required String recipientId,
    required String title,
    required String body,
  }) async {
    try {
      // Sauvegarder en base
      await _db.collection('notifications').add({
        'recipientId': recipientId,
        'senderId': _auth.currentUser?.uid,
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      debugPrint('Erreur notification: $e');
    }
  }

  // 👥 PROFIL (Auth + Firestore)
  Future<void> updateUserProfile({
    String? username,
    String? mood,
    String? profilePicture,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (mood != null) updates['mood'] = mood;
    if (profilePicture != null) updates['profilePicture'] = profilePicture;

    if (updates.isNotEmpty) {
      await _db.collection('users').doc(uid).update(updates);
    }
  }

  // 🔧 FCM TOKEN (Auth + Firestore + FCM)
  Future<void> updateFCMToken() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final token = await _messaging.getToken();
      if (token != null) {
        await _db.collection('users').doc(uid).update({'fcmToken': token});
      }
    } catch (e) {
      debugPrint('Erreur FCM: $e');
    }
  }
}