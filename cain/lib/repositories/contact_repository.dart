import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/contact.dart';

class ContactRepository {
  List<Contact>? _cache;

  Future<List<Contact>> getAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/contacts.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _cache = list
        .map((e) => Contact.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<Contact?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Contact>> getByIds(List<String> ids) async {
    final all = await getAll();
    return all.where((c) => ids.contains(c.id)).toList();
  }

  Future<List<Contact>> search(String query, String locale) async {
    if (query.trim().isEmpty) return await getAll();
    final all = await getAll();
    final q = query.toLowerCase();
    return all.where((c) {
      return c.department.resolve(locale).toLowerCase().contains(q) ||
          c.duty.resolve(locale).toLowerCase().contains(q);
    }).toList();
  }
}
