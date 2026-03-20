import 'package:flutter/material.dart';

import 'models/checkup.dart';
import 'models/doctor.dart';
import 'models/hospital.dart';
import 'services/doctor_service.dart';
import 'services/hospital_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_checkup_service.dart';
import 'services/firestore_doctor_service.dart';
import 'services/firestore_hospital_service.dart';

class CheckupFormPage extends StatefulWidget {
  final Checkup? initial;

  const CheckupFormPage({super.key, this.initial});

  @override
  State<CheckupFormPage> createState() => _CheckupFormPageState();
}

class _CheckupFormPageState extends State<CheckupFormPage> {
  late TextEditingController _reasonController;
  late TextEditingController _symptomController;
  late String _selectedCheckupType;
  String? _selectedCheckupMode;
  late DateTime _selectedDate;
  String? _selectedDoctorId;
  String? _selectedDoctorName;
  String? _selectedHospitalId;
  String? _selectedHospitalName;
  final Set<int> _selectedReminders = {};
  final TextEditingController _customReminderController = TextEditingController();

  List<Doctor> _doctors = [];
  List<Hospital> _hospitals = [];
  bool _isLoading = false;

  final _authService = FirebaseAuthService();
  final _checkupService = FirestoreCheckupService();
  final _doctorService = FirestoreDoctorService();
  final _hospitalService = FirestoreHospitalService();

  final List<String> _checkupTypes = [
    'Khám tổng quát',
    'Khám chuyên khoa',
    'Tái khám',
  ];

  final List<String> _checkupModes = [
    'Một lần',
    'Theo dõi',
    'Định kỳ',
  ];

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(
      text: widget.initial?.reason ?? '',
    );
    _symptomController = TextEditingController(
      text: widget.initial?.symptom ?? '',
    );
    _selectedCheckupType = widget.initial?.checkupType ?? 'Khám tổng quát';
    _selectedCheckupMode = widget.initial?.checkupMode;
    _selectedDate = widget.initial?.scheduledDate ?? DateTime.now();
    _selectedDoctorId = widget.initial?.doctorId;
    _selectedDoctorName = widget.initial?.doctorName;
    _selectedHospitalId = widget.initial?.hospitalId;
    _selectedHospitalName = widget.initial?.hospitalName;
    if (widget.initial?.reminderMinutesBefore != null) {
      _selectedReminders.addAll(widget.initial!.reminderMinutesBefore);
    }

    _loadDoctorsAndHospitals();
  }

  Future<void> _loadDoctorsAndHospitals() async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập trước')),
      );
      return;
    }

    try {
      final doctors = await _doctorService.getAll(userId);
      final hospitals = await _hospitalService.getAll(userId);

      setState(() {
        _doctors = doctors;
        _hospitals = hospitals;
      });
    } catch (e) {
      print('Error loading doctors/hospitals: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi tải dữ liệu')),
      );
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _symptomController.dispose();
    _customReminderController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _selectDoctor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn bác sĩ'),
        content: SizedBox(
          width: double.maxFinite,
          child: _doctors.isEmpty
              ? const Center(
                  child: Text('Chưa có bác sĩ nào. Vui lòng thêm bác sĩ trước.'),
                )
              : ListView.builder(
                  itemCount: _doctors.length,
                  itemBuilder: (context, index) {
                    final doc = _doctors[index];
                    return ListTile(
                      title: Text(doc.name),
                      subtitle: Text(doc.specialty),
                      onTap: () {
                        setState(() {
                          _selectedDoctorId = doc.id;
                          _selectedDoctorName = doc.name;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _selectHospital() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn bệnh viện'),
        content: SizedBox(
          width: double.maxFinite,
          child: _hospitals.isEmpty
              ? const Center(
                  child: Text('Chưa có bệnh viện nào. Vui lòng thêm bệnh viện trước.'),
                )
              : ListView.builder(
                  itemCount: _hospitals.length,
                  itemBuilder: (context, index) {
                    final hos = _hospitals[index];
                    return ListTile(
                      title: Text(hos.name),
                      subtitle: Text(hos.address),
                      onTap: () {
                        setState(() {
                          _selectedHospitalId = hos.id;
                          _selectedHospitalName = hos.name;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  bool _validate() {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập lý do khám')),
      );
      return false;
    }

    if (_symptomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập triệu chứng')),
      );
      return false;
    }

    return true;
  }

  void _submit() {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập trước')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final checkup = Checkup(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      checkupType: _selectedCheckupType,
      checkupMode: _selectedCheckupMode,
      reason: _reasonController.text,
      symptom: _symptomController.text,
      scheduledDate: _selectedDate,
      doctorId: _selectedDoctorId,
      doctorName: _selectedDoctorName,
      hospitalId: _selectedHospitalId,
      hospitalName: _selectedHospitalName,
      status: widget.initial?.status ?? 'upcoming',
      actualDate: widget.initial?.actualDate,
      result: widget.initial?.result,
      notes: widget.initial?.notes,
      reminderMinutesBefore: _selectedReminders.toList(),
      createdDate: widget.initial?.createdDate ?? DateTime.now(),
    );

    _saveToFirestore(userId, checkup);
  }

  Future<void> _saveToFirestore(String userId, Checkup checkup) async {
    try {
      if (widget.initial != null) {
        // Update existing
        await _checkupService.update(widget.initial!.id, checkup);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật lịch khám thành công')),
        );
      } else {
        // Create new
        await _checkupService.add(userId, checkup);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm lịch khám thành công')),
        );
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error saving checkup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildReminderOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Tuỳ chọn nhắc'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('24 giờ trước'),
              selected: _selectedReminders.contains(1440),
              onSelected: (v) {
                setState(() {
                  if (v) _selectedReminders.add(1440); else _selectedReminders.remove(1440);
                });
              },
            ),
            FilterChip(
              label: const Text('1 giờ trước'),
              selected: _selectedReminders.contains(60),
              onSelected: (v) {
                setState(() {
                  if (v) _selectedReminders.add(60); else _selectedReminders.remove(60);
                });
              },
            ),
            FilterChip(
              label: const Text('Tại thời điểm'),
              selected: _selectedReminders.contains(0),
              onSelected: (v) {
                setState(() {
                  if (v) _selectedReminders.add(0); else _selectedReminders.remove(0);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customReminderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Nhập phút trước (ví dụ: 30)',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final txt = _customReminderController.text.trim();
                if (txt.isEmpty) return;
                final m = int.tryParse(txt);
                if (m == null) return;
                setState(() {
                  _selectedReminders.add(m);
                  _customReminderController.clear();
                });
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
        if (_selectedReminders.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _selectedReminders.map((m) {
              return InputChip(
                label: Text(m == 0 ? 'Tại thời điểm' : '${m} phút trước'),
                onDeleted: () {
                  setState(() => _selectedReminders.remove(m));
                },
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day;
    final month = date.month;
    final year = date.year;
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.initial != null ? 'Sửa lịch khám' : 'Thêm lịch khám',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loại khám
            _buildLabel('Loại khám'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButton<String>(
                value: _selectedCheckupType,
                isExpanded: true,
                underline: const SizedBox(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                items: _checkupTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCheckupType = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            // Hình thức khám
            _buildLabel('Hình thức khám (Tuỳ chọn)'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButton<String?>(
                value: _selectedCheckupMode,
                isExpanded: true,
                underline: const SizedBox(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Chọn hình thức'),
                  ),
                  ..._checkupModes.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() => _selectedCheckupMode = value);
                },
              ),
            ),
            const SizedBox(height: 20),

            // Lý do khám
            _buildLabel('Lý do khám'),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'Nhập lý do khám',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Triệu chứng
            _buildLabel('Triệu chứng'),
            const SizedBox(height: 8),
            TextField(
              controller: _symptomController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Mô tả triệu chứng',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Ngày khám
            _buildLabel('Ngày khám'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF1E88E5)),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bác sĩ
            _buildLabel('Bác sĩ (Tuỳ chọn)'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDoctor,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFF1E88E5)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDoctorName ?? 'Chọn bác sĩ',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDoctorName != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tuỳ chọn nhắc
            _buildReminderOptions(),
            const SizedBox(height: 20),

            // Bệnh viện
            _buildLabel('Bệnh viện (Tuỳ chọn)'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectHospital,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_hospital, color: Color(0xFF1E88E5)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedHospitalName ?? 'Chọn bệnh viện',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedHospitalName != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Nút submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        widget.initial != null ? 'Cập nhật' : 'Thêm',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
