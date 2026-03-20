import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/medicine.dart';

class MedicineService {
  static const _key = 'medicines';

  Future<List<Medicine>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    return raw.map((s) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        return Medicine.fromJson(m);
      } catch (_) {
        return null;
      }
    }).whereType<Medicine>().toList();
  }

  Future<void> saveAll(List<Medicine> medicines) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = medicines.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }

  Future<void> add(Medicine medicine) async {
    final list = await getAll();
    list.add(medicine);
    await saveAll(list);
  }

  Future<void> update(Medicine medicine) async {
    final list = await getAll();
    final idx = list.indexWhere((m) => m.id == medicine.id);
    if (idx != -1) {
      list[idx] = medicine;
      await saveAll(list);
    }
  }

  Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((m) => m.id == id);
    await saveAll(list);
  }
}
