import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/building.dart';

class BuildingRepository {
  List<Building>? _cache;

  Future<List<Building>> getAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/buildings.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _cache = list
        .map((e) => Building.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<Building?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
