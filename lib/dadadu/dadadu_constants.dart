import 'package:flutter/material.dart';

/// 🌍 Maximum distance in meters to detect a real-time match
const double maxDetectionDistanceMeters = 50.0;

/// 📏 Distance ranges for compatibility calculation
const double perfectMatchDistance = 25.0;
const double greatMatchDistance = 40.0;

/// ⏱️ Timing constants for animations and interactions
const Duration matchAnimationDuration = Duration(milliseconds: 600);
const Duration pulseAnimationDuration = Duration(milliseconds: 1500);
const Duration searchCooldownDuration = Duration(seconds: 5);

/// 🧠 Types of possible user intents in Dadadu
enum DadaduIntent {
  love,
  business,
  entertainment,
}

/// 📊 Compatibility levels based on distance
enum CompatibilityLevel {
  perfect,
  great,
  good,
}

/// 🎭 User mood states
enum UserMood {
  happy,
  sad,
  excited,
  chill,
  focused,
  adventurous,
}

/// 🔤 Public label for each intent (for UI display)
const Map<DadaduIntent, String> dadaduIntentLabels = {
  DadaduIntent.love: "Love",
  DadaduIntent.business: "Business",
  DadaduIntent.entertainment: "Entertainment",
};

/// 🎨 Associated UI color for each intent
const Map<DadaduIntent, Color> dadaduIntentColors = {
  DadaduIntent.love: Colors.pinkAccent,
  DadaduIntent.business: Colors.blueAccent,
  DadaduIntent.entertainment: Colors.orangeAccent,
};

/// 🌈 Gradient colors for each intent
const Map<DadaduIntent, List<Color>> dadaduIntentGradients = {
  DadaduIntent.love: [Color(0xFFFF6B9D), Color(0xFFFF8E8E)],
  DadaduIntent.business: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
  DadaduIntent.entertainment: [Color(0xFFFFB74D), Color(0xFFFF9800)],
};

/// 🌐 Icon for each intent
const Map<DadaduIntent, IconData> dadaduIntentIcons = {
  DadaduIntent.love: Icons.favorite,
  DadaduIntent.business: Icons.business_center,
  DadaduIntent.entertainment: Icons.sports_esports,
};

/// 🎭 Mood labels and emojis
const Map<UserMood, String> moodLabels = {
  UserMood.happy: "Happy",
  UserMood.sad: "Sad",
  UserMood.excited: "Excited",
  UserMood.chill: "Chill",
  UserMood.focused: "Focused",
  UserMood.adventurous: "Adventurous",
};

const Map<UserMood, String> moodEmojis = {
  UserMood.happy: "😊",
  UserMood.sad: "😢",
  UserMood.excited: "🤩",
  UserMood.chill: "😎",
  UserMood.focused: "🎯",
  UserMood.adventurous: "🚀",
};

/// 📊 Compatibility level labels and colors
const Map<CompatibilityLevel, String> compatibilityLabels = {
  CompatibilityLevel.perfect: "Perfect Match",
  CompatibilityLevel.great: "Great Match",
  CompatibilityLevel.good: "Good Match",
};

const Map<CompatibilityLevel, Color> compatibilityColors = {
  CompatibilityLevel.perfect: Colors.green,
  CompatibilityLevel.great: Colors.orange,
  CompatibilityLevel.good: Colors.blue,
};

/// 💎 Diamond system constants
const int diamondsPerMatch = 10;
const int diamondsReferralBonus = 100;
const int dadalordThreshold = 10000000; // 10M diamonds

/// 🏆 Badge system
enum BadgeType {
  leaf,
  threeLeaf,
  fiveLeaf,
  dadalord,
}

const Map<BadgeType, String> badgeLabels = {
  BadgeType.leaf: "Leaf",
  BadgeType.threeLeaf: "ThreeLeaf",
  BadgeType.fiveLeaf: "FiveLeaf",
  BadgeType.dadalord: "Dadalord",
};

const Map<BadgeType, String> badgeEmojis = {
  BadgeType.leaf: "🍃",
  BadgeType.threeLeaf: "☘️",
  BadgeType.fiveLeaf: "🎀",
  BadgeType.dadalord: "👑",
};

const Map<BadgeType, int> badgeThresholds = {
  BadgeType.leaf: 0,
  BadgeType.threeLeaf: 10000,
  BadgeType.fiveLeaf: 1000000,
  BadgeType.dadalord: 10000000,
};

/// 🎯 Used for hero animations (avatar transition)
const String heroAvatarTag = "dadadu-avatar";
const String heroGlobeTag = "dadadu-globe";

/// 🎨 UI Design constants
class DadaduUI {
  // Colors
  static const Color primaryDark = Color(0xFF0A0A0A);
  static const Color primaryLight = Color(0xFFF9F9F9);

  static const Color secondaryDark = Color(0xFF1A1A1A);
  static const Color accentGlow = Color(0xFF00F5FF);
  static const Color warningGlow = Color(0xFFFF6B35);
  static const Color successGlow = Color(0xFF4ECDC4);

  // Gradients
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
  );

static const LinearGradient lightGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFF0F0F0), // light grey-white
    Color(0xFFE8E8E8), // soft light grey
    Color(0xFFDADADA), // gentle grey for depth
  ],
);


  static const LinearGradient glowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
  );

  // Border radius
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 20.0;
  static const double radiusLarge = 30.0;
  static const double radiusExtra = 40.0;

  // Shadows
  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withAlpha((255 * 0.3).toInt()), // équivalent à 0.3 d’opacité
      blurRadius: 20,
      spreadRadius: 5,
    ),
  ];

  static List<BoxShadow> deepShadow = [
    const BoxShadow(
      color: Colors.black54,
      blurRadius: 15,
      offset: Offset(0, 8),
    ),
  ];
}

/// 💬 Reusable system messages (ready for localization)
class DadaduMessages {
  static const String noNearbyUser = "No compatible user nearby.";
  static const String matchFound = "Connection detected within 50 meters!";
  static const String chooseIntent = "Choose a connection intent 🌐";
  static const String searching = "Searching for matches...";
  static const String connectionSuccess = "Connection established!";
  static const String mutualInterest = "Mutual interest detected!";
}