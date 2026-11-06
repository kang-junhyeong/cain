import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/service.dart';
import 'service_repository.dart';

class LocalServiceRepository implements ServiceRepository {
  List<ServiceModel>? _cache;

  @override
  Future<List<ServiceModel>> getAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/services.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _cache = list
        .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  @override
  Future<List<ServiceModel>> getByCategory(String categoryId) async {
    final all = await getAll();
    return all.where((s) => s.categoryId == categoryId).toList();
  }

  @override
  Future<ServiceModel?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ServiceModel>> search(String query, String locale) async {
    if (query.trim().isEmpty) return [];
    final all = await getAll();
    final q = query.toLowerCase();
    return all.where((s) {
      return s.title.resolve(locale).toLowerCase().contains(q) ||
          s.summary.resolve(locale).toLowerCase().contains(q);
    }).toList();
  }
}
