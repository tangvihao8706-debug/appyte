import 'dart:async';
import 'package:flutter/material.dart';

import 'models/doctor.dart';
import 'services/firestore_doctor_service.dart';
import 'services/firebase_auth_service.dart';
import 'doctor_form_page.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final _service = FirestoreDoctorService();
  final _authService = FirebaseAuthService();
  List<Doctor> _doctors = [];
  String _keyword = '';
  late StreamSubscription<List<Doctor>> _doctorSubscription;

  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  @override
  void dispose() {
    _doctorSubscription.cancel();
    super.dispose();
  }

  void _setupStream() {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập trước')),
      );
      return;
    }

    // Real-time stream từ Firestore với timeout
    _doctorSubscription = _service.streamAll(userId).timeout(
      const Duration(seconds: 10),
      onTimeout: (sink) {
        print('Doctor stream timeout');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kết nối timeout')),
          );
        }
        sink.close();
      },
    ).listen(
      (doctors) {
        if (mounted) {
          setState(() => _doctors = doctors);
        }
      },
      onError: (e) {
        print('Error loading doctors: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${e.toString()}')),
          );
        }
      },
      onDone: () {
        print('Doctor stream closed');
      },
    );
  }

  Future<void> _onAdd() async {
    final result = await Navigator.push<Doctor>(context, MaterialPageRoute(builder: (_) => const DoctorFormPage()));
    if (result != null) {
      // Form đã lưu vào Firestore, list sẽ tự update qua stream
      // Không cần gọi _load() nữa
    }
  }

  Future<void> _onEdit(Doctor d) async {
    final result = await Navigator.push<Doctor>(context, MaterialPageRoute(builder: (_) => DoctorFormPage(initial: d)));
    if (result != null) {
      // Form đã cập nhật vào Firestore, list sẽ tự update qua stream
    }
  }

  Future<void> _onDelete(Doctor d) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Xoá bác sĩ'),
            content: const Text('Bạn có chắc muốn xoá bác sĩ này?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')),
              TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Xoá')),
            ],
          ),
        ) ??
        false;
    if (ok) {
      try {
        await _service.delete(d.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xoá bác sĩ')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _doctors.where((d) => d.name.toLowerCase().contains(_keyword.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bác sĩ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(onPressed: _onAdd, icon: const Icon(Icons.add, color: Colors.black))
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bác sĩ...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => _keyword = v),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Chưa có bác sĩ', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final d = filtered[index];
                      return Dismissible(
                        key: Key(d.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _onDelete(d),
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.blue),
                          title: Text(d.name),
                          subtitle: Text(d.specialty.isNotEmpty ? '${d.specialty} • ${d.phone}' : d.phone),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') _onEdit(d);
                              if (v == 'delete') _onDelete(d);
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                              const PopupMenuItem(value: 'delete', child: Text('Xoá')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
