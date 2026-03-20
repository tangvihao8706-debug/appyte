import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine.dart';

class FirestoreMedicineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'medicines';

  /// Lấy tất cả thuốc của user
  Future<List<Medicine>> getAll(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => Medicine.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching medicines: $e');
      return [];
    }
  }

  /// Thêm thuốc mới
  Future<String> add(String userId, Medicine medicine) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        ...medicine.toJson(),
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error adding medicine: $e');
      rethrow;
    }
  }

  /// Cập nhật thuốc
  Future<void> update(String medicineId, Medicine medicine) async {
    try {
      await _firestore.collection(_collection).doc(medicineId).update({
        ...medicine.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating medicine: $e');
      rethrow;
    }
  }

  /// Xóa thuốc
  Future<void> delete(String medicineId) async {
    try {
      await _firestore.collection(_collection).doc(medicineId).delete();
    } catch (e) {
      print('Error deleting medicine: $e');
      rethrow;
    }
  }

  /// Real-time stream để lắng nghe thay đổi
  Stream<List<Medicine>> streamAll(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medicine.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}
