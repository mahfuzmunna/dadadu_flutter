// lib/core/widgets/custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color; // Optional background color
  final Color? textColor; // Optional text color
  final EdgeInsetsGeometry padding; // Optional padding inside the button
  final double borderRadius; // Optional border radius for rounded corners

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // Use provided color or default to the primary color from the theme
        backgroundColor: color ?? Theme.of(context).primaryColor,
        // Use provided text color or default to white
        foregroundColor: textColor ?? Colors.white,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        // You can add elevation, minimumSize, etc. here if needed
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
