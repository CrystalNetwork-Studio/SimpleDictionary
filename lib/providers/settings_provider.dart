import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _themeModeKey = 'themeMode';
  static const String _localeKey = 'appLocale';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = false;
  Locale? _locale;

  SettingsProvider() {
    _loadSettings();
  }
  bool get isLoading => _isLoading;
  Locale? get locale => _locale;

  ThemeMode get themeMode => _themeMode;

  Future<void> setLocale(Locale? locale) async {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale?.languageCode ?? '');
    } catch (e) {
      print("Error saving locale: $e");
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
    } catch (e) {
      print("Error saving theme mode: $e");
    }
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
      if (themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeIndex];
      } else {
        _themeMode = ThemeMode.system;
      }

      final localeCode = prefs.getString(_localeKey);
      if (localeCode != null) {
        _locale = Locale(localeCode);
      } else {
        _locale = null;
      }
    } catch (e) {
      print("Error loading settings: $e");
      _themeMode = ThemeMode.system;
      _locale = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
