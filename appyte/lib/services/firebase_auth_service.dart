import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy user ID hiện tại
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Lấy user object hiện tại
  User? getCurrentFirebaseUser() {
    return _auth.currentUser;
  }

  /// Stream để lắng nghe thay đổi auth state
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  /// Đăng ký (tạo account mới)
  Future<AppUser?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('User creation failed');

      // Cập nhật displayName
      await user.updateDisplayName(displayName);

      // Tạo user document trong Firestore
      final appUser = AppUser(
        id: user.uid,
        email: email,
        displayName: displayName,
        photoUrl: user.photoURL,
        role: 'user',
        permissions: ['view_checkups', 'add_medicines', 'view_doctors', 'view_hospitals'],
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(appUser.toJson());

      return appUser;
    } on FirebaseAuthException catch (e) {
      print('SignUp Error: ${e.message}');
      rethrow;
    }
  }

  /// Đăng nhập
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('SignIn failed');

      // Cập nhật lastLoginAt
      await _firestore.collection('users').doc(user.uid).update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });

      // Lấy user data từ Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return AppUser.fromJson({...doc.data()!, 'id': doc.id});
      }

      return null;
    } on FirebaseAuthException catch (e) {
      print('SignIn Error: ${e.message}');
      rethrow;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('SignOut Error: $e');
      rethrow;
    }
  }

  /// Lấy AppUser data từ Firestore
  Future<AppUser?> getAppUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return AppUser.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Get AppUser Error: $e');
      return null;
    }
  }

  /// Stream để lắng nghe user data thay đổi
  Stream<AppUser?> streamAppUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return AppUser.fromJson({...snapshot.data()!, 'id': snapshot.id});
      }
      return null;
    });
  }

  /// Kiểm tra user đã login hay chưa
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Reset Password Error: ${e.message}');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Cập nhật trong Firestore
      await _firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Update Profile Error: $e');
      rethrow;
    }
  }
}
