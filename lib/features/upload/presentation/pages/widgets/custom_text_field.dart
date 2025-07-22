// lib/core/widgets/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller; // Controller for text input
  final String hintText; // Placeholder text
  final bool obscureText; // Whether to hide input (e.g., for passwords)
  final TextInputType keyboardType; // Type of keyboard to display
  final int? maxLines; // Maximum number of lines for the input
  final Widget? prefixIcon; // Icon displayed at the beginning of the text field
  final Widget? suffixIcon; // Icon displayed at the end of the text field
  final String? Function(String?)? validator; // Optional validation function

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        // Default border style
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        // Border style when the text field is enabled but not focused
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        // Border style when the text field is focused
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
        ),
        filled: true,
        // Whether the decoration area is filled with fill color
        fillColor: Colors.grey[100],
        // Color to fill the decoration area
        // Padding for the content within the text field
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      validator: validator, // Assign the optional validator
    );
  }
}
