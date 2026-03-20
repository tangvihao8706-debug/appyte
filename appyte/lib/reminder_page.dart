import 'package:flutter/material.dart';
import 'add_reminder_page.dart';
import 'today_medicine_page.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  /// Dùng tạm list đơn giản, KHÔNG MODEL
  final List<Map<String, dynamic>> _reminders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Nhắc uống thuốc"),
        centerTitle: true,
      ),

      body: Column(
        children: [
          _dateBar(),
          Expanded(
            child: _reminders.isEmpty
                ? _emptyState(context)
                : _medicineList(),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _addButton(context),
    );
  }

  // ================= DATE BAR =================
  Widget _dateBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: const Text(
        "Hôm nay",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E88E5),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ================= EMPTY STATE =================
  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_note,
                size: 90, color: Color(0xFFB0BEC5)),
            const SizedBox(height: 20),
            const Text(
              "Hôm nay bạn chưa có lịch nhắc uống thuốc",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              "Hãy tạo lịch nhắc uống thuốc mới",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TodayMedicinePage(),
                    ),
                  );
                },
                child: const Text("Danh sách thuốc hôm nay"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= MEDICINE LIST =================
  Widget _medicineList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final r = _reminders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            r['name'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  // ================= ADD BUTTON =================
  Widget _addButton(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        onPressed: () async {
          final result = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(builder: (_) => const AddReminderPage()),
          );

          if (result != null) {
            setState(() => _reminders.add(result));
          }
        },
        child: const Text(
          "Tạo lịch nhắc",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
