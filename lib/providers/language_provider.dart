import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = AppConstants.defaultLanguage;
  String get currentLanguage => _currentLanguage;

  LanguageProvider() { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(AppConstants.keyLanguage) ?? AppConstants.defaultLanguage;
    notifyListeners();
  }

  Future<void> switchLanguage(String lang) async {
    _currentLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, lang);
    notifyListeners();
  }
}
