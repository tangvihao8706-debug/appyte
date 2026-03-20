import 'dart:convert';

class AppUser {
  final String id;
  String email;
  String displayName;
  String? photoUrl;
  String role; // "user", "doctor", "admin"
  List<String> permissions; // ["view_checkups", "edit_medicines", ...]
  bool isActive;
  DateTime createdAt;
  DateTime? lastLoginAt;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.role = 'user',
    this.permissions = const [],
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      role: json['role'] as String? ?? 'user',
      permissions: List<String>.from(json['permissions'] as List? ?? []),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'role': role,
    'permissions': permissions,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'lastLoginAt': lastLoginAt?.toIso8601String(),
  };

  @override
  String toString() => jsonEncode(toJson());

  /// Kiểm tra quyền
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  /// Kiểm tra role
  bool hasRole(String requiredRole) {
    return role == requiredRole;
  }
}
