import 'dart:async';
import 'package:flutter/material.dart';

import 'models/medicine.dart';
import 'services/firestore_medicine_service.dart';
import 'services/firebase_auth_service.dart';

class TodayMedicinePage extends StatefulWidget {
  const TodayMedicinePage({super.key});

  @override
  State<TodayMedicinePage> createState() => _TodayMedicinePageState();
}

class _TodayMedicinePageState extends State<TodayMedicinePage> {
  final _service = FirestoreMedicineService();
  final _authService = FirebaseAuthService();
  List<Medicine> _medicines = [];
  late StreamSubscription<List<Medicine>> _medicineSubscription;

  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  @override
  void dispose() {
    _medicineSubscription.cancel();
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

    _medicineSubscription = _service.streamAll(userId).listen(
      (medicines) {
        if (mounted) {
          setState(() => _medicines = medicines);
        }
      },
      onError: (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi tải thuốc: $e')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        title: const Text(
          'Nhắc uống thuốc',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _medicines.isEmpty ? _emptyState() : _medicineList(),
    );
  }

  // ================= EMPTY STATE ĐẸP =================
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.event_note, size: 90, color: Color(0xFFB0BEC5)),
            SizedBox(height: 20),
            Text(
              'Hôm nay bạn chưa có lịch uống thuốc',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy tạo lịch nhắc uống thuốc để không quên liều',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DANH SÁCH THUỐC =================
  Widget _medicineList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _medicines.length,
      itemBuilder: (context, index) {
        final m = _medicines[index];
        return _MedicineCard(medicine: m);
      },
    );
  }
}

// ================= CARD THUỐC =================
class _MedicineCard extends StatelessWidget {
  final Medicine medicine;

  const _MedicineCard({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.medication,
              color: Color(0xFF1E88E5),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),

          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Giờ uống: ${medicine.time}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // BADGE
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Hôm nay',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
