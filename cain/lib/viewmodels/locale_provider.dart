import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_strings.dart';

class LocaleProvider extends ChangeNotifier {
  static const _prefKey = 'selected_locale';

  String _locale = 'ko';
  bool _isLoaded = false;

  String get locale => _locale;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null && kSupportedLocales.any((l) => l.code == saved)) {
      _locale = saved;
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    if (_locale == code) return;
    _locale = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
  }

  bool get hasSelected {
    return _isLoaded;
  }

  Future<bool> hasStoredLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_prefKey);
  }
}
