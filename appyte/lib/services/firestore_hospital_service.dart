import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hospital.dart';

class FirestoreHospitalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'hospitals';

  /// Lấy tất cả bệnh viện của user
  Future<List<Hospital>> getAll(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => Hospital.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching hospitals: $e');
      return [];
    }
  }

  /// Thêm bệnh viện mới
  Future<String> add(String userId, Hospital hospital) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        ...hospital.toJson(),
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error adding hospital: $e');
      rethrow;
    }
  }

  /// Cập nhật bệnh viện
  Future<void> update(String hospitalId, Hospital hospital) async {
    try {
      await _firestore.collection(_collection).doc(hospitalId).update({
        ...hospital.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating hospital: $e');
      rethrow;
    }
  }

  /// Xóa bệnh viện
  Future<void> delete(String hospitalId) async {
    try {
      await _firestore.collection(_collection).doc(hospitalId).delete();
    } catch (e) {
      print('Error deleting hospital: $e');
      rethrow;
    }
  }

  /// Real-time stream để lắng nghe thay đổi
  Stream<List<Hospital>> streamAll(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Hospital.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}
