import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_strings.dart';

class LocaleProvider extends ChangeNotifier {
  static const _prefKey = 'selected_locale';

  String _locale = 'ko';
  bool _isLoaded = false;
  bool _hasSelected = false;
  bool _disposed = false;

  String get locale => _locale;
  bool get isLoaded => _isLoaded;

  /// 언어를 저장한 적이 있는가
  bool get hasSelected => _hasSelected;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null && kSupportedLocales.any((l) => l.code == saved)) {
        _locale = saved;
        _hasSelected = true;
      }
    } catch (_) {
      // 저장소를 읽지 못하면 언어 선택 화면에서 다시 고르게 한다.
    } finally {
      _isLoaded = true;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> setLocale(String code) async {
    // 첫 실행에서 기본값(ko)을 고른 경우에도 저장되도록 _hasSelected를 함께 본다.
    if (_locale == code && _hasSelected) return;
    _locale = code;
    _hasSelected = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
