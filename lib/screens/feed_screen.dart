import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:start/generated/l10n.dart';
import 'package:video_player/video_player.dart';
import '../widgets/video_card.dart';
import '../dadadu/globe_button.dart';
import '../models/video_model.dart';
import '../screens/profile_screen.dart';
import '../services/database_service.dart';

class FeedScreen extends StatefulWidget {
  final ValueNotifier<bool> tabChanged;
  const FeedScreen({super.key, required this.tabChanged});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final DatabaseService _databaseService = DatabaseService();

  List<Video> _videos = [];
  List<Video> _personalizedVideos = [];
  int _currentVideoIndex = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _currentUserId;
  final Map<String, bool> _userLikes = {};
  final Map<String, int> _videoDiamonds = {};
  DocumentSnapshot? _lastDocument;
  final ValueNotifier<int> currentPageNotifier = ValueNotifier(0);
  String moderationStatus = '';
  String status = '';
  int visibilityLevel = 0;
  String target_id = '';
  late AnimationController _notificationController;
  late AnimationController _headerController;
  late AnimationController _refreshController;
  late Animation<Offset> _notificationSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _refreshRotationAnimation;

  String _notificationMessage = '';
  bool _notificationIsError = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _initAnimations();
    _loadInitialFeed();
  }

  void _initAnimations() {
    _notificationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _notificationSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _notificationController,
      curve: Curves.elasticOut,
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeInOut,
    ));

    _refreshRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshController,
      curve: Curves.linear,
    ));

    _headerController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notificationController.dispose();
    _headerController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  // 🚀 CHARGEMENT INITIAL OPTIMISÉ
  Future<void> _loadInitialFeed() async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);
    _refreshController.repeat();

    try {
      await Future.wait([
        _loadUserPersonalization(),
        _loadVideoFeed(isRefresh: true),
      ]);

      await _applyPersonalizationAlgorithm();
      await _preloadUserInteractions();

      if (mounted) {
        setState(() => _isLoading = false);
        _refreshController.stop();
        _refreshController.reset();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _refreshController.stop();
        _showCustomNotification('Erreur de chargement: $e', isError: true);
      }
    }
  }

  // 👤 CHARGEMENT PERSONNALISATION UTILISATEUR
  Future<Map<String, dynamic>> _loadUserPersonalization() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId!)
        .get();

    return userDoc.data() ?? {};
  }

  // 📹 CHARGEMENT FEED VIDÉO AVEC PAGINATION
  Future<void> _loadVideoFeed({bool isRefresh = false}) async {
    if (_isLoadingMore && !isRefresh) return;

    setState(() => _isLoadingMore = true);

    try {
      Query query = FirebaseFirestore.instance
          .collection('videos')
          .orderBy('createdAt', descending: true)
          .limit(20);

      if (!isRefresh && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() => _isLoadingMore = false);
        return;
      }

      final List<Video> newVideos = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final videoUserId = data['uid'] ?? '';
        setState(() {
          target_id = videoUserId;
        });
        // var _moderationStatus = data['moderationStatus'] ?? 'pending';
        // var _status = data['status'] ?? 'pending';
        // var _visibilityLevel = data['visibilityLevel'] ?? 0;
        // setState(() {
        //   moderationStatus = _moderationStatus;
        //   status = _status;
        //   visibilityLevel=_visibilityLevel;
        // });
        // Skip propres vidéos
        if (videoUserId == _currentUserId) continue;

        // Récupérer données auteur
        final authorDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(videoUserId)
            .get();

        if (authorDoc.exists) {
          final authorData = authorDoc.data();
          if (authorData != null) {
            // Enrichir données vidéo
            final enrichedData = Map<String, dynamic>.from(data);
            enrichedData['username'] = authorData['username'] ?? 'User';
            enrichedData['profilePicture'] = authorData['profilePicture'] ?? '';
            enrichedData['authorTotalDiamonds'] =
                authorData['totalDiamonds'] ?? 0;
            enrichedData['mood'] = authorData['mood'] ?? 'Happy';
            enrichedData['language'] = authorData['language'] ?? 'fr';

            final video = Video.fromJson(enrichedData, doc.id);
            newVideos.add(video);
          }
        }
      }

      if (mounted) {
        setState(() {
          if (isRefresh) {
            _videos = newVideos;
            _currentVideoIndex = 0;
          } else {
            _videos.addAll(newVideos);
          }
          _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);

        _showCustomNotification('Erreur chargement vidéos: $e', isError: true);
      }
    }
  }

  // 🧠 ALGORITHME DE PERSONNALISATION AVANCÉ
  Future<void> _applyPersonalizationAlgorithm() async {
    if (_videos.isEmpty || _currentUserId == null) return;

    try {
      // Récupérer données utilisateur
      final userData = await _loadUserPersonalization();
      final userLanguage = userData['language'] ?? 'fr';
      final userIntent = userData['intent'] ?? 'love';
      final followingList = List<String>.from(userData['following'] ?? []);

      // Récupérer historique interactions
      final userInteractions = await _getUserInteractionHistory();

      // Calculer scores pour chaque vidéo
      final List<VideoWithScore> videosWithScores = [];

      for (var video in _videos) {
        final score = _calculateAdvancedScore(
          video: video,
          userLanguage: userLanguage,
          userIntent: userIntent,
          followingList: followingList,
          interactions: userInteractions,
        );

        videosWithScores.add(VideoWithScore(video, score));
      }

      // Trier et diversifier
      videosWithScores.sort((a, b) => b.score.compareTo(a.score));
      final diversifiedVideos = _applyDiversificationRules(videosWithScores);

      if (mounted) {
        setState(() {
          _personalizedVideos = diversifiedVideos.map((v) => v.video).toList();
        });
      }
    } catch (e) {
      debugPrint('Erreur personnalisation: $e');
      // Fallback: utiliser ordre original
      setState(() => _personalizedVideos = _videos);
    }
  }

  // 📊 RÉCUPÉRATION HISTORIQUE INTERACTIONS
  Future<Map<String, dynamic>> _getUserInteractionHistory() async {
    try {
      final interactions = <String, dynamic>{};

      // Récupérer historique likes
      final likesQuery = await FirebaseFirestore.instance
          .collectionGroup('likes')
          .where('userId', isEqualTo: _currentUserId)
          .limit(100)
          .get();

      final likedAuthors = <String, int>{};
      final likedIntents = <String, int>{};

      for (var doc in likesQuery.docs) {
        final videoRef = doc.reference.parent.parent;
        if (videoRef != null) {
          final videoDoc = await videoRef.get();
          if (videoDoc.exists) {
            final videoData = videoDoc.data() as Map<String, dynamic>;
            final authorId = videoData['uid'] ?? '';
            final intent = videoData['intent'] ?? '';

            likedAuthors[authorId] = (likedAuthors[authorId] ?? 0) + 1;
            likedIntents[intent] = (likedIntents[intent] ?? 0) + 1;
          }
        }
      }

      interactions['likedAuthors'] = likedAuthors;
      interactions['likedIntents'] = likedIntents;

      return interactions;
    } catch (e) {
      debugPrint('Erreur historique interactions: $e');
      return {};
    }
  }

  // 🎯 CALCUL SCORE AVANCÉ
  double _calculateAdvancedScore({
    required Video video,
    required String userLanguage,
    required String userIntent,
    required List<String> followingList,
    required Map<String, dynamic> interactions,
  }) {
    double score = 50.0; // Score de base

    // 1. Following (40 points max)
    if (followingList.contains(video.userId)) {
      score += 40.0;
    }

    // 2. Intent matching (30 points max)
    if (video.intent == userIntent) {
      score += 30.0;
    } else if (video.intent == 'entertainment') {
      score += 20.0; // Entertainment universel
    }

    // 3. Langue (20 points max)
    final videoLanguage = video.language ?? 'fr';
    if (videoLanguage == userLanguage) {
      score += 20.0;
    }

    // 4. Popularité vidéo (25 points max)
    final diamonds = video.diamonds ?? 0;
    if (diamonds > 500) {
      score += 25.0;
    } else if (diamonds > 100) {
      score += 20.0;
    } else if (diamonds > 50) {
      score += 15.0;
    } else if (diamonds > 10) {
      score += 10.0;
    } else if (diamonds > 0) {
      score += 5.0;
    }

    // 5. Historique interactions (30 points max)
    final likedAuthors =
        interactions['likedAuthors'] as Map<String, int>? ?? {};
    final likedIntents =
        interactions['likedIntents'] as Map<String, int>? ?? {};

    final authorLikes = likedAuthors[video.userId] ?? 0;
    final intentLikes = likedIntents[video.intent] ?? 0;

    score += (authorLikes * 5.0).clamp(0.0, 20.0); // Max 20 points
    score += (intentLikes * 2.0).clamp(0.0, 10.0); // Max 10 points

    // 6. Fraîcheur (15 points max)
    final hoursSincePosted =
        DateTime.now().difference(video.createdAt).inHours;

    if (hoursSincePosted < 1)
      score += 15.0;
    else if (hoursSincePosted < 6)
      score += 12.0;
    else if (hoursSincePosted < 24)
      score += 8.0;
    else if (hoursSincePosted < 168) score += 4.0;
  
    // 7. Diversité (pénalité pour répétition)
    final authorVideoCount =
        _personalizedVideos.where((v) => v.userId == video.userId).length;
    if (authorVideoCount > 0) {
      score -= (authorVideoCount * 10.0);
    }

    return score.clamp(0.0, 200.0);
  }

  // 🔀 RÈGLES DE DIVERSIFICATION
  List<VideoWithScore> _applyDiversificationRules(List<VideoWithScore> videos) {
    final List<VideoWithScore> diversified = [];
    final Map<String, int> authorCounts = {};
    final Map<String, int> intentCounts = {};

    for (var videoWithScore in videos) {
      final video = videoWithScore.video;
      final authorId = video.userId;
      final intent = video.intent ?? 'love';

      final authorCount = authorCounts[authorId] ?? 0;
      final intentCount = intentCounts[intent] ?? 0;

      // Règles de diversification
      bool canInclude = true;

      // Max 2 vidéos par auteur dans les 15 premières
      if (diversified.length < 15 && authorCount >= 2) {
        canInclude = false;
      }

      // Max 3 vidéos par auteur au total
      if (authorCount >= 3) {
        canInclude = false;
      }

      // Équilibrer les intents
      if (diversified.length > 10) {
        final totalVideos = diversified.length;
        final intentRatio = intentCount / totalVideos;
        if (intentRatio > 0.6) {
          canInclude = false; // Max 60% d'un intent
        }
      }

      if (canInclude) {
        diversified.add(videoWithScore);
        authorCounts[authorId] = authorCount + 1;
        intentCounts[intent] = intentCount + 1;
      }

      if (diversified.length >= 50) {
        break;
      }
    }

    return diversified;
  }

  // 💾 PRÉCHARGEMENT INTERACTIONS UTILISATEUR
  Future<void> _preloadUserInteractions() async {
    if (_currentUserId == null || _personalizedVideos.isEmpty) return;

    try {
      final videoIds = _personalizedVideos.take(10).map((v) => v.id).toList();

      for (String videoId in videoIds) {
        // Précharger statut like
        final hasLiked = await _databaseService.hasUserLikedVideo(
          _currentUserId!,
          videoId,
        );
        _userLikes[videoId] = hasLiked;

        // Précharger nombre de diamonds actuel
        final videoDoc = await FirebaseFirestore.instance
            .collection('videos')
            .doc(videoId)
            .get();

        if (videoDoc.exists && videoDoc.data() != null) {
          final data = videoDoc.data()!;
          _videoDiamonds[videoId] = data['diamonds'] ?? 0;
        }
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Erreur préchargement: $e');
    }
  }

  // 💎 GESTION DIAMANTS OPTIMISÉE
  Future<void> _handleDiamondTap(Video video) async {
    if (_currentUserId == null || video.userId == _currentUserId) {
      _showCustomNotification(
        'Vous ne pouvez pas vous donner des diamants !',
        isError: true,
      );
      return;
    }

    HapticFeedback.mediumImpact();

    try {
      final videoId = video.id;
      final hasLiked = _userLikes[videoId] ?? false;

      // Optimisation UI immédiate
      setState(() {
        _userLikes[videoId] = !hasLiked;
        final currentDiamonds = _videoDiamonds[videoId] ?? video.diamonds ?? 0;
        _videoDiamonds[videoId] =
            hasLiked ? currentDiamonds - 1 : currentDiamonds + 1;
      });

      if (hasLiked) {
        await _databaseService.removeDiamond(
          videoId,
          video.userId,
          _currentUserId!,
        );
        _showCustomNotification('💎 Diamant retiré');
      } else {
        await _databaseService.giveDiamond(
          videoId,
          video.userId,
          _currentUserId!,
        );
        _showCustomNotification('💎 +1 pour ${video.username}');
      }
    } catch (e) {
      // Rollback en cas d'erreur
      final videoId = video.id;
      final hasLiked = _userLikes[videoId] ?? false;
      setState(() {
        _userLikes[videoId] = !hasLiked;
        final currentDiamonds = _videoDiamonds[videoId] ?? video.diamonds ?? 0;
        _videoDiamonds[videoId] =
            hasLiked ? currentDiamonds + 1 : currentDiamonds - 1;
      });

      _showCustomNotification('Erreur: $e', isError: true);
    }
  }

  // 🔔 NOTIFICATION PERSONNALISÉE AVANCÉE
  void _showCustomNotification(String message, {bool isError = false}) {
    if (message == _notificationMessage) return; // Éviter doublons

    HapticFeedback.lightImpact();

    setState(() {
      _notificationMessage = message;
      _notificationIsError = isError;
    });

    _notificationController.forward();

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted && _notificationMessage == message) {
        _notificationController.reverse().then((_) {
          if (mounted) {
            setState(() => _notificationMessage = '');
          }
        });
      }
    });
  }

  void _navigateToProfile(String userId) {
    if (userId.isNotEmpty && mounted) {
      HapticFeedback.selectionClick();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(userId: userId),
        ),
      );
    }
  }

  void _navigateToDiscover() {
    if (mounted) {
      HapticFeedback.selectionClick();
      Navigator.pushNamed(context, '/discover');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final videosToShow =
        _personalizedVideos.isNotEmpty ? _personalizedVideos : _videos;
    final theme = Theme.of(context);
    return ValueListenableBuilder(
      valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
      builder: (context, mode, _) {
        final isDarkMode = mode == AdaptiveThemeMode.dark;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                // Feed principal
                _isLoading
                    ? _buildLoadingState(
                        isDarkMode: isDarkMode, theme: theme, s: s)
                    : videosToShow.isEmpty
                        ? _buildEmptyState(
                            isDarkMode: isDarkMode, theme: theme, s: s)
                        : _buildVideoFeed(videosToShow, isDarkMode, theme),

                // Header animé
                _buildAnimatedHeader(videosToShow, theme, s),

                // Globe button
                _buildGlobeButton(),

                // Notification personnalisée
                _buildCustomNotification(isDarkMode, theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(
      {required bool isDarkMode, required ThemeData theme, required S s}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [const Color(0xFF1a1a1a), const Color(0xFF0a0a0a)]
              : [const Color(0xFFEDEDED), const Color(0xFFF8F8F8)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.cyanAccent, Colors.blueAccent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome,
                color: theme.primaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              s.feedPersonalizing, // ✅ localized: 'Personnalisation du feed...'
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.feedAnalyzingPreferences, // ✅ localized: 'Analyse de vos préférences'
              style: TextStyle(
                color: isDarkMode ? Colors.white54 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required bool isDarkMode,
    required ThemeData theme,
    required S s, // make sure to pass context
  }) {
    // localized strings

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [const Color(0xFF0a0a0a), const Color(0xFF1a1a1a)]
              : [const Color(0xFFF8F8F8), const Color(0xFFEDEDED)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [Colors.grey.shade800, Colors.grey.shade900]
                      : [Colors.grey.shade200, Colors.grey.shade100],
                ),
              ),
              child: const Icon(
                Icons.video_library_outlined,
                size: 60,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              s.noVideos, // ✅ Localized title
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              s.followCreators, // ✅ Localized subtitle
              style: TextStyle(
                color: isDarkMode ? Colors.white54 : Colors.black54,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadInitialFeed,
              icon: const Icon(Icons.refresh),
              label: Text(s.refresh), // ✅ Localized button
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: theme.scaffoldBackgroundColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
                shadowColor: Colors.cyanAccent.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoFeed(
    List<Video> videos,
    bool isDarkMode,
    ThemeData theme,
  ) {
    return RefreshIndicator(
      onRefresh: _loadInitialFeed,
      color: Colors.cyanAccent,
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        onPageChanged: (index) {
          setState(() {
            currentPageNotifier.value = index;
            _currentVideoIndex = index;
          });

          // 🔄 Preload interactions ahead of time (lookahead buffer of 3)
          if (index + 3 < videos.length) {
            _preloadUserInteractions();
          }

          // 📥 Load more videos when reaching near the bottom
          if (index >= videos.length - 5) {
            _loadVideoFeed();
          }
        },
        itemBuilder: (context, index) {
          final video = videos[index];

          final bool isLiked = _userLikes[video.id] ?? false;
          final int diamonds = _videoDiamonds[video.id] ?? video.diamonds ?? 0;

          // 🎬 Clone video with up-to-date values
          final updatedVideo = video.copyWith(
            diamonds: diamonds,
          );

          return KeepAliveVideoCard(
            video: updatedVideo,
            isLiked: isLiked,
            onDiamondTap: () => _handleDiamondTap(video),
            onProfileTap: () => _navigateToProfile(video.userId),
            theme: theme,
            isDarkMode: isDarkMode,
            currentVideoIndex: _currentVideoIndex == index,
            targetId: target_id,
            tabChanged: widget.tabChanged, pageIndex: _currentVideoIndex, currentPageNotifier: currentPageNotifier,
          );
        },
      ),
    );
  }

  Widget _buildAnimatedHeader(List<Video> videos, ThemeData theme, S s) {
    return Positioned(
      top: 16,
      left: 20,
      child: FadeTransition(
        opacity: _headerFadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.cyanAccent.withAlpha(38), // ~15%
                Colors.blueAccent.withAlpha(38),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.cyanAccent.withAlpha(102), // ~40%
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withAlpha(51), // ~20%
                blurRadius: 20,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                s.nowLabel.toUpperCase(), // 🌍 Localized "NOW"
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: theme.primaryColor,
                ),
              ),
              if (videos.isNotEmpty) ...[
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(38), // ~15%
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentVideoIndex + 1}/${videos.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlobeButton() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: FadeTransition(
          opacity: _headerFadeAnimation,
          child: GlobeButton(onTap: _navigateToDiscover),
        ),
      ),
    );
  }

  Widget _buildCustomNotification(bool isDark, ThemeData theme) {
    if (_notificationMessage.isEmpty) return const SizedBox();

    return Positioned(
      top: 90,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _notificationSlideAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _notificationIsError
                  ? [
                      const Color(0xFFFF5252),
                      const Color(0xFFD32F2F),
                    ]
                  : [
                      const Color(0xFF4CAF50),
                      const Color(0xFF388E3C),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (_notificationIsError
                        ? const Color(0xFFFF5252)
                        : const Color(0xFF4CAF50))
                    .withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _notificationIsError
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  color: theme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _notificationMessage,
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 📊 Classe pour vidéo avec score
class VideoWithScore {
  final Video video;
  final double score;

  VideoWithScore(this.video, this.score);
}

class KeepAliveVideoCard extends StatefulWidget {
  final Video video;
  final bool isLiked;
  final bool isDarkMode;
  final bool currentVideoIndex;
  final ThemeData theme;
  final String targetId;
  final VoidCallback onDiamondTap;
  final VoidCallback onProfileTap;
    final int pageIndex;
  final ValueNotifier<int> currentPageNotifier;
  final ValueNotifier<bool> tabChanged;
  const KeepAliveVideoCard({
    super.key,
    required this.video,
    required this.isLiked,
    required this.onDiamondTap,
    required this.onProfileTap,
    required this.theme,
    required this.isDarkMode,
    required this.currentVideoIndex,
    required this.targetId,
    required this.tabChanged, required this.pageIndex, required this.currentPageNotifier,
  });

  @override
  State<KeepAliveVideoCard> createState() => _KeepAliveVideoCardState();
}

class _KeepAliveVideoCardState extends State<KeepAliveVideoCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return VideoCard(
      video: widget.video,
      onDiamondTap: widget.onDiamondTap,
      onProfileTap: widget.onProfileTap,
      theme: widget.theme,
      isDarkMode: widget.isDarkMode,
      currentPage: widget.currentVideoIndex,
      target: widget.targetId,
      tabChanged: widget.tabChanged, pageIndex: widget.pageIndex, currentPageNotifier: widget.currentPageNotifier,
    );
  }
}
