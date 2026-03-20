import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class FirebaseUserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  /// Lấy user hiện tại
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Đăng ký tài khoản
  Future<AppUser> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Tạo user trong Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cập nhật display name
      await userCredential.user?.updateDisplayName(displayName);

      // Tạo document user trong Firestore
      final appUser = AppUser(
        id: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        photoUrl: null,
        role: 'user',
        permissions: [],
        isActive: true,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestore.collection(_collection).doc(appUser.id).set(appUser.toJson());

      return appUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Mật khẩu quá yếu. Vui lòng sử dụng mật khẩu mạnh hơn.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Email này đã được sử dụng.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Email không hợp lệ.');
      }
      rethrow;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  /// Đăng nhập
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cập nhật lastLoginAt
      await _firestore
          .collection(_collection)
          .doc(userCredential.user!.uid)
          .update({'lastLoginAt': FieldValue.serverTimestamp()});

      // Lấy thông tin user
      return await getUserById(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Email này chưa được đăng ký.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Mật khẩu không chính xác.');
      } else if (e.code == 'invalid-credential') {
        throw Exception('Email hoặc mật khẩu không chính xác.');
      }
      rethrow;
    } catch (e) {
      print('Error logging in: $e');
      rethrow;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error logging out: $e');
      rethrow;
    }
  }

  /// Lấy thông tin user theo ID
  Future<AppUser> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();

      if (!doc.exists) {
        throw Exception('User không tồn tại.');
      }

      return AppUser.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('Error fetching user: $e');
      rethrow;
    }
  }

  /// Stream để lắng nghe thay đổi user
  Stream<AppUser?> streamCurrentUser() {
    return _auth.authStateChanges().asyncExpand((User? user) async* {
      if (user == null) {
        yield null;
      } else {
        try {
          final appUser = await getUserById(user.uid);
          yield appUser;
        } catch (e) {
          print('Error streaming user: $e');
          yield null;
        }
      }
    });
  }

  /// Cập nhật profil user
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(_collection).doc(userId).update(updates);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  /// Đổi mật khẩu
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User không được tìm thấy.');

      // Xác thực lại với mật khẩu cũ
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Đổi mật khẩu
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Mật khẩu cũ không chính xác.');
      } else if (e.code == 'weak-password') {
        throw Exception('Mật khẩu mới quá yếu.');
      }
      rethrow;
    } catch (e) {
      print('Error changing password: $e');
      rethrow;
    }
  }

  /// Reset mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }
  /// Đăng nhập bằng Google
  Future<AppUser> signInWithGoogle(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase Auth
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Kiểm tra xem user đã tồn tại trong Firestore chưa
      final doc = await _firestore.collection(_collection).doc(user.uid).get();

      if (!doc.exists) {
        // Nếu chưa có thì tạo mới (giống hàm signup của ông)
        final appUser = AppUser(
          id: user.uid,
          email: user.email!,
          displayName: user.displayName ?? 'Người dùng',
          photoUrl: user.photoURL,
          role: 'user',
          permissions: [],
          isActive: true,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _firestore.collection(_collection).doc(appUser.id).set(appUser.toJson());
        return appUser;
      } else {
        // Nếu có rồi thì cập nhật giờ đăng nhập
        await _firestore.collection(_collection).doc(user.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        return await getUserById(user.uid);
      }
    } catch (e) {
      print('Lỗi đăng nhập Google: $e');
      rethrow;
    }
  }
}
