import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/hospital.dart';

class HospitalService {
  static const _key = 'hospitals_v1';

  Future<List<Hospital>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    return raw.map((s) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        return Hospital.fromJson(m);
      } catch (_) {
        return null;
      }
    }).whereType<Hospital>().toList();
  }

  Future<void> saveAll(List<Hospital> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = items.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }

  Future<void> add(Hospital item) async {
    final list = await getAll();
    list.add(item);
    await saveAll(list);
  }

  Future<void> update(Hospital item) async {
    final list = await getAll();
    final idx = list.indexWhere((d) => d.id == item.id);
    if (idx != -1) {
      list[idx] = item;
      await saveAll(list);
    }
  }

  Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((d) => d.id == id);
    await saveAll(list);
  }
}
