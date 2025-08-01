// lib/core/locale/locale_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en')) {
    // Default to English
    _loadLocale();
  }

  // Load the saved language from device storage
  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode =
        prefs.getString('languageCode') ?? 'en'; // Default to 'en'
    emit(Locale(languageCode));
  }

  // Update the language and save the new preference
  void updateLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    emit(locale);
  }
}
