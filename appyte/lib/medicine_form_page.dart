import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/medicine.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_medicine_service.dart';


class MedicineFormPage extends StatefulWidget {
  final Medicine? initial;

  const MedicineFormPage({super.key, this.initial});

  @override
  State<MedicineFormPage> createState() => _MedicineFormPageState();
}

class _MedicineFormPageState extends State<MedicineFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _dosageCtrl;
  late TextEditingController _timeCtrl;
  late TextEditingController _notesCtrl;
  bool _isLoading = false;

  final _authService = FirebaseAuthService();
  final _medicineService = FirestoreMedicineService();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
    _dosageCtrl = TextEditingController(text: widget.initial?.dosage ?? '');
    _timeCtrl = TextEditingController(text: widget.initial?.time ?? '');
    _notesCtrl = TextEditingController(text: widget.initial?.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _timeCtrl.dispose();
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

    final med = Medicine(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim(),
      time: _timeCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );

    _saveToFirestore(userId, med);
  }

  Future<void> _saveToFirestore(String userId, Medicine medicine) async {
    try {
      if (widget.initial != null) {
        // Update existing
        await _medicineService.update(widget.initial!.id, medicine);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thuốc thành công')),
        );
      } else {
        // Create new
        await _medicineService.add(userId, medicine);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm thuốc thành công')),
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error saving medicine: $e');
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
        title: Text(widget.initial == null ? 'Thêm thuốc' : 'Sửa thuốc'),
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
                decoration: const InputDecoration(labelText: 'Tên thuốc'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên thuốc' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dosageCtrl,
                decoration: const InputDecoration(labelText: 'Liều lượng (vd: 500mg)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeCtrl,
                decoration: const InputDecoration(labelText: 'Giờ uống (vd: 08:00 sáng)'),
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
