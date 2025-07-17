import 'package:flutter/material.dart';

class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color glowColor;
  final double width;
  final double height;

  const NeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.glowColor = Colors.cyanAccent,
    this.width = 200,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final Color shadowColor = glowColor.withAlpha((0.7 * 255).toInt()); // ✅ Sans .withOpacity

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
          ],
          border: Border.all(color: glowColor, width: 1.2),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: glowColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
