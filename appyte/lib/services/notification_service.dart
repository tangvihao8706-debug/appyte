import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/checkup.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// Init notification plugin and timezone
  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings,
        onDidReceiveNotificationResponse: (response) {
      // Handle tapped notification if needed
    });
  }

  /// Schedule a notification for a Checkup
  /// Uses the checkup `id` (milliseconds string) as notification id
  static Future<void> scheduleCheckupNotification(Checkup checkup) async {
    try {
      final scheduled = checkup.scheduledDate;
      final tzScheduled = tz.TZDateTime.from(scheduled, tz.local);

      final offsets = checkup.reminderMinutesBefore.isNotEmpty
          ? checkup.reminderMinutesBefore
          : [1440]; // default 24h

      const androidDetails = AndroidNotificationDetails(
        'checkup_channel',
        'Lịch khám',
        channelDescription: 'Thông báo nhắc lịch khám/tái khám',
        importance: Importance.max,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();

      final now = tz.TZDateTime.now(tz.local);

      for (final offset in offsets) {
        tz.TZDateTime notifyTime = tzScheduled.subtract(Duration(minutes: offset));
        if (notifyTime.isBefore(now.add(const Duration(seconds: 5)))) {
          notifyTime = now.add(const Duration(seconds: 10));
        }

        final nid = _notificationIdFor(checkup.id, offset);

        await _plugin.zonedSchedule(
          nid,
          'Nhắc lịch khám',
          '${checkup.checkupType} vào ${scheduled.day}/${scheduled.month}/${scheduled.year}',
          notifyTime,
          const NotificationDetails(android: androidDetails, iOS: iosDetails),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );
      }
    } catch (e) {
      // ignore errors to avoid crash
      print('Error scheduling notification: $e');
    }
  }

  static int _notificationIdFor(String checkupId, int offsetMinutes) {
    final base = checkupId.hashCode.abs();
    return base + offsetMinutes;
  }

  /// Cancel all scheduled notifications for a checkup
  static Future<void> cancelCheckupNotifications(Checkup checkup) async {
    try {
      final offsets = checkup.reminderMinutesBefore.isNotEmpty
          ? checkup.reminderMinutesBefore
          : [1440];

      for (final offset in offsets) {
        final nid = _notificationIdFor(checkup.id, offset);
        await _plugin.cancel(nid);
      }
    } catch (e) {
      print('Error cancelling checkup notifications: $e');
    }
  }

  /// Cancel a scheduled notification by numeric id
  static Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  /// Lấy danh sách lịch khám sắp tới (1-3 ngày) + quá hạn
  static List<Checkup> getCheckupNotifications(List<Checkup> allCheckups) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notifications = <Checkup>[];

    for (final checkup in allCheckups) {
      if (checkup.actualDate != null) continue;
      if (checkup.status == 'cancelled') continue;

      final scheduledDay = DateTime(checkup.scheduledDate.year, checkup.scheduledDate.month, checkup.scheduledDate.day);
      final daysUntil = scheduledDay.difference(today).inDays;

      if (daysUntil >= 0 && daysUntil <= 3) {
        notifications.add(checkup);
      } else if (daysUntil < 0) {
        notifications.add(checkup);
      }
    }

    return notifications;
  }

  /// Hiển thị Notification Dialog với danh sách lịch khám
  static void showNotificationDialog(
    BuildContext context,
    List<Checkup>? notifications,
  ) {
    if (notifications == null || notifications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có lịch khám nào cần chú ý'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications, color: Color(0xFF1E88E5)),
            const SizedBox(width: 8),
            Text(
              'Lịch khám cần chú ý',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final checkup = notifications[index];
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final scheduledDay = DateTime(checkup.scheduledDate.year, checkup.scheduledDate.month, checkup.scheduledDate.day);
              final daysUntil = scheduledDay.difference(today).inDays;
              final isOverdue = daysUntil < 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOverdue ? Colors.red[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOverdue ? Colors.red[200]! : Colors.blue[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isOverdue ? Colors.red : Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isOverdue
                                ? '⚠️ Quá hạn ${daysUntil.abs()} ngày'
                                : '📋 Sắp tới $daysUntil ngày',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${checkup.doctorName ?? 'Bác sĩ'} - ${checkup.hospitalName ?? 'Bệnh viện'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ngày khám: ${checkup.scheduledDate.day}/${checkup.scheduledDate.month}/${checkup.scheduledDate.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    if (checkup.checkupType.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Loại khám: ${checkup.checkupType}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

