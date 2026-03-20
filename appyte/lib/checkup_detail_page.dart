import 'package:flutter/material.dart';

import 'models/checkup.dart';
import 'services/checkup_service.dart';
import 'checkup_form_page.dart';

class CheckupDetailPage extends StatefulWidget {
  final Checkup checkup;

  const CheckupDetailPage({super.key, required this.checkup});

  @override
  State<CheckupDetailPage> createState() => _CheckupDetailPageState();
}

class _CheckupDetailPageState extends State<CheckupDetailPage> {
  final CheckupService _service = CheckupService();
  late Checkup _checkup;
  bool _isEditingResult = false;
  late TextEditingController _resultController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _checkup = widget.checkup;
    _resultController = TextEditingController(text: _checkup.result ?? '');
    _notesController = TextEditingController(text: _checkup.notes ?? '');
  }

  @override
  void dispose() {
    _resultController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _editCheckup() async {
    final result = await Navigator.push<Checkup>(
      context,
      MaterialPageRoute(builder: (_) => CheckupFormPage(initial: _checkup)),
    );

    if (result != null) {
      await _service.update(result);
      setState(() => _checkup = result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật lịch khám thành công')),
      );
    }
  }

  Future<void> _markAsCompleted() async {
    if (_resultController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập kết quả khám')),
      );
      return;
    }

    await _service.markAsCompleted(
      _checkup.id,
      _resultController.text,
      _notesController.text.isEmpty ? null : _notesController.text,
    );

    _checkup.status = 'completed';
    _checkup.actualDate = DateTime.now();
    _checkup.result = _resultController.text;
    _checkup.notes = _notesController.text.isEmpty ? null : _notesController.text;

    setState(() => _isEditingResult = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã hoàn tất khám')),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day;
    final month = date.month;
    final year = date.year;
    return '$day/$month/$year';
  }

  String _formatDateTime(DateTime date) {
    final day = date.day;
    final month = date.month;
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year lúc $hour:$minute';
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'upcoming':
        return 'Sắp tới';
      case 'completed':
        return 'Đã khám';
      case 'overdue':
        return 'Quá hạn';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
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
        title: const Text(
          'Chi tiết lịch khám',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_checkup.status != 'completed')
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Sửa'),
                  onTap: _editCheckup,
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge - lớn hơn
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: _getStatusColor(_checkup.status).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    _checkup.status == 'completed'
                        ? Icons.check_circle
                        : _checkup.status == 'overdue'
                            ? Icons.warning_amber_rounded
                            : Icons.schedule,
                    size: 24,
                    color: _getStatusColor(_checkup.status),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getStatusText(_checkup.status),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _getStatusColor(_checkup.status),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Thông tin khám
            _buildSection(
              '📋 Thông tin khám',
              [
                _buildInfoRow('Loại khám', _checkup.checkupType),
                if (_checkup.checkupMode != null)
                  _buildInfoRow('Hình thức', _checkup.checkupMode!),
                _buildInfoRow('Ngày dự kiến', _formatDate(_checkup.scheduledDate)),
                if (_checkup.reason.isNotEmpty) _buildInfoRow('Lý do', _checkup.reason),
                if (_checkup.symptom.isNotEmpty)
                  _buildInfoRow('Triệu chứng', _checkup.symptom, isMultiline: true),
              ],
            ),

            const SizedBox(height: 28),

            // Cơ sở y tế
            if (_checkup.doctorName != null || _checkup.hospitalName != null)
              _buildSection(
                '🏥 Cơ sở y tế',
                [
                  if (_checkup.doctorName != null)
                    _buildInfoRow('Bác sĩ', _checkup.doctorName!),
                  if (_checkup.hospitalName != null)
                    _buildInfoRow('Bệnh viện', _checkup.hospitalName!),
                ],
              ),

            if (_checkup.doctorName != null || _checkup.hospitalName != null)
              const SizedBox(height: 28),

            // Kết quả khám (nếu đã hoàn tất)
            if (_checkup.status == 'completed')
              _buildSection(
                '✅ Kết quả khám',
                [
                  if (_checkup.actualDate != null)
                    _buildInfoRow('Ngày khám thực tế', _formatDateTime(_checkup.actualDate!)),
                  if (_checkup.result != null && _checkup.result!.isNotEmpty)
                    _buildInfoRow('Kết quả', _checkup.result!, isMultiline: true),
                  if (_checkup.notes != null && _checkup.notes!.isNotEmpty)
                    _buildInfoRow('Ghi chú', _checkup.notes!, isMultiline: true),
                ],
              ),

            // Form nhập kết quả (nếu chưa hoàn tất)
            if (_checkup.status != 'completed' && !_isEditingResult)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => setState(() => _isEditingResult = true),
                      icon: const Icon(Icons.check),
                      label: const Text('Hoàn tất khám'),
                    ),
                  ),
                ],
              ),

            // Form nhập kết quả (khi đang chỉnh sửa)
            if (_isEditingResult)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Nhập kết quả khám',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _resultController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Mô tả kết quả khám',
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
                  const SizedBox(height: 16),
                  const Text(
                    'Ghi chú thêm (tuỳ chọn)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Ghi chú thêm',
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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => setState(() => _isEditingResult = false),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _markAsCompleted,
                          child: const Text(
                            'Lưu',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
            maxLines: isMultiline ? null : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
