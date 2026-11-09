import 'package:flutter/foundation.dart';
import '../models/service.dart';
import '../repositories/service_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final ServiceRepository _repository;

  HomeViewModel({required ServiceRepository repository}) : _repository = repository;

  List<ServiceModel> _featured = [];
  List<ServiceModel> _searchResults = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  List<ServiceModel> get featured => _featured;
  List<ServiceModel> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSearching => _searchQuery.isNotEmpty;

  Future<void> loadFeatured() async {
    if (_isLoading || _disposed) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final all = await _repository.getAll();
      // 홈에서는 첫 4개를 '주요 서비스'로 표시
      _featured = all.take(4).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> search(String query, String locale) async {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    try {
      _searchResults = await _repository.search(query, locale);
    } catch (_) {
      _searchResults = [];
    }
    if (!_disposed) notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
