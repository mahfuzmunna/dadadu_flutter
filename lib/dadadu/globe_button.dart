import 'package:flutter/material.dart';
// Pour HapticFeedback
import 'package:lottie/lottie.dart';     // Pour Lottie animation
import 'dadadu_screen.dart';             // Chemin correct vers l'écran cible

class GlobeButton extends StatefulWidget {
  final VoidCallback onTap;

  const GlobeButton({
    super.key,
    required this.onTap,
  });

  @override
  State<GlobeButton> createState() => _GlobeButtonState();
}

class _GlobeButtonState extends State<GlobeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
  _scaleController.reverse().then((_) {
  _scaleController.forward();
  if (mounted) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const DadaduScreen()),
  );
}
});
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleController,
      child: GestureDetector(
        onTap: _handleTap,
        child: SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Lottie.asset(
                'assets/animations/globe.json',
                width: 70,
                height: 70,
                repeat: true,
                fit: BoxFit.cover,
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x1AFFFFFF), // 10% opacity en hex
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
