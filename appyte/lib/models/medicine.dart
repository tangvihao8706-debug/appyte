import 'dart:convert';

class Medicine {
  final String id;
  String name;
  String dosage;
  String time; // simple text like "08:00"
  String notes;

  Medicine({
    required this.id,
    required this.name,
    this.dosage = '',
    this.time = '',
    this.notes = '',
  });

  factory Medicine.create({
    required String name,
    String dosage = '',
    String time = '',
    String notes = '',
  }) {
    return Medicine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      dosage: dosage,
      time: time,
      notes: notes,
    );
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String? ?? '',
      time: json['time'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'time': time,
        'notes': notes,
      };

  @override
  String toString() => jsonEncode(toJson());
}
