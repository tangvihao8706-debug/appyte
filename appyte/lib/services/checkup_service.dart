import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/checkup.dart';
import 'notification_service.dart';

class CheckupService {
  static const _key = 'checkups';

  Future<List<Checkup>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    return raw.map((s) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        return Checkup.fromJson(m);
      } catch (_) {
        return null;
      }
    }).whereType<Checkup>().toList();
  }

  Future<void> saveAll(List<Checkup> checkups) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = checkups.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }

  /// Auto-update status từ 'upcoming' → 'overdue' nếu quá hạn
  Future<void> _updateStatusIfNeeded() async {
    final all = await getAll();
    final now = DateTime.now();
    bool hasChanges = false;

    for (final checkup in all) {
      // Nếu lịch sắp tới nhưng hôm nay đã quá ngày scheduled → chuyển thành overdue
      if (checkup.status == 'upcoming' &&
          checkup.actualDate == null &&
          checkup.scheduledDate.isBefore(DateTime(now.year, now.month, now.day))) {
        checkup.status = 'overdue';
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await saveAll(all);
    }
  }

  Future<void> add(Checkup checkup) async {
    final list = await getAll();
    list.add(checkup);
    await saveAll(list);
  }

  Future<void> update(Checkup checkup) async {
    final list = await getAll();
    final idx = list.indexWhere((c) => c.id == checkup.id);
    if (idx != -1) {
      list[idx] = checkup;
      await saveAll(list);
    }
  }

  Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((c) => c.id == id);
    await saveAll(list);
  }

  // Lấy danh sách thăm khám sắp tới
  Future<List<Checkup>> getUpcoming() async {
    await _updateStatusIfNeeded(); // Auto-update status trước
    final all = await getAll();
    return all
        .where((c) => c.status == 'upcoming' && c.actualDate == null)
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  // Lấy danh sách thăm khám đã hoàn tất
  Future<List<Checkup>> getCompleted() async {
    final all = await getAll();
    return all
        .where((c) => c.status == 'completed')
        .toList()
      ..sort((a, b) => b.actualDate?.compareTo(a.actualDate ?? DateTime.now()) ?? 0);
  }

  // Lấy danh sách thăm khám quá hạn (chưa khám)
  Future<List<Checkup>> getOverdue() async {
    await _updateStatusIfNeeded(); // Auto-update status trước
    final all = await getAll();
    return all
        .where((c) => c.status == 'overdue' && c.actualDate == null)
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  // Đánh dấu thăm khám đã hoàn tất
  Future<void> markAsCompleted(String id, String result, String? notes) async {
    final list = await getAll();
    final idx = list.indexWhere((c) => c.id == id);
    if (idx != -1) {
      list[idx].status = 'completed';
      list[idx].actualDate = DateTime.now();
      list[idx].result = result;
      list[idx].notes = notes;
      await saveAll(list);
    }
  }

  // Đếm số lượng theo trạng thái
  Future<Map<String, int>> getCountByStatus() async {
    final upcoming = await getUpcoming();
    final completed = await getCompleted();
    final overdue = await getOverdue();

    return {
      'upcoming': upcoming.length,
      'completed': completed.length,
      'overdue': overdue.length,
    };
  }

  // Lấy thăm khám sắp tới nhất
  Future<Checkup?> getNextCheckup() async {
    final upcoming = await getUpcoming();
    if (upcoming.isEmpty) return null;
    return upcoming.first;
  }

  /// Kiểm tra và hiển thị thông báo cho lịch khám
  /// Được gọi khi app mở (từ CheckupListPage hoặc HomePage)
  Future<void> checkAndNotifyCheckups() async {
    final all = await getAll();
    final now = DateTime.now();

    for (final checkup in all) {
      // Nếu là lịch sắp tới (1-3 ngày) - hiển thị thông báo
      if (checkup.status == 'upcoming' || checkup.status == 'overdue') {
        final daysUntil = checkup.scheduledDate.difference(now).inDays;

        // Thông báo lịch sắp tới (1-3 ngày)
        if (daysUntil >= 1 && daysUntil <= 3 && checkup.actualDate == null) {
          final day = checkup.scheduledDate.day;
          final month = checkup.scheduledDate.month;
          final dateStr = '$day/$month';

          // Không gửi notification nữa
          return;
        }

        // Thông báo khám quá hạn (đã quá ngày nhưng chưa khám)
        if (checkup.scheduledDate.isBefore(now) &&
            checkup.status != 'completed' &&
            checkup.actualDate == null) {
          final daysOverdue = now.difference(checkup.scheduledDate).inDays;

          // Không gửi notification nữa
          return;
        }
      }
    }
  }
}

