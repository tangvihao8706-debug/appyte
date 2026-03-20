import 'dart:async';
import 'package:flutter/material.dart';

import 'models/checkup.dart';
import 'services/firestore_checkup_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/notification_service.dart';
import 'checkup_form_page.dart';
import 'checkup_detail_page.dart';

class CheckupListPage extends StatefulWidget {
  const CheckupListPage({super.key});

  @override
  State<CheckupListPage> createState() => _CheckupListPageState();
}

class _CheckupListPageState extends State<CheckupListPage> with TickerProviderStateMixin {
  final _service = FirestoreCheckupService();
  final _authService = FirebaseAuthService();
  List<Checkup> _upcomingCheckups = [];
  List<Checkup> _completedCheckups = [];
  List<Checkup> _overdueCheckups = [];
  late TabController _tabController;
  late StreamSubscription<List<Checkup>> _checkupSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupStreams();
  }

  @override
  void dispose() {
    _checkupSubscription.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _setupStreams() {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập trước')),
      );
      return;
    }

    // Real-time streams từ Firestore với timeout
    _checkupSubscription = _service.streamAll(userId).timeout(
      const Duration(seconds: 10),
      onTimeout: (sink) {
        print('Checkup stream timeout');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kết nối timeout')),
          );
        }
        sink.close();
      },
    ).listen(
      (allCheckups) {
        if (mounted) {
          setState(() {
            _upcomingCheckups = allCheckups.where((c) => c.status == 'upcoming').toList()
              ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
            _completedCheckups = allCheckups.where((c) => c.status == 'completed').toList()
              ..sort((a, b) => (b.actualDate ?? DateTime.now()).compareTo(a.actualDate ?? DateTime.now()));
            _overdueCheckups = allCheckups.where((c) => c.status == 'overdue').toList()
              ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
          });
        }
      },
      onError: (e) {
        print('Error loading checkups: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${e.toString()}')),
          );
        }
      },
      onDone: () {
        print('Checkup stream closed');
      },
    );
  }

  Future<void> _onAdd() async {
    final result = await Navigator.push<Checkup>(
      context,
      MaterialPageRoute(builder: (_) => const CheckupFormPage()),
    );
    if (result != null) {
      // Form đã lưu vào Firestore, list sẽ tự update qua stream
      // Schedule local notifications
      await NotificationService.scheduleCheckupNotification(result);
    }
  }

  Future<void> _onViewDetail(Checkup checkup) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => CheckupDetailPage(checkup: checkup)),
    );
  }

  Future<void> _onEdit(Checkup checkup) async {
    final result = await Navigator.push<Checkup>(
      context,
      MaterialPageRoute(builder: (_) => CheckupFormPage(initial: checkup)),
    );
    if (result != null) {
      // Form đã cập nhật vào Firestore, list sẽ tự update qua stream
      // Cancel previous notifications and schedule new ones
      await NotificationService.cancelCheckupNotifications(checkup);
      await NotificationService.scheduleCheckupNotification(result);
    }
  }

  Future<void> _onDelete(Checkup checkup) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Xoá lịch khám'),
            content: const Text('Bạn có chắc muốn xoá lịch khám này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Xoá'),
              ),
            ],
          ),
        ) ??
        false;

    if (ok) {
      try {
        // Cancel all scheduled notifications for this checkup then delete
        await NotificationService.cancelCheckupNotifications(checkup);
        await _service.delete(checkup.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xoá lịch khám')),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A5CFF),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lịch khám định kỳ',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(
              text: 'Sắp tới (${_upcomingCheckups.length})',
            ),
            Tab(
              text: 'Đã khám (${_completedCheckups.length})',
            ),
            Tab(
              text: 'Quá hạn (${_overdueCheckups.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(_upcomingCheckups, const Color(0xFF0A5CFF)),
          _buildTabContent(_completedCheckups, const Color(0xFF12A569)),
          _buildTabContent(_overdueCheckups, const Color(0xFFE84C3D)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        backgroundColor: const Color(0xFF0A5CFF),
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildTabContent(List<Checkup> checkups, Color statusColor) {
    if (checkups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Không có lịch khám',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: checkups.length,
      itemBuilder: (context, index) {
        return _CheckupCard(
          checkup: checkups[index],
          statusColor: statusColor,
          onDetail: () => _onViewDetail(checkups[index]),
          onEdit: () => _onEdit(checkups[index]),
          onDelete: () => _onDelete(checkups[index]),
        );
      },
    );
  }
}

class _CheckupCard extends StatelessWidget {
  final Checkup checkup;
  final Color statusColor;
  final VoidCallback onDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CheckupCard({
    required this.checkup,
    required this.statusColor,
    required this.onDetail,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: statusColor, width: 5),
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
        children: [
          // Header với status badge
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusLabel(checkup.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(checkup.scheduledDate),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Loại khám
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.healing,
                        color: Colors.blue[700],
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loại khám',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            checkup.checkupType,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          if (checkup.checkupMode != null &&
                              checkup.checkupMode!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  checkup.checkupMode!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bác sĩ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.green[700],
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bác sĩ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            checkup.doctorName ?? 'Chưa chọn',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bệnh viện
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.local_hospital,
                        color: Colors.orange[700],
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bệnh viện',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            checkup.hospitalName ?? 'Chưa chọn',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (checkup.reason.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.note,
                          color: Colors.purple[700],
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lý do',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              checkup.reason,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A1A),
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDetail,
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Chi tiết'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0A5CFF),
                      side: const BorderSide(
                        color: Color(0xFF0A5CFF),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Sửa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(
                        color: Colors.orange,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Xoá'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
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
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}
