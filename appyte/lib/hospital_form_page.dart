import 'package:flutter/material.dart';

import 'models/hospital.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_hospital_service.dart';

class HospitalFormPage extends StatefulWidget {
  final Hospital? initial;

  const HospitalFormPage({super.key, this.initial});

  @override
  State<HospitalFormPage> createState() => _HospitalFormPageState();
}

class _HospitalFormPageState extends State<HospitalFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _notesCtrl;
  bool _isLoading = false;

  final _authService = FirebaseAuthService();
  final _hospitalService = FirestoreHospitalService();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
    _addressCtrl = TextEditingController(text: widget.initial?.address ?? '');
    _phoneCtrl = TextEditingController(text: widget.initial?.phone ?? '');
    _notesCtrl = TextEditingController(text: widget.initial?.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập trước')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final item = Hospital(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );

    _saveToFirestore(userId, item);
  }

  Future<void> _saveToFirestore(String userId, Hospital hospital) async {
    try {
      if (widget.initial != null) {
        // Update existing
        await _hospitalService.update(widget.initial!.id, hospital);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật bệnh viện thành công')),
        );
      } else {
        // Create new
        await _hospitalService.add(userId, hospital);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm bệnh viện thành công')),
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error saving hospital: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'Thêm bệnh viện' : 'Sửa bệnh viện'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _onSave,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Text('Lưu', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên bệnh viện'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên bệnh viện' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Ghi chú'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
