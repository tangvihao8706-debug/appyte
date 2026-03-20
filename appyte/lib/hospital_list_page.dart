import 'dart:async';
import 'package:flutter/material.dart';

import 'models/hospital.dart';
import 'services/firestore_hospital_service.dart';
import 'services/firebase_auth_service.dart';
import 'hospital_form_page.dart';

class HospitalListPage extends StatefulWidget {
  const HospitalListPage({super.key});

  @override
  State<HospitalListPage> createState() => _HospitalListPageState();
}

class _HospitalListPageState extends State<HospitalListPage> {
  final _service = FirestoreHospitalService();
  final _authService = FirebaseAuthService();
  List<Hospital> _items = [];
  String _keyword = '';
  late StreamSubscription<List<Hospital>> _hospitalSubscription;

  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  @override
  void dispose() {
    _hospitalSubscription.cancel();
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
    _hospitalSubscription = _service.streamAll(userId).timeout(
      const Duration(seconds: 10),
      onTimeout: (sink) {
        print('Hospital stream timeout');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kết nối timeout')),
          );
        }
        sink.close();
      },
    ).listen(
      (hospitals) {
        if (mounted) {
          setState(() => _items = hospitals);
        }
      },
      onError: (e) {
        print('Error loading hospitals: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${e.toString()}')),
          );
        }
      },
      onDone: () {
        print('Hospital stream closed');
      },
    );
  }

  Future<void> _onAdd() async {
    final result = await Navigator.push<Hospital>(context, MaterialPageRoute(builder: (_) => const HospitalFormPage()));
    if (result != null) {
      // Form đã lưu vào Firestore, list sẽ tự update qua stream
    }
  }

  Future<void> _onEdit(Hospital h) async {
    final result = await Navigator.push<Hospital>(context, MaterialPageRoute(builder: (_) => HospitalFormPage(initial: h)));
    if (result != null) {
      // Form đã cập nhật vào Firestore, list sẽ tự update qua stream
    }
  }

  Future<void> _onDelete(Hospital h) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Xoá bệnh viện'),
            content: const Text('Bạn có chắc muốn xoá bệnh viện này?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')),
              TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Xoá')),
            ],
          ),
        ) ??
        false;
    if (ok) {
      try {
        await _service.delete(h.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã xoá "${h.name}"')),
          );
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
    final filtered = _items.where((d) => d.name.toLowerCase().contains(_keyword.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bệnh viện'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm bệnh viện...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _keyword.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _keyword = ''),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => _keyword = v),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.local_hospital, size: 56, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Chưa có bệnh viện', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final d = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: const Icon(Icons.local_hospital, color: Colors.blue),
                          ),
                          title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(d.address.isNotEmpty ? '${d.address}\n${d.phone}' : d.phone, maxLines: 2),
                          isThreeLine: d.address.isNotEmpty,
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
                          onTap: () => _onEdit(d),
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
