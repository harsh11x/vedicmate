import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Locale> {
  static const String _kLanguageCode = 'language_code';
  
  LanguageNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  // All supported languages (add more as you get ARB files)
  // For now, we only have English and Hindi ARB files.
  // Other selections will default to English unless files are added,
  // OR we can dynamically load translations (advanced).
  // I will assume for now we only support 'en' and 'hi' fully,
  // but I will list others in the Settings UI as placeholders or 
  // allow selecting them with English fallback if that's what's preferred locally.
  
  // Mapping of Language Name to Locale
  static const Map<String, Locale> supportedLanguages = {
    'English': Locale('en'),
    'Hindi': Locale('hi'),
    'Spanish': Locale('es'),
    'French': Locale('fr'),
    'German': Locale('de'),
    'Japanese': Locale('ja'),
    'Russian': Locale('ru'),
    'Arabic': Locale('ar'),
    'Portuguese': Locale('pt'),
    'Bengali': Locale('bn'),
    'Tamil': Locale('ta'),
    'Telugu': Locale('te'),
    'Marathi': Locale('mr'),
    'Gujarati': Locale('gu'),
  };

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_kLanguageCode);
    if (langCode != null) {
      state = Locale(langCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguageCode, locale.languageCode);
    debugPrint('LanguageNotifier: Set locale to ${locale.languageCode}');
  }
  
  Future<void> setLanguageByName(String name) async {
    final locale = supportedLanguages[name];
    if (locale != null) {
      await setLocale(locale);
    }
  }
}
