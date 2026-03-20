import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/doctor.dart';

class DoctorService {
  static const _key = 'doctors';

  Future<List<Doctor>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    return raw.map((s) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        return Doctor.fromJson(m);
      } catch (_) {
        return null;
      }
    }).whereType<Doctor>().toList();
  }

  Future<void> saveAll(List<Doctor> doctors) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = doctors.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }

  Future<void> add(Doctor doctor) async {
    final list = await getAll();
    list.add(doctor);
    await saveAll(list);
  }

  Future<void> update(Doctor doctor) async {
    final list = await getAll();
    final idx = list.indexWhere((d) => d.id == doctor.id);
    if (idx != -1) {
      list[idx] = doctor;
      await saveAll(list);
    }
  }

  Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((d) => d.id == id);
    await saveAll(list);
  }
}
