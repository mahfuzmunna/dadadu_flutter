import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:start/generated/l10n.dart';
import 'package:start/screens/image_crop.dart';
import 'dart:io';
import '../models/video_model.dart';
import '../shared/services/video_service.dart';
import '../shared/services/database_service.dart';
import 'settings_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final picker = ImagePicker();
  String _selectedMood = "Happy";
  final List<String> _moods = ["Happy", "Sad", "Excited"];

  // ignore: non_constant_identifier_names
  final current_user_id = FirebaseAuth.instance.currentUser!.uid;
  int _totalDiamonds = 0;
  Map<String, dynamic> _badgeInfo = {};
  late Stream<Map<String, dynamic>> combinedStream;
  String _referralCode = '';
  bool _isOwnProfile = true;
  final DatabaseService _databaseService = DatabaseService();
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _checkIfOwnProfile();
    _calculateDiamonds();
    _generateReferralCode();
    combinedStreams();
    _getFollowers();
  }

  void _checkIfOwnProfile() {
    final currentUser = FirebaseAuth.instance.currentUser;
    _isOwnProfile = widget.userId == null || widget.userId == currentUser?.uid;
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final ref =
          FirebaseStorage.instance.ref().child('profile_pictures/$uid.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'photoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).profilePhotoUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).profilePhotoUpdateError)),
        );
      }
    }
  }

  Future<void> _removeProfilePicture() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Supprimer de Storage
      try {
        await FirebaseStorage.instance
            .ref()
            .child('profile_pictures/$uid.jpg')
            .delete();
      } catch (e) {
        // Ignore si le fichier n'existe pas
      }

      // Supprimer de Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'photoUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).profilePhotoRemoved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).profilePhotoRemoveError)),
        );
      }
    }
  }

  String get _targetUserId {
    return widget.userId ?? current_user_id;
  }

  combinedStreams() {
    final userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(_targetUserId)
        .snapshots();

    final followerStream = FirebaseFirestore.instance
        .collection('users')
        .doc(_targetUserId)
        .collection('followers')
        .snapshots();

    final followingStream = FirebaseFirestore.instance
        .collection('users')
        .doc(_targetUserId)
        .collection('following')
        .snapshots();

    final videoStream =
        VideoService.fetchVideosByUserId(_targetUserId).asStream();

    final matchStream = FirebaseFirestore.instance
        .collection('users')
        .doc(_targetUserId)
        .collection('matchHistory')
        .orderBy('timestamp', descending: true)
        .snapshots();
    combinedStream = Rx.combineLatest5<DocumentSnapshot, QuerySnapshot,
        List<Video>, QuerySnapshot, QuerySnapshot, Map<String, dynamic>>(
      userStream,
      matchStream,
      videoStream,
      followingStream,
      followerStream,
      (userSnap, matchSnap, videos, followingSnap, followersSnap) => {
        'user': userSnap.data(),
        'matches': matchSnap.docs.map((doc) => doc.data()).toList(),
        'videos': videos,
        'following': followingSnap.docs.length,
        'followers': followersSnap.docs.length,
      },
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _loadUserData() {
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(current_user_id)
        .snapshots();
    try {
      // if (doc.exists && mounted) {
      //   final data = doc.data()!;
      //   setState(() {
      //     _userData = data;
      //     _selectedMood = data['mood'] ?? 'Happy';
      //   });
      // }

      return doc;
    } catch (e) {
      debugPrint('Erreur chargement données utilisateur: $e');
    }
    return doc;
  }

  Future<void> _generateReferralCode() async {
    if (!_isOwnProfile) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final code = currentUser.uid.substring(0, 8).toUpperCase();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({'referralCode': code}, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _referralCode = code;
        });
      }
    } catch (e) {
      debugPrint('Erreur génération code parrainage: $e');
    }
  }

  Future<void> _saveMood(String mood) async {
    if (!_isOwnProfile) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'mood': mood}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Erreur sauvegarde mood: $e');
    }
  }

  Future<void> _calculateDiamonds() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_targetUserId)
          .get();

      if (userDoc.exists && userDoc.data()!.containsKey('totalDiamonds')) {
        final totalFromProfile = userDoc.data()!['totalDiamonds'] ?? 0;
        if (mounted) {
          setState(() {
            _totalDiamonds = totalFromProfile;
            _badgeInfo = getBadgeInfo(_totalDiamonds);
          });
        }
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('videos')
          .where('uid', isEqualTo: current_user_id)
          .get();

      int sum = 0;
      for (var doc in snapshot.docs) {
        final dynamic value = doc.data()['diamonds'] ?? 0;
        sum += (value is num) ? value.toInt() : 0;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_targetUserId)
          .set({'totalDiamonds': sum}, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _totalDiamonds = sum;
          _badgeInfo = getBadgeInfo(_totalDiamonds);
        });
      }
    } catch (e) {
      debugPrint('Erreur calcul diamants: $e');
    }
  }

  String formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else {
      return number.toString();
    }
  }

  String _calculateEvolutiveValue(int diamonds) {
    if (diamonds < 10000000) return '\$0';

    double baseValue = 10000.0;
    int millionsAbove10 = ((diamonds - 10000000) / 1000000).floor();

    for (int i = 0; i < millionsAbove10; i++) {
      baseValue *= 1.02;
    }

    return '\$${baseValue.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  Map<String, dynamic> getBadgeInfo(int diamonds) {
    if (diamonds >= 10000000) {
      return {
        'label': 'Dadalord 👑',
        'color': Colors.deepPurpleAccent,
        'value': _calculateEvolutiveValue(diamonds),
        'isEvolutive': true,
        'type': 'dadalord',
      };
    } else if (diamonds >= 1000000) {
      return {
        'label': 'FiveLeaf 🎀',
        'color': Colors.green[400] ?? Colors.green,
        'value': '\$0',
        'isEvolutive': false,
        'type': 'fiveleaf',
      };
    } else if (diamonds >= 10000) {
      return {
        'label': 'ThreeLeaf ☘️',
        'color': const Color.fromARGB(255, 67, 198, 200),
        'value': '\$0',
        'isEvolutive': false,
        'type': 'threeleaf',
      };
    } else {
      return {
        'label': 'Leaf 🍃',
        'color': const Color.fromARGB(255, 232, 90, 90),
        'value': '\$0',
        'isEvolutive': false,
        'type': 'leaf',
      };
    }
  }

  // 🏪 MARKETPLACE FUNCTIONS
  /* Future<void> _openMarketplace(ThemeData theme) async {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMarketplaceModal(theme: theme),
    );
  }*/

  Widget _badgeItem({
    required String emoji,
    required String title,
    required ThemeData theme,
    required bool isDark,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceModal({required ThemeData theme}) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.scaffoldBackgroundColor, theme.cardColor],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(Icons.store, color: theme.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      S.of(context).badgeMarketplace,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: theme.primaryColor),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                labelColor: theme.primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: S.of(context).buy),
                  Tab(text: S.of(context).sell),
                ],
              ),
            ),

            // Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildBuyTab(theme: theme),
                  _buildSellTab(theme: theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeGuideDialog(
      BuildContext context, bool isDark, ThemeData theme) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            S.of(context).badgeSystemTitle,
            style: TextStyle(
              color: isDark ? Colors.tealAccent : Colors.teal,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _badgeItem(
                  emoji: '🍃',
                  title: S.of(context).badgeLeafTitle,
                  description: S.of(context).badgeLeafDesc,
                  theme: theme,
                  isDark: isDark,
                ),
                _badgeItem(
                  emoji: '☘️',
                  title: S.of(context).badgeThreeleafTitle,
                  description: S.of(context).badgeThreeleafDesc,
                  theme: theme,
                  isDark: isDark,
                ),
                _badgeItem(
                  emoji: '🎀',
                  title: S.of(context).badgeFiveleafTitle,
                  description: S.of(context).badgeFiveleafDesc,
                  theme: theme,
                  isDark: isDark,
                ),
                _badgeItem(
                  emoji: '👑',
                  title: S.of(context).badgeDadalordTitle,
                  description: S.of(context).badgeDadalordDesc,
                  theme: theme,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context).badgeNote,
                  style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).gotIt),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBuyTab({required ThemeData theme}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('marketplace_badges')
          .where('status', isEqualTo: 'available')
          .where('sellerId', isNotEqualTo: current_user_id)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store_outlined, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  S.of(context).noBadgesForSale,
                  style: const TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildBadgeCard(doc.id, data, theme);
          },
        );
      },
    );
  }

  Widget _buildBadgeCard(
      String badgeId, Map<String, dynamic> data, ThemeData theme) {
    final badgeType = data['badgeType'] ?? '';
    final priceInDiamonds = (data['price'] ?? 0).toDouble();
    final sellerId = data['sellerId'] ?? '';
    final description = data['description'] ?? '';

    final badgeInfo = _getBadgeInfoByType(badgeType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.cardColor,
            theme.highlightColor,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: badgeInfo['color'] != null
              ? (badgeInfo['color'] as Color).withAlpha((255 * 0.3).toInt())
              : Colors.grey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: badgeInfo['color'] != null
                      ? (badgeInfo['color'] as Color).withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: badgeInfo['color'] as Color? ?? Colors.grey),
                ),
                child: Text(
                  badgeInfo['label'] ?? badgeType,
                  style: TextStyle(
                    color: badgeInfo['color'] as Color? ?? Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${priceInDiamonds.toInt()} 💎',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: theme.shadowColor),
            ),
          ],
          const SizedBox(height: 12),
          if (sellerId != current_user_id) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _buyBadge(badgeId, priceInDiamonds.toInt()),
                icon: const Icon(Icons.diamond, size: 18),
                label: Text(
                  S
                      .of(context)
                      .buyForDiamonds(priceInDiamonds.toInt().toString()),
                  style: TextStyle(color: theme.primaryColor, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.highlightColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  S.of(context).yourBadge,
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSellTab({required ThemeData theme}) {
    if (!_isOwnProfile) {
      return Center(
        child: Text(
          S.of(context).ownBadgeSellError,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_badgeInfo.isNotEmpty && _badgeInfo['type'] != 'leaf')
            _buildSellCurrentBadge(theme: theme),
          const SizedBox(height: 24),
          Text(
            S.of(context).myBadgesForSale,
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('marketplace_badges')
                  .where('sellerId', isEqualTo: current_user_id)
                  .where('status', isEqualTo: 'available')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      S.of(context).noBadgesForSale,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return _buildMyListingCard(doc.id, data, theme);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellCurrentBadge({required ThemeData theme}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _badgeInfo['color'] != null
                ? (_badgeInfo['color'] as Color).withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _badgeInfo['color'] != null
              ? (_badgeInfo['color'] as Color).withOpacity(0.3)
              : Colors.grey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vendre mon badge actuel',
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _badgeInfo['color'] != null
                  ? (_badgeInfo['color'] as Color).withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _badgeInfo['color'] as Color? ?? Colors.grey),
            ),
            child: Text(
              _badgeInfo['label']?.toString() ?? '',
              style: TextStyle(
                color: _badgeInfo['color'] as Color? ?? Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _showSellDialog(theme),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Mettre en vente',
              style: TextStyle(
                color: theme.scaffoldBackgroundColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyListingCard(
      String badgeId, Map<String, dynamic> data, ThemeData theme) {
    final badgeType = data['badgeType'] ?? '';
    final price = (data['price'] ?? 0).toDouble();
    final badgeInfo = _getBadgeInfoByType(badgeType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeInfo['color'] != null
                  ? (badgeInfo['color'] as Color).withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeInfo['label']?.toString() ?? badgeType,
              style: TextStyle(
                color: badgeInfo['color'] as Color? ?? Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${price.toInt()} 💎',
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => _removeListing(badgeId),
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  Future<void> _showSellDialog(ThemeData theme) async {
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();

    int suggestedPrice = 0;
    switch (_badgeInfo['type']) {
      case 'threeleaf':
        suggestedPrice = 5000;
        break;
      case 'fiveleaf':
        suggestedPrice = 50000;
        break;
      case 'dadalord':
        suggestedPrice = 500000;
        break;
    }

    priceController.text = suggestedPrice.toString();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(
          S.of(context).sellBadgeTitle,
          style: TextStyle(color: theme.primaryColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: theme.primaryColor),
              decoration: InputDecoration(
                labelText: S.of(context).priceLabel,
                labelStyle: const TextStyle(color: Colors.amber),
                hintText: S.of(context).priceHint(suggestedPrice),
                hintStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.amber),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.amber),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: TextStyle(color: theme.primaryColor),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: S.of(context).descriptionLabel,
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.amber),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context).cancel,
                style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final price = int.tryParse(priceController.text) ?? 0;
              if (price > 0) {
                _sellBadge(price, descriptionController.text);
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text(
              S.of(context).sell,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sellBadge(int price, String description) async {
    try {
      await _databaseService.createBadgeListing(
        badgeType: _badgeInfo['type'],
        price: price.toDouble(),
        description: description,
      );

      if (mounted) {
        _showSnackBar(S.of(context).badgeListed);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(S.of(context).badgeListingError(e.toString()));
      }
    }
  }

  Future<void> _buyBadge(String badgeId, int price) async {
    if (_totalDiamonds < price) {
      _showSnackBar(S.of(context).notEnoughDiamonds);
      return;
    }

    try {
      await _databaseService.purchaseBadge(badgeId);
      if (mounted) {
        _showSnackBar(S.of(context).badgePurchased);
        Navigator.pop(context);
        await _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(S.of(context).badgePurchaseError(e.toString()));
      }
    }
  }

  Future<void> _removeListing(String badgeId) async {
    try {
      await _databaseService.removeBadgeListing(badgeId);
      if (mounted) {
        _showSnackBar(S.of(context).listingRemoved);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(S.of(context).errorRemovingListing(e.toString()));
      }
    }
  }

  Map<String, dynamic> _getBadgeInfoByType(String type) {
    switch (type) {
      case 'threeleaf':
        return {
          'label': 'ThreeLeaf ☘️',
          'color': const Color.fromARGB(255, 67, 198, 200),
        };
      case 'fiveleaf':
        return {
          'label': 'FiveLeaf 🎀',
          'color': Colors.green[400] ?? Colors.green,
        };
      case 'dadalord':
        return {
          'label': 'Dadalord 👑',
          'color': Colors.deepPurpleAccent,
        };
      default:
        return {
          'label': 'Leaf 🍃',
          'color': const Color.fromARGB(255, 232, 90, 90),
        };
    }
  }

  Future<void> _shareReferralLink() async {
    if (_referralCode.isEmpty) return;

    const baseUrl = 'https://dadadu.app/invite/';
    final referralLink = '$baseUrl$_referralCode';

    try {
      await Share.share(
        S.of(context).shareReferralText(referralLink),
        subject: S.of(context).shareReferralSubject,
      );
    } catch (e) {
      if (mounted) {
        _showSnackBar(S
            .of(context)
            .shareProfileError(e.toString())); // optional: use localized error
      }
    }
  }

  Future<void> _shareProfile(String username) async {
    final profileUrl = 'https://dadadu.app/user/$current_user_id';

    try {
      await Share.share(
        S.of(context).shareProfileText(username, profileUrl),
        subject: S.of(context).shareProfileSubject(username),
      );
    } catch (e) {
      if (mounted) {
        _showSnackBar(S.of(context).shareProfileError(e.toString()));
      }
    }
  }

  Future<void> _getFollowers() async {
    final firestore = FirebaseFirestore.instance;
    final targetFollowersRef = firestore
        .collection('users')
        .doc(_targetUserId)
        .collection('followers')
        .doc(current_user_id);
    await targetFollowersRef.get().then((value) {
      final isFollowingRef = value.exists;
      if (isFollowingRef) {
        if (mounted) {
          setState(() {
            isFollowing = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isFollowing = false;
          });
        }
      }
    });
  }

  void _copyReferralLink() {
    if (_referralCode.isEmpty) return;

    const baseUrl = 'https://dadadu.app/invite/';
    final referralLink = '$baseUrl$_referralCode';

    Clipboard.setData(ClipboardData(text: referralLink));
    _showSnackBar('${S.of(context).cancel} ! 📋');
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.tealAccent.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (!_isOwnProfile) return;

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      final cropped = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CropSample(imageFile: pickedFile),
        ),
      );

      if (cropped != null && cropped is Uint8List) {
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/cropped_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final croppedFile = await File(filePath).writeAsBytes(cropped);
        await _uploadProfilePicture(croppedFile);
      }
    }
  }

  Future<void> _removeImage() async {
    if (!_isOwnProfile) return;
    if (mounted) {
      await _removeProfilePicture();
    }
  }

  Future<void> _editUsernameDialog(dynamic username, User? user) async {
    if (!_isOwnProfile) return;

    final currentName = username;
    final controller = TextEditingController(text: currentName);

    if (!mounted) return;
    final newName = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          S.of(context).changeUsername,
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: S.of(context).newUsernameHint,
            hintStyle: const TextStyle(color: Colors.white54),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.tealAccent),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.tealAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              S.of(context).cancel,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              Navigator.pop(dialogContext, name.isNotEmpty ? name : null);
            },
            child: Text(
              S.of(context).save,
              style: const TextStyle(color: Colors.tealAccent),
            ),
          ),
        ],
      ),
    );

    if (newName != null) {
      if (user != null) {
        try {
          await user.updateDisplayName(newName);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'username': newName});
        } catch (e) {
          debugPrint('Error updating username: $e');
        }
      }
    }
  }

  Widget _buildReferralSection({required ThemeData theme}) {
    if (!_isOwnProfile || _referralCode.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.tealAccent.withOpacity(0.1),
            Colors.purpleAccent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.share, color: Colors.tealAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                S.of(context).referFriends,
                style: const TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '+100 💎',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).referralDescription,
            style: TextStyle(color: theme.shadowColor, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    'dadadu.app/invite/$_referralCode',
                    style: TextStyle(color: theme.primaryColor, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _copyReferralLink,
                icon:
                    const Icon(Icons.copy, color: Colors.tealAccent, size: 20),
                tooltip: S.of(context).copyLink,
              ),
              IconButton(
                onPressed: _shareReferralLink,
                icon:
                    const Icon(Icons.share, color: Colors.tealAccent, size: 20),
                tooltip: S.of(context).share,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final badge = _badgeInfo;
    final theme = Theme.of(context);
    final s = S.of(context);
    final isDark = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    return StreamBuilder(
        stream: combinedStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amberAccent),
            );
          }
          if (snapshot.hasData) {
            final userData = snapshot.data!['user'];
            final matches = snapshot.data!['matches'] as List;
            final userVideos = snapshot.data!['videos'];
            final username = userData['username'] ?? s.user;
            final photoURL = userData['photoUrl'];
            final following = snapshot.data!['following'];
            final followers = snapshot.data!['followers'];
            final currentUser = FirebaseAuth.instance.currentUser;
            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: AppBar(
                title: Text(_isOwnProfile ? s.profile : "@$username"),
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: _isOwnProfile
                    ? IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.highlightColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.settings,
                              color: theme.primaryColor, size: 20),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SettingsScreen()),
                          );
                        },
                      )
                    : null,
                actions: [
                  if (!_isOwnProfile)
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => _shareProfile(username),
                    ),
                ],
              ),
              body: Stack(
                children: [
                  // ✅ BOUTON MARKETPLACE - Positionné entre settings et notifications

                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              GestureDetector(
                                onTap: _isOwnProfile ? _pickImage : null,
                                child: photoURL == null
                                    ? const CircleAvatar(
                                        radius: 45,
                                        backgroundColor: Colors.grey,
                                        backgroundImage: null,
                                        child: Icon(Icons.person,
                                            color: Colors.white, size: 40))
                                    : ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: photoURL,
                                          fit: BoxFit.cover,
                                          width: 90,
                                          height: 90,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(
                                                  strokeWidth: 2),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error, size: 40),
                                        ),
                                      ),
                              ),
                              if (photoURL != null && _isOwnProfile)
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.redAccent),
                                  onPressed: _removeImage,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: GestureDetector(
                            onTap: () => _isOwnProfile
                                ? _editUsernameDialog(username, currentUser)
                                : null,
                            child: Text(
                              "@$username",
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // USER'S LOCATION INFO PLACEHOLDER
                        Text('California, CA'),
                        const SizedBox(height: 8),
                        if (badge.isNotEmpty)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: badge['color'] != null
                                    ? (badge['color'] as Color)
                                        .withValues(alpha: 0.2)
                                    : theme.primaryColorLight,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: badge['color'] as Color? ??
                                        Colors.grey),
                                boxShadow: badge['isEvolutive'] == true
                                    ? [
                                        BoxShadow(
                                          color: badge['color'] != null
                                              ? (badge['color'] as Color)
                                                  .withValues(alpha: 0.4)
                                              : Colors.transparent,
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    badge['label']?.toString() ?? '',
                                    style: TextStyle(
                                      color: badge['color'] as Color? ??
                                          Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (badge['isEvolutive'] == true &&
                                      badge['value'] != '\$0') ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        badge['value']?.toString() ?? '',
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],

                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (_isOwnProfile)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.mood,
                                  color: Colors.amberAccent, size: 18),
                              const SizedBox(width: 6),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  dropdownColor: theme.scaffoldBackgroundColor,
                                  value: _selectedMood,
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: Colors.amberAccent),
                                  style: TextStyle(color: theme.primaryColor),
                                  onChanged: (String? newValue) async {
                                    if (newValue != null && mounted) {
                                      setState(() => _selectedMood = newValue);
                                      await _saveMood(newValue);
                                    }
                                  },
                                  items: _moods.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        "${s.moodProfile}: $value",
                                        style: TextStyle(
                                            color: theme.primaryColor),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        const Color(0xFFFFB933)),
                                    foregroundColor:
                                        WidgetStateProperty.all(Colors.white),
                                  ),
                                  onPressed: () {
                                    _showBadgeGuideDialog(
                                        context, isDark, theme);
                                  },
                                  child: Text(
                                    s.howBadgesWork,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.mood,
                                    color: Colors.amberAccent, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  "${s.moodProfile}: $_selectedMood",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all(Colors.red),
                                    foregroundColor:
                                        WidgetStateProperty.all(Colors.white),
                                  ),
                                  onPressed: () {
                                    _showBadgeGuideDialog(
                                        context, isDark, theme);
                                  },
                                  child: Text(s.howBadgesWork),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(
                              title: s.followers,
                              value: formatNumber(followers ?? 0),
                              theme: theme,
                            ),
                            _StatItem(
                              title: s.following,
                              value: formatNumber(following ?? 0),
                              theme: theme,
                            ),
                            _StatItem(
                              title: s.rank,
                              value: badge['label'] ?? "-",
                              theme: theme,
                            ),
                          ],
                        ),
                        _buildReferralSection(theme: theme),
                        const SizedBox(height: 24),
                        if (_isOwnProfile) ...[
                          Text(s.matchHistory,
                              style: TextStyle(
                                  color: theme.shadowColor, fontSize: 16)),
                          const SizedBox(height: 8),
                          matches.isEmpty
                              ? Text(s.noMatchHistory,
                                  style: TextStyle(
                                      color: theme.inputDecorationTheme
                                          .hintStyle!.color))
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: matches.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(color: Colors.white10),
                                  itemBuilder: (context, index) {
                                    final match = matches[index].data()
                                        as Map<String, dynamic>;
                                    return ListTile(
                                      leading: const Icon(Icons.favorite,
                                          color: Colors.pinkAccent),
                                      title: Text(
                                          "${s.matchedWith} ${match['matchedWith'] ?? s.unknown}",
                                          style: TextStyle(
                                              color: theme.primaryColor)),
                                      subtitle: Text(
                                          "${s.intent} ${match['intent']}",
                                          style: TextStyle(
                                              color: theme.inputDecorationTheme
                                                  .hintStyle!.color)),
                                      trailing: Icon(Icons.arrow_forward_ios,
                                          size: 16,
                                          color: theme.inputDecorationTheme
                                              .enabledBorder!.borderSide.color),
                                    );
                                  },
                                ),
                          const SizedBox(height: 24),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(
                              title: s.videos,
                              value: formatNumber(userVideos.length),
                              theme: theme,
                            ),
                            _StatItem(
                              title: s.diamondsProfile,
                              value: formatNumber(_totalDiamonds),
                              theme: theme,
                            ),
                            _StatItem(
                              title: s.rank,
                              value: badge['label'] ?? "-",
                              theme: theme,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        Text(
                          _isOwnProfile
                              ? s.myVideos
                              : "${s.videosOf} @$username",
                          style:
                              TextStyle(color: theme.shadowColor, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: userVideos.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 9 / 16,
                          ),
                          itemBuilder: (context, index) {
                            final video = userVideos[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    video.thumbnailUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: theme.highlightColor,
                                        child: Icon(Icons.video_library,
                                            color: theme.inputDecorationTheme
                                                .hintStyle!.color),
                                      );
                                    },
                                  ),
                                  Container(color: Colors.black26),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Row(
                                      children: [
                                        Icon(Icons.diamond,
                                            size: 14,
                                            color: theme.primaryColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          formatNumber(video.diamonds),
                                          style: TextStyle(
                                              color: theme.shadowColor,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // MARKET PLACE TO BE IMPLEMENTED ON FUTURE UPDATES

                  /*Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    right:
                        70, // Position entre settings (gauche) et notifications (droite)
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.store,
                            color: Colors.white, size: 20),
                      ),
                      onPressed: () => _openMarketplace(theme),
                      tooltip: s.badgeMarketplace,
                    ),
                  ),*/
                ],
              ),
            );
          }

          return Container();
        });
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final ThemeData theme;

  const _StatItem(
      {required this.title, required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              color: theme.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(color: theme.primaryColor, fontSize: 13),
        ),
      ],
    );
  }
}
