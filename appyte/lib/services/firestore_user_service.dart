import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class FirestoreUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  /// Lấy user theo ID
  Future<AppUser?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists) {
        return AppUser.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Cập nhật user profile
  Future<void> updateUser(String userId, AppUser user) async {
    try {
      await _firestore.collection(_collection).doc(userId).update(user.toJson());
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  /// Cập nhật role của user
  Future<void> updateRole(String userId, String role) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'role': role,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating role: $e');
      rethrow;
    }
  }

  /// Thêm permission cho user
  Future<void> addPermission(String userId, String permission) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'permissions': FieldValue.arrayUnion([permission]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding permission: $e');
      rethrow;
    }
  }

  /// Xóa permission từ user
  Future<void> removePermission(String userId, String permission) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'permissions': FieldValue.arrayRemove([permission]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error removing permission: $e');
      rethrow;
    }
  }

  /// Stream để lắng nghe user thay đổi
  Stream<AppUser?> streamUser(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return AppUser.fromJson({...snapshot.data()!, 'id': snapshot.id});
      }
      return null;
    });
  }
}
