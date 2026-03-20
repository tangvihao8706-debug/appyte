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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return const Color(0xFF0A5CFF);
      case 'completed':
        return const Color(0xFF12A569);
      case 'overdue':
        return const Color(0xFFE84C3D);
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'upcoming':
        return 'SẮP TỚI';
      case 'completed':
        return 'ĐÃ KHÁM';
      case 'overdue':
        return 'QUÁ HẠN';
      case 'cancelled':
        return 'ĐÃ HỦY';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_checkup.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: statusColor,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết lịch khám',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
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
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _checkup.status == 'completed'
                        ? Icons.check_circle
                        : _checkup.status == 'overdue'
                            ? Icons.warning_amber_rounded
                            : Icons.schedule,
                    size: 28,
                    color: statusColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getStatusText(_checkup.status),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Thông tin khám
            _buildSection(
              '📋 Thông tin khám',
              const Color(0xFF0A5CFF),
              [
                _buildInfoRow('Loại khám', _checkup.checkupType),
                if (_checkup.checkupMode != null && _checkup.checkupMode!.isNotEmpty)
                  _buildInfoRow('Hình thức', _checkup.checkupMode!),
                _buildInfoRow('Ngày dự kiến', _formatDate(_checkup.scheduledDate)),
                if (_checkup.reason.isNotEmpty)
                  _buildInfoRow('Lý do', _checkup.reason),
                if (_checkup.symptom.isNotEmpty)
                  _buildInfoRow('Triệu chứng', _checkup.symptom, isMultiline: true),
              ],
            ),

            const SizedBox(height: 28),

            // Cơ sở y tế
            if (_checkup.doctorName != null || _checkup.hospitalName != null)
              _buildSection(
                '🏥 Cơ sở y tế',
                const Color(0xFF12A569),
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
                const Color(0xFF12A569),
                [
                  if (_checkup.actualDate != null)
                    _buildInfoRow(
                      'Ngày khám thực tế',
                      _formatDateTime(_checkup.actualDate!),
                    ),
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
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF12A569),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => setState(() => _isEditingResult = true),
                      icon: const Icon(Icons.check, size: 24),
                      label: const Text(
                        'Hoàn tất khám',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // Form nhập kết quả (khi đang chỉnh sửa)
            if (_isEditingResult)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  const Text(
                    'Nhập kết quả khám',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _resultController,
                    maxLines: 5,
                    style: const TextStyle(fontSize: 16),
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
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ghi chú thêm (tuỳ chọn)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 16),
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
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () =>
                                setState(() => _isEditingResult = false),
                            child: const Text(
                              'Hủy',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF12A569),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _markAsCompleted,
                            child: const Text(
                              'Lưu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
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

  Widget _buildSection(
    String title,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          top: BorderSide(color: color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
              height: 1.5,
            ),
            maxLines: isMultiline ? null : 1,
            overflow: isMultiline ? null : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
