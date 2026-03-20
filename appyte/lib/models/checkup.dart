import 'dart:convert';

class Checkup {
  final String id;
  String checkupType; // Loại khám: "Khám tổng quát", "Khám chuyên khoa", "Tái khám"
  String? checkupMode; // Hình thức: "Một lần", "Theo dõi", "Định kỳ"
  String reason; // Lý do khám
  String symptom; // Triệu chứng
  DateTime scheduledDate; // Ngày khám dự kiến
  String? doctorId; // Liên kết bác sĩ
  String? doctorName; // Tên bác sĩ
  String? hospitalId; // Liên kết bệnh viện
  String? hospitalName; // Tên bệnh viện
  String status; // "upcoming", "completed", "overdue", "cancelled"
  DateTime? actualDate; // Ngày khám thực tế
  String? result; // Kết quả khám
  String? notes; // Ghi chú sau khám
  List<int> reminderMinutesBefore; // danh sách số phút trước thời điểm khám để nhắc
  DateTime createdDate;

  Checkup({
    required this.id,
    required this.checkupType,
    this.checkupMode,
    required this.reason,
    required this.symptom,
    required this.scheduledDate,
    this.doctorId,
    this.doctorName,
    this.hospitalId,
    this.hospitalName,
    required this.status,
    this.actualDate,
    this.result,
    this.notes,
    required this.reminderMinutesBefore,
    required this.createdDate,
  });

  factory Checkup.create({
    required String checkupType,
    String? checkupMode,
    required String reason,
    required String symptom,
    required DateTime scheduledDate,
    String? doctorId,
    String? doctorName,
    String? hospitalId,
    String? hospitalName,
    List<int>? reminderMinutesBefore,
  }) {
    final now = DateTime.now();
    String status = 'upcoming';
    if (scheduledDate.isBefore(now)) {
      status = 'overdue';
    }

    return Checkup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      checkupType: checkupType,
      checkupMode: checkupMode,
      reason: reason,
      symptom: symptom,
      scheduledDate: scheduledDate,
      doctorId: doctorId,
      doctorName: doctorName,
      hospitalId: hospitalId,
      hospitalName: hospitalName,
      status: status,
      reminderMinutesBefore: reminderMinutesBefore ?? [],
      createdDate: now,
    );
  }

  factory Checkup.fromJson(Map<String, dynamic> json) {
    return Checkup(
      id: json['id'] as String,
      checkupType: json['checkupType'] as String? ?? '',
      checkupMode: json['checkupMode'] as String?,
      reason: json['reason'] as String? ?? '',
      symptom: json['symptom'] as String? ?? '',
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      doctorId: json['doctorId'] as String?,
      doctorName: json['doctorName'] as String?,
      hospitalId: json['hospitalId'] as String?,
      hospitalName: json['hospitalName'] as String?,
      status: json['status'] as String? ?? 'upcoming',
      actualDate: json['actualDate'] != null
          ? DateTime.parse(json['actualDate'] as String)
          : null,
      result: json['result'] as String?,
      notes: json['notes'] as String?,
      reminderMinutesBefore: (json['reminderMinutesBefore'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      createdDate: DateTime.parse(json['createdDate'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'checkupType': checkupType,
        'checkupMode': checkupMode,
        'reason': reason,
        'symptom': symptom,
        'scheduledDate': scheduledDate.toIso8601String(),
        'doctorId': doctorId,
        'doctorName': doctorName,
        'hospitalId': hospitalId,
        'hospitalName': hospitalName,
        'status': status,
        'actualDate': actualDate?.toIso8601String(),
        'result': result,
        'notes': notes,
        'reminderMinutesBefore': reminderMinutesBefore,
        'createdDate': createdDate.toIso8601String(),
      };

  @override
  String toString() => jsonEncode(toJson());

  // Helper method để cập nhật status dựa vào ngày
  void updateStatus() {
    final now = DateTime.now();
    if (status == 'completed') return; // Không thay đổi nếu đã hoàn tất
    if (status == 'cancelled') return; // Không thay đổi nếu đã hủy

    if (scheduledDate.isBefore(now) && status != 'completed') {
      status = 'overdue';
    } else if (scheduledDate.isAfter(now) || scheduledDate.difference(now).inHours >= 0) {
      status = 'upcoming';
    }
  }
}
