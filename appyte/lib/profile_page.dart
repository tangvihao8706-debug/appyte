import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'services/firebase_auth_service.dart';

class ProfilePage extends StatefulWidget {
  final GoogleSignInAccount? user;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;

  const ProfilePage({
    super.key,
    required this.user,
    required this.onSignIn,
    required this.onSignOut,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = FirebaseAuthService();
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signOut();
      if (mounted) {
        widget.onSignOut();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: widget.user != null ? _buildLoggedIn() : _buildLoggedOut(),
    );
  }

  Widget _buildLoggedIn() {
    final currentUser = _authService.getCurrentFirebaseUser();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blue[50],
          child: currentUser?.photoURL != null
              ? ClipOval(
                  child: Image.network(
                    currentUser!.photoURL!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 50),
                  ),
                )
              : const Icon(Icons.person, size: 50),
        ),
        const SizedBox(height: 15),
        Text(
          currentUser?.displayName ?? widget.user?.displayName ?? 'User',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(currentUser?.email ?? widget.user?.email ?? ''),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _handleLogout,
          icon: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout),
          label: const Text("Đăng xuất"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[50],
            foregroundColor: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedOut() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.account_circle, size: 100, color: Colors.grey),
        const SizedBox(height: 10),
        const Text(
          "Đăng nhập để quản lý sức khỏe của bạn.",
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: widget.onSignIn,
          icon: const Icon(Icons.login),
          label: const Text("Đăng nhập"),
        ),
      ],
    );
  }
}