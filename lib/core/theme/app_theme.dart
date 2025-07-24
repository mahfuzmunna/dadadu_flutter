// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts package

class AppTheme {
  // Define a single seed color for your app's primary palette
  // static const Color _primarySeed = Color(0xFF673AB7); // A deep purple/violet
  static const Color _primarySeed = Color(0xFF0061A4); // A deep purple/violet

  // Light Color Scheme
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _primarySeed,
    brightness: Brightness.light,
  );

  // Dark Color Scheme
  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _primarySeed,
    brightness: Brightness.dark,
  );

  // Helper function to build a text theme with Montserrat
  static TextTheme _buildMontserratTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.nunito(textStyle: base.displayLarge),
      displayMedium: GoogleFonts.nunito(textStyle: base.displayMedium),
      displaySmall: GoogleFonts.nunito(textStyle: base.displaySmall),
      headlineLarge: GoogleFonts.nunito(textStyle: base.headlineLarge),
      headlineMedium: GoogleFonts.nunito(textStyle: base.headlineMedium),
      headlineSmall: GoogleFonts.nunito(textStyle: base.headlineSmall),
      titleLarge: GoogleFonts.nunito(textStyle: base.titleLarge),
      titleMedium: GoogleFonts.nunito(textStyle: base.titleMedium),
      titleSmall: GoogleFonts.nunito(textStyle: base.titleSmall),
      bodyLarge: GoogleFonts.nunito(textStyle: base.bodyLarge),
      bodyMedium: GoogleFonts.nunito(textStyle: base.bodyMedium),
      bodySmall: GoogleFonts.nunito(textStyle: base.bodySmall),
      labelLarge: GoogleFonts.nunito(textStyle: base.labelLarge),
      labelMedium: GoogleFonts.nunito(textStyle: base.labelMedium),
      labelSmall: GoogleFonts.nunito(textStyle: base.labelSmall),
    );
  }

  // Light Theme Data
  static ThemeData get lightTheme {
    final ThemeData baseTheme = ThemeData.light(); // Get the default light theme
    return ThemeData(
      colorScheme: _lightColorScheme,
      useMaterial3: true, // Crucial for Material 3
      appBarTheme: AppBarTheme(
        // backgroundColor: _lightColorScheme.primaryContainer,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark),
        foregroundColor: _lightColorScheme.onPrimaryContainer,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _buildMontserratTextTheme(baseTheme.textTheme).titleLarge?.copyWith( // Apply Montserrat via helper
          color: _lightColorScheme.onPrimaryContainer,
          // fontSize: 20, // Let the textTheme define the size unless specific override is needed
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData( // Use CardTheme, not CardThemeData
        color: _lightColorScheme.surfaceContainerHigh,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightColorScheme.surfaceContainerHighest, // Or surfaceContainerLow
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // No border by default for filled
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightColorScheme.outline, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightColorScheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightColorScheme.error, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightColorScheme.error, width: 2.0),
        ),
        labelStyle: _buildMontserratTextTheme(baseTheme.textTheme).bodyLarge?.copyWith(color: _lightColorScheme.onSurfaceVariant), // Apply Montserrat
        hintStyle: _buildMontserratTextTheme(baseTheme.textTheme).bodyLarge?.copyWith(color: _lightColorScheme.onSurfaceVariant.withOpacity(0.6)), // Apply Montserrat
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightColorScheme.primary,
          foregroundColor: _lightColorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: _buildMontserratTextTheme(baseTheme.textTheme).labelLarge?.copyWith( // Apply Montserrat
            // fontSize: 16, // Let the textTheme define the size
            fontWeight: FontWeight.bold,
            color: _lightColorScheme.onPrimary, // This color will be overridden by foregroundColor
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _lightColorScheme.primary,
          foregroundColor: _lightColorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: _buildMontserratTextTheme(baseTheme.textTheme).labelLarge?.copyWith( // Apply Montserrat
            // fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _lightColorScheme.onPrimary, // This color will be overridden by foregroundColor
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightColorScheme.primary,
          side: BorderSide(color: _lightColorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: _buildMontserratTextTheme(baseTheme.textTheme).labelLarge?.copyWith( // Apply Montserrat
            // fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _lightColorScheme.primary, // This color will be overridden by foregroundColor
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightColorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: _buildMontserratTextTheme(baseTheme.textTheme).labelLarge?.copyWith( // Apply Montserrat
            // fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _lightColorScheme.primary, // This color will be overridden by foregroundColor
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _lightColorScheme.tertiaryContainer,
        foregroundColor: _lightColorScheme.onTertiaryContainer,
      ),
      // Apply the Montserrat text theme to the entire app
      textTheme: _buildMontserratTextTheme(baseTheme.textTheme),
    );
  }

  // Dark Theme Data
  static ThemeData get darkTheme {
    final ThemeData baseTheme = ThemeData.dark(); // Get the default dark theme
    return ThemeData(
      colorScheme: _darkColorScheme,
      useMaterial3: true, // Crucial for Material 3
      appBarTheme: AppBarTheme(
        // backgroundColor: _darkColorScheme.primaryContainer,
        backgroundColor: Colors.transparent,
        foregroundColor: _darkColorScheme.onPrimaryContainer,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _buildMontserratTextTheme(baseTheme.textTheme).titleLarge?.copyWith( // Apply Montserrat via helper
          color: _darkColorScheme.onPrimaryContainer,
          // fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData( // Use CardTheme, not CardThemeData
        color: _darkColorScheme.surfaceContainerHigh,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkColorScheme.outline, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkColorScheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkColorScheme.error, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkColorScheme.error, width: 2.0),
        ),
        labelStyle: _buildMontserratTextTheme(baseTheme.textTheme).bodyLarge?.copyWith(color: _darkColorScheme.onSurfaceVariant), // Apply Montserrat
        hintStyle: _buildMontserratTextTheme(baseTheme.textTheme).bodyLarge?.copyWith(color: _darkColorScheme.onSurfaceVariant.withOpacity(0.6)), // Apply Montserrat
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkColorScheme.primary,
          foregroundColor: _darkColorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: _buildMontserratTextTheme(baseTheme.textTheme).labelLarge?.copyWith( // Apply Montserrat
            // fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _darkColorScheme.onPrimary,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _darkColorScheme.primary,
          foregroundColor: _darkColorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: _buildMontserratTextTheme(baseTheme.textTheme).labelLarge?.copyWith( // Apply Montserrat
            // fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _darkColorScheme.onPrimary,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkColorScheme.primary,
          side: BorderSide(color: _darkColorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: _buildMontserratTextTheme(baseTheme.textTheme).labelLarge?.copyWith( // Apply Montserrat
            // fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _darkColorScheme.primary,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkColorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: _buildMontserratTextTheme(baseTheme.textTheme).labelLarge?.copyWith( // Apply Montserrat
            // fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _darkColorScheme.primary,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _darkColorScheme.tertiaryContainer,
        foregroundColor: _darkColorScheme.onTertiaryContainer,
      ),
      // Apply the Montserrat text theme to the entire app
      textTheme: _buildMontserratTextTheme(baseTheme.textTheme),
    );
  }
}