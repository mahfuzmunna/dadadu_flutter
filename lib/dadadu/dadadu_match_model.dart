import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:start/generated/l10n.dart';
import 'dadadu_constants.dart';

class DadaduMatchModal extends StatefulWidget {
  final String name;
  final int age;
  final String imageUrl;
  final String intent;
  final double distance;
  final String language;
  final String userId; // ✅ AJOUT: ID utilisateur pour logique matching
  final int diamonds; // ✅ AJOUT: Nombre de diamonds de l'utilisateur
  final String mood; // ✅ AJOUT: Humeur actuelle
  final VoidCallback onAccept;
  final VoidCallback onIgnore;

  const DadaduMatchModal({
    super.key,
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.intent,
    required this.distance,
    required this.language,
    required this.userId,
    required this.diamonds,
    required this.mood,
    required this.onAccept,
    required this.onIgnore,
  });

  @override
  State<DadaduMatchModal> createState() => _DadaduMatchModalState();
}

class _DadaduMatchModalState extends State<DadaduMatchModal>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _controller.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color _getIntentColor() {
    switch (widget.intent.toLowerCase()) {
      case 'love':
        return Colors.pinkAccent;
      case 'business':
        return Colors.blueAccent;
      case 'entertainment':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  String _getIntentEmoji() {
    switch (widget.intent.toLowerCase()) {
      case 'love':
        return '💖';
      case 'business':
        return '💼';
      case 'entertainment':
        return '🎮';
      default:
        return '⭐';
    }
  }

  String _getMoodEmoji() {
    switch (widget.mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'excited':
        return '🤩';
      default:
        return '😐';
    }
  }

  Widget _buildCompatibilityBadge() {
    final loc = S.of(context);
    final compatibility = widget.distance <= 25
        ? loc.perfectMatch
        : widget.distance <= 40
            ? loc.greatMatch
            : loc.goodMatch;
    final badgeColor = widget.distance <= 25
        ? Colors.green
        : widget.distance <= 40
            ? Colors.orange
            : Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        compatibility,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildModalContent() {
    final loc = S.of(context);

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1a1a1a).withOpacity(0.95),
                const Color(0xFF2d2d2d).withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _getIntentColor().withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _getIntentColor().withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_getIntentEmoji()} ${loc.matchFound(_getIntentEmoji())}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  _buildCompatibilityBadge(),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnim.value,
                    child: Hero(
                      tag: heroAvatarTag,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getIntentColor(),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getIntentColor().withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(70),
                          child: Image.network(
                            widget.imageUrl,
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 140,
                                height: 140,
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white54,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                "${widget.name}, ${widget.age}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  loc.mood(_getMoodEmoji(), widget.mood),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                        "🎯", widget.intent.toUpperCase(), _getIntentColor()),
                    const SizedBox(height: 8),
                    _buildInfoRow("🌍", widget.language, Colors.blueAccent),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        "📍",
                        loc.away(widget.distance.toStringAsFixed(0)),
                        Colors.greenAccent),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        "💎",
                        loc.diamonds(widget.diamonds.toString()),
                        Colors.amberAccent),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      loc.skip,
                      Icons.close,
                      Colors.grey[700]!,
                      Colors.white70,
                      widget.onIgnore,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildActionButton(
                      loc.interested,
                      Icons.favorite,
                      _getIntentColor(),
                      Colors.white,
                      widget.onAccept,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String text, Color color) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color backgroundColor,
    Color textColor,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      icon: Icon(icon, color: textColor, size: 20),
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 8,
        shadowColor: backgroundColor.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withValues(alpha:  0.7),
            ),
          ),
          Center(child: _buildModalContent()),
        ],
      ),
    );
  }
}
