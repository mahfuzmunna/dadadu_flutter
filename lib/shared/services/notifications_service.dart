import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🎯 MODÈLES SIMPLES (définis dans le même fichier pour éviter les erreurs)
enum NotificationType {
  match,
  diamond,
  comment,
  newVideo,
  referral,
  system,
  proximity,
}

class DadaduNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? senderId;
  final String? senderUsername;
  final String? senderAvatar;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final bool isRead;
  final String? actionUrl;

  DadaduNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.senderId,
    this.senderUsername,
    this.senderAvatar,
    this.data,
    required this.timestamp,
    this.isRead = false,
    this.actionUrl,
  });

  factory DadaduNotification.fromMap(Map<String, dynamic> map, String id) {
    return DadaduNotification(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: _getNotificationTypeFromString(map['type'] ?? 'system'),
      senderId: map['senderId'] as String?,
      senderUsername: map['senderUsername'] as String?,
      senderAvatar: map['senderAvatar'] as String?,
      data: map['data'] != null ? Map<String, dynamic>.from(map['data'] as Map) : null,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      actionUrl: map['actionUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'senderAvatar': senderAvatar,
      'data': data,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'actionUrl': actionUrl,
    };
  }

  static NotificationType _getNotificationTypeFromString(String typeString) {
    switch (typeString) {
      case 'match':
        return NotificationType.match;
      case 'diamond':
        return NotificationType.diamond;
      case 'comment':
        return NotificationType.comment;
      case 'newVideo':
        return NotificationType.newVideo;
      case 'referral':
        return NotificationType.referral;
      case 'proximity':
        return NotificationType.proximity;
      default:
        return NotificationType.system;
    }
  }
}

// 🌟 SERVICE DE NOTIFICATIONS PREMIUM
class NotificationsService {
  static final NotificationsService _instance = NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  // 🔧 SERVICES FIREBASE
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🎨 ÉTAT UI
  final ValueNotifier<List<DadaduNotification>> notificationsNotifier =
  ValueNotifier<List<DadaduNotification>>([]);
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  // 📱 SETTINGS BASIQUES
  final Map<String, bool> _settings = {
    'pushEnabled': true,
    'soundEnabled': true,
    'vibrationEnabled': true,
    'matchNotifications': true,
    'diamondNotifications': true,
    'commentNotifications': true,
    'proximityNotifications': true,
    'referralNotifications': true,
  };

  // 🚀 INITIALISATION SIMPLE - CORRIGÉE
  Future<void> initialize(BuildContext context) async {
    try {
      await _initializeFCM();
      _setupNotificationHandlers();
      await _loadNotifications();

      debugPrint('✅ NotificationsService initialized successfully!');
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  // 🔔 FCM SETUP BASIQUE - CORRIGÉ
  Future<void> _initializeFCM() async {
    try {
      // Token FCM
      final token = await _fcm.getToken();
      await _saveTokenToFirestore(token);

      // Refresh token listener
      _fcm.onTokenRefresh.listen(_saveTokenToFirestore);

      debugPrint('🔥 FCM Token: ${token?.substring(0, 20)}...');
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    }
  }

  // 💾 TOKEN FIRESTORE - CORRIGÉ
  Future<void> _saveTokenToFirestore(String? token) async {
    if (token == null) return;

    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ FCM Token saved');
      }
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  // 🎧 HANDLERS BASIQUES - CORRIGÉS
  void _setupNotificationHandlers() {
    try {
      // Foreground messages - STOCKAGE DU CONTEXTE ÉVITÉ
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundMessage(message);
      });

      // App opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationOpenedApp(message);
      });

      // App opened from terminated state
      _fcm.getInitialMessage().then((RemoteMessage? initialMessage) {
        if (initialMessage != null) {
          _handleNotificationOpenedApp(initialMessage);
        }
      });
    } catch (e) {
      debugPrint('Error setting up handlers: $e');
    }
  }

  // 🎨 FOREGROUND NOTIFICATION SIMPLE - CORRIGÉ
  void _handleForegroundMessage(RemoteMessage message) {
    try {
      final notification = _createNotificationFromMessage(message);

      // Sauvegarder en base
      _saveNotificationToFirestore(notification);

      // Sons/vibrations SANS CONTEXT
      if (_settings['soundEnabled'] == true) {
        SystemSound.play(SystemSoundType.click);
      }
      if (_settings['vibrationEnabled'] == true) {
        HapticFeedback.lightImpact();
      }

      debugPrint('📱 Notification reçue: ${notification.title}');
    } catch (e) {
      debugPrint('Error handling foreground message: $e');
    }
  }

  // 💾 SAUVEGARDER NOTIFICATION - CORRIGÉ
  Future<void> _saveNotificationToFirestore(DadaduNotification notification) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());

      // Mettre à jour compteur
      await _updateUnreadCount();
    } catch (e) {
      debugPrint('Error saving notification: $e');
    }
  }

  // 📊 CHARGER NOTIFICATIONS - CORRIGÉ
  Future<void> _loadNotifications() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      final notifications = snapshot.docs
          .map((doc) => DadaduNotification.fromMap(doc.data(), doc.id))
          .toList();

      notificationsNotifier.value = notifications;
      await _updateUnreadCount();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  // 📈 COMPTEUR NON-LUES - CORRIGÉ
  Future<void> _updateUnreadCount() async {
    try {
      final unreadCount = notificationsNotifier.value
          .where((n) => !n.isRead)
          .length;
      unreadCountNotifier.value = unreadCount;
    } catch (e) {
      debugPrint('Error updating count: $e');
    }
  }

  // ✅ MARQUER COMME LUE - CORRIGÉ
  Future<void> markAsRead(String notificationId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      // Mettre à jour localement
      final updatedNotifications = notificationsNotifier.value.map((n) {
        if (n.id == notificationId) {
          return DadaduNotification(
            id: n.id,
            title: n.title,
            body: n.body,
            type: n.type,
            senderId: n.senderId,
            senderUsername: n.senderUsername,
            senderAvatar: n.senderAvatar,
            data: n.data,
            timestamp: n.timestamp,
            isRead: true,
            actionUrl: n.actionUrl,
          );
        }
        return n;
      }).toList();

      notificationsNotifier.value = updatedNotifications;
      await _updateUnreadCount();
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  // 🧹 MARQUER TOUTES COMME LUES - CORRIGÉ
  Future<void> markAllAsRead() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final batch = _firestore.batch();

      for (final notification in notificationsNotifier.value) {
        if (!notification.isRead) {
          final docRef = _firestore
              .collection('users')
              .doc(uid)
              .collection('notifications')
              .doc(notification.id);
          batch.update(docRef, {'isRead': true});
        }
      }

      await batch.commit();

      // Mettre à jour localement
      final updatedNotifications = notificationsNotifier.value.map((n) {
        return DadaduNotification(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          senderId: n.senderId,
          senderUsername: n.senderUsername,
          senderAvatar: n.senderAvatar,
          data: n.data,
          timestamp: n.timestamp,
          isRead: true,
          actionUrl: n.actionUrl,
        );
      }).toList();

      notificationsNotifier.value = updatedNotifications;
      unreadCountNotifier.value = 0;
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  // 🎯 ENVOYER NOTIFICATION - CORRIGÉ
  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
    String? actionUrl,
  }) async {
    try {
      final senderId = _auth.currentUser?.uid;
      if (senderId == null) return;

      // Récupérer infos expéditeur
      final senderDoc = await _firestore.collection('users').doc(senderId).get();
      final senderData = senderDoc.data();

      // Créer notification
      final notification = DadaduNotification(
        id: _firestore.collection('temp').doc().id,
        title: title,
        body: body,
        type: type,
        senderId: senderId,
        senderUsername: senderData?['username'] as String?,
        senderAvatar: senderData?['profilePicture'] as String?,
        data: data,
        timestamp: DateTime.now(),
        actionUrl: actionUrl,
      );

      // Sauvegarder chez le destinataire
      await _firestore
          .collection('users')
          .doc(recipientId)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());

      debugPrint('✅ Notification sent to $recipientId');
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
    }
  }

  // ⚙️ PARAMÈTRES - CORRIGÉS
  bool getSetting(String key) => _settings[key] ?? true;

  Future<void> updateSetting(String key, bool value) async {
    try {
      _settings[key] = value;
      debugPrint('✅ Setting updated: $key = $value');
    } catch (e) {
      debugPrint('Error updating setting: $e');
    }
  }

  // 📱 HELPERS - CORRIGÉS
  void _handleNotificationOpenedApp(RemoteMessage message) {
    final notification = _createNotificationFromMessage(message);
    _handleNotificationAction(notification);
  }

  void _handleNotificationAction(DadaduNotification notification) {
    // Marquer comme lue
    markAsRead(notification.id);

    // Actions selon le type (basiques pour éviter erreurs)
    switch (notification.type) {
      case NotificationType.match:
        debugPrint('Navigate to matches');
        break;
      case NotificationType.diamond:
        debugPrint('Navigate to profile');
        break;
      case NotificationType.comment:
        debugPrint('Navigate to video');
        break;
      default:
        debugPrint('Default notification action');
    }
  }

  DadaduNotification _createNotificationFromMessage(RemoteMessage message) {
    final messageId = message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';

    return DadaduNotification(
      id: messageId,
      title: title,
      body: body,
      type: _getNotificationTypeFromData(message.data),
      senderId: message.data['senderId'] as String?,
      senderUsername: message.data['senderUsername'] as String?,
      senderAvatar: message.data['senderAvatar'] as String?,
      data: message.data.isNotEmpty ? Map<String, dynamic>.from(message.data) : null,
      timestamp: DateTime.now(),
      actionUrl: message.data['actionUrl'] as String?,
    );
  }

  NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    final typeString = data['type'] as String?;
    return DadaduNotification._getNotificationTypeFromString(typeString ?? 'system');
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.match:
        return Icons.favorite;
      case NotificationType.diamond:
        return Icons.diamond;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.proximity:
        return Icons.location_on;
      case NotificationType.referral:
        return Icons.card_giftcard;
      default:
        return Icons.notifications;
    }
  }

  // 🧹 CLEANUP - CORRIGÉ
  void dispose() {
    notificationsNotifier.dispose();
    unreadCountNotifier.dispose();
  }

  // ✅ MÉTHODE STATIQUE POUR COMPATIBILITÉ AVEC L'ANCIEN CODE - CORRIGÉE
  static Future<void> initFCM(BuildContext context) async {
    try {
      final instance = NotificationsService();
      await instance.initialize(context);
    } catch (e) {
      debugPrint('Error in initFCM: $e');
    }
  }

  // 🎨 MÉTHODE POUR AFFICHER NOTIFICATION AVEC CONTEXT SÛRE
  static void showNotificationInApp(BuildContext context, DadaduNotification notification) {
    if (!context.mounted) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                NotificationsService()._getTypeIcon(notification.type),
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'Voir',
            textColor: Colors.tealAccent,
            onPressed: () {
              NotificationsService()._handleNotificationAction(notification);
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }
}