import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video_model.dart';

class VideoService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _videoCollection = _firestore.collection('videos');

  // 🔄 Récupérer les vidéos (avec une limite)
  static Future<List<Video>> fetchVideos({int limit = 20}) async {
    final querySnapshot = await _videoCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Video.fromJson(data, doc.id);
    }).toList();
  }

  // 🔄 Récupérer les vidéos avec données utilisateur (pour le feed)
  static Future<List<Video>> fetchVideosWithUserData({int limit = 20}) async {
    final querySnapshot = await _videoCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    List<Video> videos = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Récupérer les données utilisateur
      final String userId = data['uid'] ?? '';
      if (userId.isNotEmpty) {
        final userDoc = await _firestore
            .collection('users')
            .doc(userId)
            .get();

        final userData = userDoc.data() ?? {};

        // Créer une map combinée avec les données utilisateur
        final combinedData = Map<String, dynamic>.from(data);
        combinedData['username'] = userData['username'] ?? 'Utilisateur';
        combinedData['profilePicture'] = userData['profilePicture'];

        videos.add(Video.fromJson(combinedData, doc.id));
      }
    }

    return videos;
  }

  // ➕ Ajouter une vidéo
  static Future<void> uploadVideo(Video video) async {
    await _videoCollection.doc(video.id).set(video.toJson());
  }

  // 🔍 Récupérer une vidéo par ID
  static Future<Video?> getVideoById(String id) async {
    final doc = await _videoCollection.doc(id).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return Video.fromJson(data, doc.id);
    }
    return null;
  }

  // 🔎 Récupérer les vidéos d'un utilisateur par username
  static Future<List<Video>> fetchVideosByUser(String username) async {
    final querySnapshot = await _videoCollection
        .where('username', isEqualTo: username)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Video.fromJson(data, doc.id);
    }).toList();
  }

  // 🆔 Récupérer les vidéos d'un utilisateur par UID
  static Future<List<Video>> fetchVideosByUserId(String userId) async {
    if (userId.isEmpty) return [];

    try {
      final querySnapshot = await _videoCollection
          .where('uid', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Video.fromJson(data, doc.id);
      }).toList();
    } catch (e) {
      // Si l'index n'existe pas, essayer sans orderBy
      try {
        final querySnapshot = await _videoCollection
            .where('uid', isEqualTo: userId)
            .get();

        final videos = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Video.fromJson(data, doc.id);
        }).toList();

        // Trier manuellement par date
        videos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return videos;
      } catch (e2) {
        return [];
      }
    }
  }

  // 💎 Mettre à jour les diamants d'une vidéo
  static Future<void> updateVideoDiamonds(String videoId, int newDiamondCount) async {
    await _videoCollection.doc(videoId).update({'diamonds': newDiamondCount});
  }

  // 📊 Calculer le total des diamants d'un utilisateur
  static Future<int> calculateUserTotalDiamonds(String userId) async {
    if (userId.isEmpty) return 0;

    try {
      final querySnapshot = await _videoCollection
          .where('uid', isEqualTo: userId)
          .get();

      int total = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final diamonds = data['diamonds'] ?? 0;
        total += (diamonds is num) ? diamonds.toInt() : 0;
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  // 🗑️ Supprimer une vidéo
  static Future<void> deleteVideo(String videoId) async {
    await _videoCollection.doc(videoId).delete();
  }

  // 🔍 Rechercher des vidéos par caption/description
  static Future<List<Video>> searchVideos(String query) async {
    if (query.isEmpty) return [];

    final querySnapshot = await _videoCollection
        .where('caption', isGreaterThanOrEqualTo: query)
        .where('caption', isLessThan: '${query}z')
        .orderBy('caption')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Video.fromJson(data, doc.id);
    }).toList();
  }

  // 🌍 Récupérer vidéos par géolocalisation et intent
  static Future<List<Video>> fetchVideosByLocationAndIntent({
    required String intent,
    String? location,
    int limit = 10,
  }) async {
    Query query = _videoCollection;

    if (intent.isNotEmpty) {
      query = query.where('intent', isEqualTo: intent);
    }

    if (location != null && location.isNotEmpty) {
      query = query.where('location', isEqualTo: location);
    }

    final querySnapshot = await query
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Video.fromJson(data, doc.id);
    }).toList();
  }
}