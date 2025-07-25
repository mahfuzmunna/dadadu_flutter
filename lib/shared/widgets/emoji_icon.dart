import 'package:flutter/material.dart';

class EmojiIcon extends StatelessWidget {
  final String emoji;
  final double size;

  const EmojiIcon(
    this.emoji, {
    super.key,
    this.size = 24.0, // Default size similar to the Icon widget
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      style: TextStyle(
        fontSize: size,
        // This can sometimes help with rendering consistency on different platforms
        fontFamily: 'AppleColorEmoji',
      ),
    );
  }
}
