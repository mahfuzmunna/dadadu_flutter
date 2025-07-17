import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:start/generated/l10n.dart';
import '../services/notifications_service.dart';
import 'dart:async';

// 🎯 MODÈLES RÉVOLUTIONNAIRES
enum ReactionType {
  love(emoji: '❤️', color: Colors.red),
  fire(emoji: '🔥', color: Colors.orange),
  diamond(emoji: '💎', color: Colors.blue),
  crown(emoji: '👑', color: Colors.amber),
  rocket(emoji: '🚀', color: Colors.purple),
  star(emoji: '⭐', color: Colors.yellow);

  const ReactionType({required this.emoji, required this.color});
  final String emoji;
  final Color color;
}

enum CommentSort { recent, popular, trending }

class DadaduComment {
  final String id;
  final String authorId;
  final String authorUsername;
  final String? authorAvatar;
  final String text;
  final String videoId;
  final DateTime timestamp;
  final Map<ReactionType, List<String>> reactions;
  final List<String> mentions;
  final List<String> hashtags;
  final String? parentId;
  final bool isAuthorVerified;
  final bool isAuthorCreator;
  final int totalReactions;
  final int repliesCount;

  const DadaduComment({
    required this.id,
    required this.authorId,
    required this.authorUsername,
    this.authorAvatar,
    required this.text,
    required this.videoId,
    required this.timestamp,
    this.reactions = const {},
    this.mentions = const [],
    this.hashtags = const [],
    this.parentId,
    this.isAuthorVerified = false,
    this.isAuthorCreator = false,
    this.totalReactions = 0,
    this.repliesCount = 0,
  });

  factory DadaduComment.fromMap(Map<String, dynamic> map, String id) {
    final reactionsMap = <ReactionType, List<String>>{};
    final reactionsData = map['reactions'] as Map<String, dynamic>? ?? {};

    for (final type in ReactionType.values) {
      final reactionList = reactionsData[type.name] as List<dynamic>? ?? [];
      reactionsMap[type] = reactionList.cast<String>();
    }

    return DadaduComment(
      id: id,
      authorId: map['authorId'] as String? ?? '',
      authorUsername: map['authorUsername'] as String? ?? '',
      authorAvatar: map['authorAvatar'] as String?,
      text: map['text'] as String? ?? '',
      videoId: map['videoId'] as String? ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reactions: reactionsMap,
      mentions: (map['mentions'] as List<dynamic>?)?.cast<String>() ?? [],
      hashtags: (map['hashtags'] as List<dynamic>?)?.cast<String>() ?? [],
      parentId: map['parentId'] as String?,
      isAuthorVerified: map['isAuthorVerified'] as bool? ?? false,
      isAuthorCreator: map['isAuthorCreator'] as bool? ?? false,
      totalReactions: map['totalReactions'] as int? ?? 0,
      repliesCount: map['repliesCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    final reactionsMap = <String, dynamic>{};
    for (final entry in reactions.entries) {
      reactionsMap[entry.key.name] = entry.value;
    }

    return {
      'authorId': authorId,
      'authorUsername': authorUsername,
      'authorAvatar': authorAvatar,
      'text': text,
      'videoId': videoId,
      'timestamp': Timestamp.fromDate(timestamp),
      'reactions': reactionsMap,
      'mentions': mentions,
      'hashtags': hashtags,
      'parentId': parentId,
      'isAuthorVerified': isAuthorVerified,
      'isAuthorCreator': isAuthorCreator,
      'totalReactions': totalReactions,
      'repliesCount': repliesCount,
    };
  }
}

// 🌟 SYSTÈME DE COMMENTAIRES ULTRA-MODERNE
class CommentSheet extends StatefulWidget {
  final String videoId;
  final String videoAuthorId;

  const CommentSheet({
    super.key,
    required this.videoId,
    required this.videoAuthorId,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet>
    with TickerProviderStateMixin {

  // 🔧 SERVICES
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationsService _notificationService = NotificationsService();

  // 📱 CONTROLLERS
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // 🎨 ANIMATIONS
  late AnimationController _reactionAnimationController;
  late AnimationController _sendAnimationController;
  late Animation<double> _reactionScaleAnimation;
  late Animation<double> _sendScaleAnimation;

  // 📊 STATE
  List<DadaduComment> _comments = [];
  final Map<String, List<DadaduComment>> _replies = {};
  CommentSort _currentSort = CommentSort.recent;
  String? _replyingTo;
  bool _isLoading = false;
  bool _isSending = false;
  final Set<String> _expandedComments = {};
  StreamSubscription<QuerySnapshot>? _commentsSubscription;

  // 🎯 PAGINATION
  DocumentSnapshot? _lastDocument;
  bool _hasMoreComments = true;
  static const int _commentsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadComments();
    _setupScrollListener();
    _setupTextListener();
  }

  void _initializeAnimations() {
    _reactionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sendAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _reactionScaleAnimation = Tween<double>(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(
      parent: _reactionAnimationController,
      curve: Curves.elasticOut,
    ));

    _sendScaleAnimation = Tween<double>(begin: 1.0, end: 0.9)
        .animate(CurvedAnimation(
      parent: _sendAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 500) {
        _loadMoreComments();
      }
    });
  }

  void _setupTextListener() {
    _commentController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // 📥 CHARGEMENT COMMENTS INTELLIGENT
  Future<void> _loadComments() async {
    if (_isLoading) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      Query query = _firestore
          .collection('comments')
          .where('videoId', isEqualTo: widget.videoId)
          .where('parentId', isNull: true);

      // Tri intelligent
      switch (_currentSort) {
        case CommentSort.recent:
          query = query.orderBy('timestamp', descending: true);
          break;
        case CommentSort.popular:
          query = query.orderBy('totalReactions', descending: true);
          break;
        case CommentSort.trending:
          query = query.orderBy('timestamp', descending: true);
          break;
      }

      query = query.limit(_commentsPerPage);

      final snapshot = await query.get();

      final comments = snapshot.docs
          .map((doc) => DadaduComment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      if (mounted) {
        setState(() {
          _comments = comments;
          _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
          _hasMoreComments = snapshot.docs.length == _commentsPerPage;
        });
      }

      // Charger les réponses pour chaque commentaire
      await _loadRepliesForComments(comments.map((c) => c.id).toList());

    } catch (e) {
      debugPrint('Erreur chargement commentaires: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreComments() async {
    if (_isLoading || !_hasMoreComments || _lastDocument == null) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      Query query = _firestore
          .collection('comments')
          .where('videoId', isEqualTo: widget.videoId)
          .where('parentId', isNull: true)
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_commentsPerPage);

      final snapshot = await query.get();

      final newComments = snapshot.docs
          .map((doc) => DadaduComment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      if (mounted) {
        setState(() {
          _comments.addAll(newComments);
          _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
          _hasMoreComments = snapshot.docs.length == _commentsPerPage;
        });
      }

      await _loadRepliesForComments(newComments.map((c) => c.id).toList());

    } catch (e) {
      debugPrint('Erreur chargement plus de commentaires: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadRepliesForComments(List<String> commentIds) async {
    for (final commentId in commentIds) {
      try {
        final repliesSnapshot = await _firestore
            .collection('comments')
            .where('videoId', isEqualTo: widget.videoId)
            .where('parentId', isEqualTo: commentId)
            .orderBy('timestamp', descending: false)
            .limit(5)
            .get();

        final replies = repliesSnapshot.docs
            .map((doc) => DadaduComment.fromMap(doc.data(), doc.id))
            .toList();

        if (mounted) {
          setState(() {
            _replies[commentId] = replies;
          });
        }
      } catch (e) {
        debugPrint('Erreur chargement réponses: $e');
      }
    }
  }

  // ✍️ ENVOI COMMENTAIRE RÉVOLUTIONNAIRE
  Future<void> _sendComment() async {
    final s = S.of(context);
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSending) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
     _showSnackBar(s.mustBeLoggedIn);
      return;
    }

    if (mounted) {
      setState(() => _isSending = true);
    }

    _sendAnimationController.forward().then((_) {
      _sendAnimationController.reverse();
    });

    try {
      // Récupérer infos utilisateur
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data() ?? <String, dynamic>{};

      // Analyser le texte pour mentions et hashtags
      final mentions = _extractMentions(text);
      final hashtags = _extractHashtags(text);

      // Créer commentaire
      final comment = DadaduComment(
        id: '',
        authorId: currentUser.uid,
        authorUsername: userData['username'] as String? ?? 'Utilisateur',
        authorAvatar: userData['profilePicture'] as String?,
        text: text,
        videoId: widget.videoId,
        timestamp: DateTime.now(),
        mentions: mentions,
        hashtags: hashtags,
        parentId: _replyingTo,
        isAuthorCreator: currentUser.uid == widget.videoAuthorId,
        isAuthorVerified: userData['isVerified'] as bool? ?? false,
      );

      // Sauvegarder en Firebase
      final docRef = await _firestore.collection('comments').add(comment.toMap());

      // Si c'est une réponse, mettre à jour le compteur
      if (_replyingTo != null) {
        await _firestore.collection('comments').doc(_replyingTo).update({
          'repliesCount': FieldValue.increment(1),
        });

        // Notifier l'auteur du commentaire parent
        await _notifyCommentAuthor(_replyingTo!, 'reply');
      } else {
        // Notifier l'auteur de la vidéo
        if (currentUser.uid != widget.videoAuthorId) {
     await _notificationService.sendNotification(
  recipientId: widget.videoAuthorId,
  title: s.newCommentNotification,
  body: s.userCommented(userData['username']),
  type: NotificationType.comment,
  data: {'videoId': widget.videoId, 'commentId': docRef.id},
);

        }
      }

      // Notifier les mentions
      for (final mention in mentions) {
        await _notifyMention(mention, text);
      }

      // Reset UI
      _commentController.clear();
      if (mounted) {
        setState(() {
          _replyingTo = null;
        });
      }
      _focusNode.unfocus();

      // Recharger les commentaires
      await _loadComments();

      HapticFeedback.lightImpact();
      _showSnackBar(s.commentPosted);

    } catch (e) {
      debugPrint('Erreur envoi commentaire: $e');
      _showSnackBar(s.commentError);

    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  // 🎯 SYSTÈME DE RÉACTIONS RÉVOLUTIONNAIRE
  Future<void> _toggleReaction(String commentId, ReactionType reactionType) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    _reactionAnimationController.forward().then((_) {
      _reactionAnimationController.reverse();
    });

    try {
      final commentRef = _firestore.collection('comments').doc(commentId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(commentRef);
        if (!doc.exists) return;

        final data = doc.data()!;
        final reactions = Map<String, dynamic>.from(data['reactions'] as Map<String, dynamic>? ?? {});
        final userReactions = List<String>.from(reactions[reactionType.name] as List<dynamic>? ?? []);

        if (userReactions.contains(currentUser.uid)) {
          // Retirer la réaction
          userReactions.remove(currentUser.uid);
          reactions[reactionType.name] = userReactions;

          transaction.update(commentRef, {
            'reactions': reactions,
            'totalReactions': FieldValue.increment(-1),
          });
        } else {
          // Retirer les autres réactions de l'utilisateur
          for (final type in ReactionType.values) {
            final typeReactions = List<String>.from(reactions[type.name] as List<dynamic>? ?? []);
            if (typeReactions.contains(currentUser.uid)) {
              typeReactions.remove(currentUser.uid);
              reactions[type.name] = typeReactions;
            }
          }

          // Ajouter la nouvelle réaction
          userReactions.add(currentUser.uid);
          reactions[reactionType.name] = userReactions;

          transaction.update(commentRef, {
            'reactions': reactions,
            'totalReactions': FieldValue.increment(1),
          });

          // Notifier l'auteur du commentaire
          await _notifyCommentAuthor(commentId, 'reaction');
        }
      });

      HapticFeedback.selectionClick();
      await _loadComments();

    } catch (e) {
      debugPrint('Erreur réaction: $e');
    }
  }

  // 📱 HELPERS
  List<String> _extractMentions(String text) {
    final regex = RegExp(r'@(\w+)');
    return regex.allMatches(text).map((match) => match.group(1)!).toList();
  }

  List<String> _extractHashtags(String text) {
    final regex = RegExp(r'#(\w+)');
    return regex.allMatches(text).map((match) => match.group(1)!).toList();
  }

  Future<void> _notifyCommentAuthor(String commentId, String type) async {
    try {
      final commentDoc = await _firestore.collection('comments').doc(commentId).get();
      if (!commentDoc.exists) return;

      final commentData = commentDoc.data()!;
      final authorId = commentData['authorId'] as String;
      final currentUser = _auth.currentUser;

      if (currentUser != null && authorId != currentUser.uid) {
        String title, body;
        if (type == 'reply') {
          title = '💬 Nouvelle réponse';
          body = 'Quelqu\'un a répondu à votre commentaire';
        } else {
          title = '❤️ Nouvelle réaction';
          body = 'Quelqu\'un a réagi à votre commentaire';
        }

        await _notificationService.sendNotification(
          recipientId: authorId,
          title: title,
          body: body,
          type: NotificationType.comment,
          data: {'videoId': widget.videoId, 'commentId': commentId},
        );
      }
    } catch (e) {
      debugPrint('Erreur notification: $e');
    }
  }

  Future<void> _notifyMention(String username, String text) async {
    try {
      final userQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userId = userQuery.docs.first.id;
        await _notificationService.sendNotification(
          recipientId: userId,
          title: '👤 Vous avez été mentionné',
          body: text.length > 50 ? '${text.substring(0, 50)}...' : text,
          type: NotificationType.comment,
          data: {'videoId': widget.videoId},
        );
      }
    } catch (e) {
      debugPrint('Erreur mention: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.tealAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
       final theme = Theme.of(context);
    final isDark = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:  isDark
      ? [
          Colors.black.withOpacity(0.95),
          Colors.grey.shade900.withOpacity(0.98),
        ]
      : [
          Colors.white.withOpacity(0.95),
          Colors.grey.shade100.withOpacity(0.98),
        ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.tealAccent.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(theme, isDark),
          _buildSortTabs(isDark),
          Expanded(child: _buildCommentsList(isDark,theme)),
          _buildCommentInput(isDark,theme),
        ],
      ),
    );
  }

  // 🎨 HEADER PREMIUM
  Widget _buildHeader(ThemeData theme, bool isDark) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Handle
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.tealAccent.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Titre avec stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    s.commentsTitle,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.commentsCount(_comments.length),
                    style: TextStyle(
                      color:isDark
    ? Colors.white.withValues(alpha:  0.7)
    : Colors.black.withValues(alpha:  0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              // Actions
              Row(
                children: [
                  IconButton(
                    onPressed: _loadComments,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:isDark? Colors.tealAccent.withValues(alpha: 0.2): Colors.tealAccent.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:  Icon(Icons.refresh, color: isDark? Colors.tealAccent:const Color.fromARGB(255, 87, 144, 131), size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🏷️ ONGLETS TRI
Widget _buildSortTabs(bool isDarkMode) {
final s = S.of(context);
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: isDarkMode
          ? Colors.grey.shade900.withOpacity(0.8)
          : Colors.grey.shade200.withOpacity(0.8),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(
        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
      ),
    ),
    child: Row(
      children: [
  
      Expanded(child: _buildSortTab(CommentSort.recent, s.sortRecent, isDarkMode)),
      Expanded(child: _buildSortTab(CommentSort.popular, s.sortPopular, isDarkMode)),
      Expanded(child: _buildSortTab(CommentSort.trending, s.sortTrending, isDarkMode)),
      ],
    ),
  );
}


  Widget _buildSortTab(CommentSort sort, String label, bool isDarkMode) {
  final isSelected = _currentSort == sort;

  return GestureDetector(
    onTap: () {
      if (mounted) {
        setState(() => _currentSort = sort);
      }
      _loadComments();
      HapticFeedback.selectionClick();
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.tealAccent
            : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected
              ? Colors.black
              : isDarkMode
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha:  0.7),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
        ),
      ),
    ),
  );
}

  // 📝 LISTE COMMENTAIRES
 Widget _buildCommentsList(bool isDarkMode, ThemeData theme) {

  if (_isLoading && _comments.isEmpty) {
    return const Center(
      child: CircularProgressIndicator(color: Colors.tealAccent),
    );
  }

  if (_comments.isEmpty) {
    return Center(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey.shade900.withValues(alpha:  0.5)
                    : Colors.grey.shade300.withValues(alpha:  0.5), 
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 50,
                color: Colors.tealAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).noCommentsTitle,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).noCommentsSubtitle,
              style: TextStyle(
                color: isDarkMode
                    ? Colors.white.withValues(alpha:  0.6)
                    : Colors.black.withValues(alpha:  0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  return ListView.builder(
    controller: _scrollController,
    padding: const EdgeInsets.all(20),
    itemCount: _comments.length + (_hasMoreComments ? 1 : 0),
    itemBuilder: (context, index) {
      if (index == _comments.length) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: Colors.tealAccent),
          ),
        );
      }

      final comment = _comments[index];
      final replies = _replies[comment.id] ?? [];

      return _buildCommentCard(comment, replies,isDarkMode,theme);
    },
  );
}

  // 💎 CARTE COMMENTAIRE RÉVOLUTIONNAIRE
 Widget _buildCommentCard(DadaduComment comment, List<DadaduComment> replies, bool isDarkMode, ThemeData theme) {
  final isExpanded = _expandedComments.contains(comment.id);

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: Column(
      children: [
        // Main comment box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [
                      Colors.grey.shade900.withOpacity(0.8),
                      Colors.grey.shade800.withOpacity(0.8),
                    ]
                  : [
                      Colors.grey.shade200.withOpacity(0.8),
                      Colors.grey.shade100.withOpacity(0.8),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: comment.isAuthorCreator
                  ? Colors.amber.withOpacity(0.5)
                  : isDarkMode
                      ? Colors.grey.shade700.withValues(alpha:  0.3)
                      : Colors.grey.shade300.withValues(alpha:  1),
              width: comment.isAuthorCreator ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: comment.isAuthorCreator
                            ? Colors.amber
                            : Colors.tealAccent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (comment.isAuthorCreator
                                  ? Colors.amber
                                  : Colors.tealAccent)
                              .withValues(alpha:  0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: comment.authorAvatar?.isNotEmpty == true
                          ? Image.network(
                              comment.authorAvatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildDefaultAvatar(theme),
                            )
                          : _buildDefaultAvatar(theme),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Author info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment.authorUsername,
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (comment.isAuthorCreator) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                   S.of(context).creator,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            if (comment.isAuthorVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified,
                                  color: Colors.blue, size: 16),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTimestamp(comment.timestamp),
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.black.withValues(alpha:  0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              _buildFormattedText(
                  comment.text, comment.mentions, comment.hashtags,theme),
              const SizedBox(height: 12),

              // Actions
              Row(
                children: [
                  ..._buildReactionButtons(comment,isDarkMode),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (mounted) {
                        setState(() => _replyingTo = comment.id);
                      }
                      _focusNode.requestFocus();
                      HapticFeedback.selectionClick();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withValues(alpha:  0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: isDarkMode? Colors.tealAccent.withValues(alpha:  0.3):Colors.tealAccent.withValues(alpha:  0.9)),
                      ),
                      child:  Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.reply,
                              color: isDarkMode? Colors.tealAccent:const Color.fromARGB(255, 9, 173, 156), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            S.of(context).reply,
                            style: TextStyle(
                                color: isDarkMode? Colors.tealAccent:const Color.fromARGB(255, 9, 173, 156), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Replies
        if (replies.isNotEmpty || comment.repliesCount > 0) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              if (mounted) {
                setState(() {
                  if (isExpanded) {
                    _expandedComments.remove(comment.id);
                  } else {
                    _expandedComments.add(comment.id);
                  }
                });
              }
              HapticFeedback.selectionClick();
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey.shade800.withOpacity(0.5)
                    : Colors.grey.shade200.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.tealAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    S.of(context).repliesCount(comment.repliesCount),
                    style: const TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            ...replies.map((reply) => Container(
                  margin: const EdgeInsets.only(left: 40, bottom: 8),
                  child: _buildReplyCard(reply,isDarkMode,theme),
                )),
          ],
        ],
      ],
    ),
  );
}

Widget _buildReplyCard(DadaduComment reply, bool isDarkMode,ThemeData theme) {

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isDarkMode
          ? Colors.grey.shade800.withOpacity(0.6)
          : Colors.grey.shade100.withOpacity(0.6),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: isDarkMode
            ? Colors.grey.shade600.withOpacity(0.3)
            : Colors.grey.shade300.withOpacity(0.3),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.tealAccent, width: 1.5),
              ),
              child: ClipOval(
                child: reply.authorAvatar?.isNotEmpty == true
                    ? Image.network(
                        reply.authorAvatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildDefaultAvatar(theme),
                      )
                    : _buildDefaultAvatar(theme),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              reply.authorUsername,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (reply.isAuthorCreator) ...[
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Colors.amber, size: 14),
            ],
            const Spacer(),
            Text(
              _formatTimestamp(reply.timestamp),
              style: TextStyle(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildFormattedText(reply.text, reply.mentions, reply.hashtags,theme),
        const SizedBox(height: 8),
        Row(
          children: _buildReactionButtons(reply,isDarkMode),
        ),
      ],
    ),
  );
}

  Widget _buildDefaultAvatar(ThemeData theme) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.tealAccent, Colors.blue],
        ),
      ),
      child:  Icon(Icons.person, color: theme.primaryColor, size: 20),
    );
  }

  // 🎨 TEXTE FORMATÉ RÉVOLUTIONNAIRE
  Widget _buildFormattedText(String text, List<String> mentions, List<String> hashtags, ThemeData theme) {
    final spans = <TextSpan>[];
    final words = text.split(' ');

    for (int i = 0; i < words.length; i++) {
      final word = words[i];

      if (word.startsWith('@') && mentions.contains(word.substring(1))) {
        spans.add(TextSpan(
          text: word,
          style: const TextStyle(
            color: Colors.tealAccent,
            fontWeight: FontWeight.bold,
          ),
        ));
      } else if (word.startsWith('#') && hashtags.contains(word.substring(1))) {
        spans.add(TextSpan(
          text: word,
          style: const TextStyle(
            color: Colors.amberAccent,
            fontWeight: FontWeight.bold,
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: word,
          style:  TextStyle(color: theme.primaryColor),
        ));
      }

      if (i < words.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  // 🎭 BOUTONS RÉACTIONS RÉVOLUTIONNAIRES
  List<Widget> _buildReactionButtons(DadaduComment comment, bool isDarkMode) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return <Widget>[];

    final widgets = <Widget>[];

    for (final reactionType in ReactionType.values.take(3)) {
      final userReactedList = comment.reactions[reactionType] ?? <String>[];
      final hasReacted = userReactedList.contains(currentUser.uid);
      final count = userReactedList.length;

     widgets.add(
  GestureDetector(
    onTap: () => _toggleReaction(comment.id, reactionType),
    child: AnimatedBuilder(
      animation: _reactionScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: hasReacted ? _reactionScaleAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: hasReacted
                  ? reactionType.color.withValues(alpha:  0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasReacted
                    ? reactionType.color.withValues(alpha:  0.5)
                    : isDarkMode
                        ? Colors.grey.shade600.withValues(alpha:  0.3)
                        : Colors.grey.shade300.withValues(alpha:  0.9),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reactionType.emoji,
                  style: TextStyle(
                    fontSize: hasReacted ? 16 : 14,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      color: hasReacted
                          ? reactionType.color
                          : isDarkMode
                              ? Colors.white.withValues(alpha:  0.6)
                              : Colors.black.withValues(alpha:  0.5),
                      fontSize: 12,
                      fontWeight:
                          hasReacted ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  ),
);
 }

    return widgets;
  }

  // ✍️ ZONE SAISIE RÉVOLUTIONNAIRE
  Widget _buildCommentInput(bool isDarkMode, ThemeData theme) {

  return Container(
    padding: EdgeInsets.only(
      left: 20,
      right: 20,
      top: 16,
      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
    ),
    decoration: BoxDecoration(
      color: isDarkMode
          ? Colors.black.withOpacity(0.9)
          : Colors.white.withOpacity(0.9),
      border: Border(
        top: BorderSide(
          color: isDarkMode
              ? Colors.grey.shade700.withOpacity(0.5)
              : Colors.grey.shade300.withOpacity(0.5),
        ),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_replyingTo != null) _buildReplyingToIndicator(theme,isDarkMode),
        Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.tealAccent, width: 2),
              ),
              child: _buildDefaultAvatar(theme),
            ),
            const SizedBox(width: 12),

            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.shade900.withOpacity(0.8)
                      : Colors.grey.shade200.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.grey.shade700.withOpacity(0.5)
                        : Colors.grey.shade300.withOpacity(0.5),
                  ),
                ),
                child: TextField(
                  controller: _commentController,
                  focusNode: _focusNode,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: _replyingTo != null
                        ? S.of(context).replyToComment
    : S.of(context).addComment,
                    hintStyle: TextStyle(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.5)
                          : Colors.black.withOpacity(0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Send button
            AnimatedBuilder(
              animation: _sendScaleAnimation,
              builder: (context, child) {
                final hasText =
                    _commentController.text.trim().isNotEmpty;

                return Transform.scale(
                  scale: _sendScaleAnimation.value,
                  child: GestureDetector(
                    onTap:
                        hasText && !_isSending ? _sendComment : null,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: hasText
                            ? const LinearGradient(
                                colors: [Colors.tealAccent, Colors.cyan],
                              )
                            : LinearGradient(
                                colors: isDarkMode
                                    ? [
                                        Colors.grey.shade700,
                                        Colors.grey.shade600,
                                      ]
                                    : [
                                        Colors.grey.shade300,
                                        Colors.grey.shade200,
                                      ],
                              ),
                        shape: BoxShape.circle,
                        boxShadow: hasText
                            ? [
                                BoxShadow(
                                  color:
                                      Colors.tealAccent.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              color: hasText
                                  ? theme.primaryColor
                                  : isDarkMode
                                      ? Colors.white60
                                      : Colors.black54,
                              size: 20,
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildReplyingToIndicator(ThemeData theme, bool isDarkMode) {
  final replyComment = _comments.firstWhere((c) => c.id == _replyingTo);

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.tealAccent.withOpacity(0.1),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: Colors.tealAccent.withOpacity(0.3),
      ),
    ),
    child: Row(
      children: [
        const Icon(Icons.reply, color: Colors.tealAccent, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            S.of(context).replyingTo(replyComment.authorUsername),
            style: const TextStyle(
              color: Colors.tealAccent,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (mounted) {
              setState(() => _replyingTo = null);
            }
          },
          child: const Icon(Icons.close, color: Colors.tealAccent, size: 18),
        ),
      ],
    ),
  );
}

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _reactionAnimationController.dispose();
    _sendAnimationController.dispose();
    _commentsSubscription?.cancel();
    super.dispose();
  }
}