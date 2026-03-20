import 'dart:convert';

class Doctor {
  final String id;
  String name;
  String specialty;
  String phone;
  String notes;

  Doctor({
    required this.id,
    required this.name,
    this.specialty = '',
    this.phone = '',
    this.notes = '',
  });

  factory Doctor.create({
    required String name,
    String specialty = '',
    String phone = '',
    String notes = '',
  }) {
    return Doctor(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      specialty: specialty,
      phone: phone,
      notes: notes,
    );
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'specialty': specialty,
        'phone': phone,
        'notes': notes,
      };

  @override
  String toString() => jsonEncode(toJson());
}
