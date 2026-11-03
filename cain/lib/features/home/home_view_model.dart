import 'package:flutter/material.dart';
import '../../core/models/service.dart';
import '../../core/repositories/service_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final ServiceRepository _repo;

  HomeViewModel(this._repo);

  List<ServiceModel> _featured = [];
  List<ServiceModel> _searchResults = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  List<ServiceModel> get featured => _featured;
  List<ServiceModel> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSearching => _searchQuery.isNotEmpty;

  Future<void> loadFeatured() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final all = await _repo.getAll();
      // 홈에서는 첫 4개를 '주요 서비스'로 표시
      _featured = all.take(4).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
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
      _searchResults = await _repo.search(query, locale);
    } catch (_) {
      _searchResults = [];
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }
}
