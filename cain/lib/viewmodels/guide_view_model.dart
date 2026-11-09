import 'package:flutter/foundation.dart';
import '../models/building.dart';
import '../models/service.dart';
import '../repositories/building_repository.dart';
import '../repositories/service_repository.dart';

class GuideViewModel extends ChangeNotifier {
  final ServiceRepository _repository;
  final BuildingRepository? _buildingRepository;
  final String serviceId;

  GuideViewModel({
    required ServiceRepository repository,
    BuildingRepository? buildingRepository,
    required this.serviceId,
    int stepIndex = 0,
  })  : _repository = repository,
        _buildingRepository = buildingRepository,
        _currentIndex = stepIndex;

  ServiceModel? _service;
  Building? _building;
  bool _isLoading = false;
  bool _hasError = false;
  int _currentIndex;
  bool _disposed = false;

  ServiceModel? get service => _service;

  /// 서비스가 안내하는 건물 (좌표가 있으면 단계 화면 지도에 사용)
  Building? get building => _building;
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
      await _loadBuilding(_service?.buildingId);
    } catch (_) {
      _hasError = true;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  // 건물 정보는 지도 표시용 부가 정보라서, 불러오지 못해도 단계 안내는 계속 보여준다.
  Future<void> _loadBuilding(String? buildingId) async {
    final repository = _buildingRepository;
    if (repository == null || buildingId == null) return;
    try {
      _building = await repository.getById(buildingId);
    } catch (e) {
      debugPrint('[GuideViewModel] 건물 정보 로드 실패: $e');
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
