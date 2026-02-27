import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = AppConstants.defaultLanguage;

  String get currentLanguage => _currentLanguage;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(AppConstants.keyLanguage) ??
        AppConstants.defaultLanguage;
    notifyListeners();
  }

  Future<void> switchLanguage(String language) async {
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, language);
    notifyListeners();
  }

  String getText(String en, String ja) {
    return _currentLanguage == 'en' ? en : ja;
  }
}
