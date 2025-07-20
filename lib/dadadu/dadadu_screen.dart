import 'dart:math';
import 'dart:async';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:start/generated/l10n.dart';
import '../core/constants/dadadu_constants.dart';
import 'dadadu_match_model.dart';

class DadaduScreen extends StatefulWidget {
  const DadaduScreen({super.key});

  @override
  State<DadaduScreen> createState() => _DadaduScreenState();
}

class _DadaduScreenState extends State<DadaduScreen>
    with TickerProviderStateMixin {
  List<DocumentSnapshot> _matches = [];
  String _selectedIntent = "";
  bool _isSearching = false;
  bool _hasLocationPermission = false;
  Position? _currentPosition;
  Timer? _searchTimer;

  late AnimationController _pulseController;
  late AnimationController _scanController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );

    _pulseController.repeat(reverse: true);
  }

  Future<void> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _currentPosition = await Geolocator.getCurrentPosition();
        setState(() => _hasLocationPermission = true);
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

Future<void> _findMatches(String intent) async {
  if (!_hasLocationPermission || _currentPosition == null) {
    _showLocationError(); // Already localized separately
    return;
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  setState(() {
    _matches = [];
    _selectedIntent = intent;
    _isSearching = true;
  });

  _scanController.repeat();
  HapticFeedback.lightImpact();

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({
      'latitude': _currentPosition!.latitude,
      'longitude': _currentPosition!.longitude,
      'intent': intent,
      'lastActive': FieldValue.serverTimestamp(),
      'isSearching': true,
    });

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('intent', isEqualTo: intent)
        .where('isSearching', isEqualTo: true)
        .limit(20)
        .get();

    final List<DocumentSnapshot> candidates = [];

    for (var doc in query.docs) {
      if (doc.id == currentUser.uid) continue;

      final data = doc.data();
      final userLat = data['latitude']?.toDouble();
      final userLng = data['longitude']?.toDouble();

      if (userLat == null || userLng == null) continue;

      final distance = _calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        userLat,
        userLng,
      );

      if (distance <= maxDetectionDistanceMeters) {
        candidates.add(doc);
      }
    }

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _matches = candidates;
        _isSearching = false;
      });
      _scanController.stop();

      if (candidates.isNotEmpty) {
        HapticFeedback.heavyImpact();
        _showMatch(candidates.first);
      } else {
        HapticFeedback.lightImpact();
      }
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isSearching = false);
      _scanController.stop();
      if (mounted) {
         _showError('${S.of(context).searchFailed}: $e');
      }
     
    }
  }
}

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _deg2rad(double deg) => deg * pi / 180;

  void _showMatch(DocumentSnapshot matchDoc) {
    final data = matchDoc.data() as Map<String, dynamic>;
    final distance = _calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      data['latitude']?.toDouble() ?? 0,
      data['longitude']?.toDouble() ?? 0,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DadaduMatchModal(
        name: data['username'] ?? 'Unknown',
        age: data['age'] ?? 18,
        imageUrl: data['profilePicture'] ?? '',
        intent: _selectedIntent,
        distance: distance,
        language: data['language'] ?? 'Unknown',
        userId: matchDoc.id,
        diamonds: data['totalDiamonds'] ?? 0,
        mood: data['mood'] ?? 'Happy',
        onAccept: () => _handleAccept(matchDoc),
        onIgnore: () => _handleIgnore(),
      ),
    );
  }

Future<void> _handleAccept(DocumentSnapshot matchDoc) async {
  Navigator.pop(context);
  HapticFeedback.heavyImpact();

  final currentUser = FirebaseAuth.instance.currentUser!;

  try {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final matchUserRef =
          FirebaseFirestore.instance.collection('users').doc(matchDoc.id);

      transaction.update(matchUserRef, {
        'interestedBy': FieldValue.arrayUnion([currentUser.uid])
      });

      final matchData = matchDoc.data() as Map<String, dynamic>;
      final interestedBy = List<String>.from(matchData['interestedBy'] ?? []);

      if (interestedBy.contains(currentUser.uid)) {
        final timestamp = FieldValue.serverTimestamp();

        transaction.set(currentUserRef.collection('matchHistory').doc(), {
          'matchedWith': matchDoc.id,
          'intent': _selectedIntent,
          'mutual': true,
          'timestamp': timestamp,
        });

        transaction.set(matchUserRef.collection('matchHistory').doc(), {
          'matchedWith': currentUser.uid,
          'intent': _selectedIntent,
          'mutual': true,
          'timestamp': timestamp,
        });

        _showMutualMatch(matchData);
      } else {
        _showInterestSent();
      }
    });
  } catch (e) {
    if (mounted) {
      _showError('${S.of(context).interestFailed}: $e');
    }
    
  }
}

  void _handleIgnore() {
    Navigator.pop(context);
    HapticFeedback.lightImpact();
    _findNextMatch();
  }

  void _findNextMatch() {
    if (_matches.length > 1) {
      setState(() => _matches.removeAt(0));
      _showMatch(_matches.first);
    } else {
      setState(() {
        _matches.clear();
        _selectedIntent = "";
      });
    }
  }

 void _showMutualMatch(Map<String, dynamic> matchData) {
  final contact = Map<String, dynamic>.from(matchData['contact'] ?? {});
  final contactInfo = contact.isNotEmpty
      ? '${contact.keys.first}: ${contact.values.first}'
      : S.of(context).noContactInfo;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: DadaduUI.secondaryDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        S.of(context).mutualMatchTitle,
        style: const TextStyle(color: Colors.white),
      ),
      content: Text(
        '${S.of(context).contactLabel} $contactInfo',
        style: const TextStyle(color: Colors.amberAccent),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).greatButton),
        ),
      ],
    ),
  );
}


void _showInterestSent() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(S.of(context).interestSentWaiting),
      backgroundColor: Colors.green,
    ),
  );
}


void _showLocationError() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(S.of(context).locationPermissionRequired),
      backgroundColor: Colors.red,
    ),
  );
}

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

 Widget _buildIntentSelector(ThemeData theme) {
  return Container(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: DadaduUI.glowGradient,
                  boxShadow: DadaduUI.glowShadow(DadaduUI.accentGlow),
                ),
                child: const Icon(
                  Icons.radar,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        Text(
          S.of(context).whatsYourVibe,
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ...DadaduIntent.values.map((intent) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildIntentButton(intent),
            )),
        const SizedBox(height: 32),
        if (!_hasLocationPermission)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(25, 255, 107, 53),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DadaduUI.warningGlow),
            ),
            child: Text(
              S.of(context).locationPermissionNeeded,
              style: const TextStyle(color: Colors.orange),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    ),
  );
}

  Widget _buildIntentButton(DadaduIntent intent) {
    final label = dadaduIntentLabels[intent]!;
    final color = dadaduIntentColors[intent]!;
    final icon = dadaduIntentIcons[intent]!;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _findMatches(label.toLowerCase()),
        icon: Icon(icon, color: color, size: 24),
        label: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Color.fromARGB(25, color.red, color.green, color.blue),
          side: BorderSide(color: color, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildNoMatchesState(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_searching,
            size: 80,
            color: isDarkMode ? Colors.grey[600] : Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            S.of(context).noMatchesFoundNearby,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).tryChangingIntentOrLater,
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.black54,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => setState(() => _selectedIntent = ""),
            style: ElevatedButton.styleFrom(
              backgroundColor: DadaduUI.accentGlow,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              S.of(context).tryAgain,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildSearchingState(bool isDarkMode) {
  return Container(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _scanAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _scanAnimation.value,
              child: Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color.fromARGB(76, 255, 64, 129),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.radar,
                  size: 80,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        Text(
          S.of(context).scanningForConnections,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          S.of(context).lookingForIntentNearby(_selectedIntent),
          style: TextStyle(
            color: isDarkMode ? Colors.white54 : Colors.black54,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: () {
            setState(() {
              _selectedIntent = "";
              _isSearching = false;
            });
            _scanController.stop();
          },
          child: Text(
            S.of(context).cancelSearch,
            style: TextStyle(
              color: isDarkMode ? Colors.grey : const Color(0xFF9E9E9E),
            ),
          ),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

    return PopScope(
      canPop: _selectedIntent.isEmpty, // Always intercept manually
      onPopInvokedWithResult: (didPop, result) {
        if (_selectedIntent.isNotEmpty || _isSearching) {
          setState(() {
            _selectedIntent = "";
            _isSearching = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor:
            isDarkMode ? DadaduUI.primaryDark : DadaduUI.primaryLight,
        appBar: AppBar(
          title: Text(
            S.of(context).discover, // ← Localized title
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient:
                isDarkMode ? DadaduUI.darkGradient : DadaduUI.lightGradient,
          ),
          child: _selectedIntent.isEmpty
              ? _buildIntentSelector(theme)
              : _isSearching
                  ? _buildSearchingState(isDarkMode)
                  : _matches.isEmpty
                      ? _buildNoMatchesState(isDarkMode)
                      : Container(),
        ),
      ),
    );
  }
}
