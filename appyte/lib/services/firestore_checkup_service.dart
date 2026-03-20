import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/checkup.dart';

class FirestoreCheckupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'checkups';

  /// Lấy tất cả thăm khám của user
  Future<List<Checkup>> getAll(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => Checkup.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching checkups: $e');
      return [];
    }
  }

  /// Lấy danh sách thăm khám sắp tới
  Future<List<Checkup>> getUpcoming(String userId) async {
    try {
      // Chỉ query userId + orderBy - không cần index
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('scheduledDate', descending: false)
          .get();

      // Filter ở client-side
      return snapshot.docs
          .map((doc) => Checkup.fromJson({...doc.data(), 'id': doc.id}))
          .where((c) => c.status == 'upcoming')
          .toList();
    } catch (e) {
      print('Error fetching upcoming checkups: $e');
      return [];
    }
  }

  /// Lấy danh sách thăm khám đã hoàn tất
  Future<List<Checkup>> getCompleted(String userId) async {
    try {
      // Chỉ query userId - không cần index
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      // Filter + sort ở client-side
      return snapshot.docs
          .map((doc) => Checkup.fromJson({...doc.data(), 'id': doc.id}))
          .where((c) => c.status == 'completed')
          .toList()
        ..sort((a, b) => (b.actualDate ?? DateTime.now()).compareTo(a.actualDate ?? DateTime.now()));
    } catch (e) {
      print('Error fetching completed checkups: $e');
      return [];
    }
  }

  /// Lấy danh sách thăm khám quá hạn
  Future<List<Checkup>> getOverdue(String userId) async {
    try {
      // Chỉ query userId - không cần index
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      // Filter + sort ở client-side
      return snapshot.docs
          .map((doc) => Checkup.fromJson({...doc.data(), 'id': doc.id}))
          .where((c) => c.status == 'overdue')
          .toList()
        ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
    } catch (e) {
      print('Error fetching overdue checkups: $e');
      return [];
    }
  }

  /// Thêm thăm khám mới
  Future<String> add(String userId, Checkup checkup) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        ...checkup.toJson(),
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error adding checkup: $e');
      rethrow;
    }
  }

  /// Cập nhật thăm khám
  Future<void> update(String checkupId, Checkup checkup) async {
    try {
      await _firestore.collection(_collection).doc(checkupId).update({
        ...checkup.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating checkup: $e');
      rethrow;
    }
  }

  /// Xóa thăm khám
  Future<void> delete(String checkupId) async {
    try {
      await _firestore.collection(_collection).doc(checkupId).delete();
    } catch (e) {
      print('Error deleting checkup: $e');
      rethrow;
    }
  }

  /// Real-time stream để lắng nghe thay đổi (không dùng orderBy để tránh cần index)
  Stream<List<Checkup>> streamAll(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final checkups = snapshot.docs
              .map((doc) => Checkup.fromJson({...doc.data(), 'id': doc.id}))
              .toList();
          // Sort ở client-side thay vì server-side
          checkups.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
          return checkups;
        });
  }
}
