import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme();
  }

  // Load the saved theme from device storage
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // final themeIndex = prefs.getInt('themeMode') ?? 2; // Default to system
    final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    emit(ThemeMode.values[themeIndex]);
  }

  // Update the theme and save the choice
  void updateTheme(ThemeMode newThemeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', newThemeMode.index);
    emit(newThemeMode);
  }
}
