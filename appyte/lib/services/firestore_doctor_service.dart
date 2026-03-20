import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor.dart';

class FirestoreDoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'doctors';

  /// Lấy tất cả bác sĩ của user
  Future<List<Doctor>> getAll(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => Doctor.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }

  /// Thêm bác sĩ mới
  Future<String> add(String userId, Doctor doctor) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        ...doctor.toJson(),
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error adding doctor: $e');
      rethrow;
    }
  }

  /// Cập nhật bác sĩ
  Future<void> update(String doctorId, Doctor doctor) async {
    try {
      await _firestore.collection(_collection).doc(doctorId).update({
        ...doctor.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating doctor: $e');
      rethrow;
    }
  }

  /// Xóa bác sĩ
  Future<void> delete(String doctorId) async {
    try {
      await _firestore.collection(_collection).doc(doctorId).delete();
    } catch (e) {
      print('Error deleting doctor: $e');
      rethrow;
    }
  }

  /// Real-time stream để lắng nghe thay đổi
  Stream<List<Doctor>> streamAll(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Doctor.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}
