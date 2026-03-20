import 'package:flutter/material.dart';

import 'models/doctor.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_doctor_service.dart';

class DoctorFormPage extends StatefulWidget {
  final Doctor? initial;

  const DoctorFormPage({super.key, this.initial});

  @override
  State<DoctorFormPage> createState() => _DoctorFormPageState();
}

class _DoctorFormPageState extends State<DoctorFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _specialtyCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _notesCtrl;
  bool _isLoading = false;

  final _authService = FirebaseAuthService();
  final _doctorService = FirestoreDoctorService();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
    _specialtyCtrl = TextEditingController(text: widget.initial?.specialty ?? '');
    _phoneCtrl = TextEditingController(text: widget.initial?.phone ?? '');
    _notesCtrl = TextEditingController(text: widget.initial?.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _specialtyCtrl.dispose();
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

    final doc = Doctor(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      specialty: _specialtyCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );

    _saveToFirestore(userId, doc);
  }

  Future<void> _saveToFirestore(String userId, Doctor doctor) async {
    try {
      if (widget.initial != null) {
        // Update existing
        await _doctorService.update(widget.initial!.id, doctor);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật bác sĩ thành công')),
        );
      } else {
        // Create new
        await _doctorService.add(userId, doctor);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm bác sĩ thành công')),
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error saving doctor: $e');
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
        title: Text(widget.initial == null ? 'Thêm bác sĩ' : 'Sửa bác sĩ'),
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
                decoration: const InputDecoration(labelText: 'Tên bác sĩ'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên bác sĩ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _specialtyCtrl,
                decoration: const InputDecoration(labelText: 'Chuyên khoa'),
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
