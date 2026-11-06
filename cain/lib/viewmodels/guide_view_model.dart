import 'package:flutter/foundation.dart';
import '../models/service.dart';
import '../repositories/service_repository.dart';

class GuideViewModel extends ChangeNotifier {
  final ServiceRepository _repository;
  final String serviceId;

  GuideViewModel({
    required ServiceRepository repository,
    required this.serviceId,
    int stepIndex = 0,
  })  : _repository = repository,
        _currentIndex = stepIndex;

  ServiceModel? _service;
  bool _isLoading = false;
  bool _hasError = false;
  int _currentIndex;
  bool _disposed = false;

  ServiceModel? get service => _service;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  int get currentIndex => _currentIndex;

  Future<void> load() async {
    if (_isLoading || _disposed) return;
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      _service = await _repository.getById(serviceId);
    } catch (_) {
      _hasError = true;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  void next() {
    _currentIndex++;
    notifyListeners();
  }

  void prev() {
    _currentIndex--;
    notifyListeners();
  }

  void restart() {
    _currentIndex = 0;
    notifyListeners();
  }

  /// 추천 서비스 안내에 쓸 제목을 찾는다. 찾지 못하면 null.
  Future<String?> serviceTitle(String id, String locale) async {
    try {
      final found = await _repository.getById(id);
      return found?.title.resolve(locale);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
