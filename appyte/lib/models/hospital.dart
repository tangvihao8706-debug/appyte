import 'dart:convert';

class Hospital {
  final String id;
  String name;
  String address;
  String phone;
  String notes;

  Hospital({
    required this.id,
    required this.name,
    this.address = '',
    this.phone = '',
    this.notes = '',
  });

  factory Hospital.create({
    required String name,
    String address = '',
    String phone = '',
    String notes = '',
  }) {
    return Hospital(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      address: address,
      phone: phone,
      notes: notes,
    );
  }

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'phone': phone,
        'notes': notes,
      };

  @override
  String toString() => jsonEncode(toJson());
}
