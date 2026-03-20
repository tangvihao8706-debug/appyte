import 'package:flutter/material.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  int _timesPerDay = 1;
  final List<TimeOfDay> _times = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),

      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Tạo lịch nhắc uống thuốc",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // ===== BODY =====
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionTitle("Thông tin thuốc"),

            _card(
              icon: Icons.medication,
              title: "Tên thuốc",
              child: TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: "Ví dụ: Paracetamol 500mg",
                  border: InputBorder.none,
                ),
              ),
            ),

            _card(
              icon: Icons.repeat,
              title: "Số lần uống mỗi ngày",
              child: DropdownButton<int>(
                value: _timesPerDay,
                isExpanded: true,
                underline: const SizedBox(),
                items: List.generate(
                  6,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text("${i + 1} lần / ngày"),
                  ),
                ),
                onChanged: (v) {
                  setState(() {
                    _timesPerDay = v!;
                    _times.clear();
                  });
                },
              ),
            ),

            _sectionTitle("Thời gian uống"),

            _card(
              icon: Icons.access_time,
              title: "Giờ uống thuốc",
              child: Column(
                children: [
                  ..._times.map(
                    (t) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.schedule,
                          color: Color(0xFF1E88E5)),
                      title: Text(
                        t.format(context),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.check_circle,
                          color: Colors.green),
                    ),
                  ),
                  if (_times.length < _timesPerDay)
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Thêm giờ uống"),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() => _times.add(picked));
                        }
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      // ===== BUTTON =====
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            onPressed: () {
              if (_nameCtrl.text.isEmpty || _times.isEmpty) return;

              Navigator.pop(context, {
                "name": _nameCtrl.text,
                "times": _times.map((e) => e.format(context)).toList(),
              });
            },
            child: const Text(
              "XÁC NHẬN",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  // ===== UI HELPERS =====

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1E88E5)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
