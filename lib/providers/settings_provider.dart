import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unibook/core/constants/app_strings.dart';

class SettingsProvider extends ChangeNotifier {
  static const _themeKey = 'settings_theme_mode';
  static const _languageKey = 'settings_language';

  ThemeMode _themeMode = ThemeMode.dark;
  String _languageCode = 'ru';
  bool _isReady = false;

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  bool get isReady => _isReady;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawTheme = prefs.getString(_themeKey);
    final rawLang = prefs.getString(_languageKey);

    if (rawTheme == ThemeMode.light.name) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }

    if (rawLang != null && AppStrings.all.containsKey(rawLang)) {
      _languageCode = rawLang;
    }

    _isReady = true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeMode.name);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (!AppStrings.all.containsKey(languageCode)) return;
    _languageCode = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    notifyListeners();
  }

  String t(String key) => AppStrings.translate(key, languageCode: _languageCode);
}
