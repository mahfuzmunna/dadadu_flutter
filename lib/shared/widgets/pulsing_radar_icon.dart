import 'package:flutter/material.dart';

class PulsingRadarIcon extends StatefulWidget {
  final double size;
  final Color color;
  final IconData icon;

  const PulsingRadarIcon({
    super.key,
    this.size = 120.0,
    this.color = Colors.blue,
    this.icon = Icons.radar,
  });

  @override
  State<PulsingRadarIcon> createState() => _PulsingRadarIconState();
}

class _PulsingRadarIconState extends State<PulsingRadarIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Make it loop and reverse for a pulsing effect

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const LinearGradient glowGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
    );
    List<BoxShadow> glowShadow(Color color) => [
          BoxShadow(
            color: color.withAlpha((255 * 0.3).toInt()),
            // équivalent à 0.3 d’opacité
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ];
    const Color accentGlow = Color(0xFF00F5FF);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: glowGradient,
                boxShadow: glowShadow(accentGlow)),
            child: Icon(
              widget.icon,
              size: widget.size * 0.5, // Icon size is half of the total size
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
