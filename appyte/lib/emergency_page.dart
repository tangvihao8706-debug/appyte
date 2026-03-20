import 'package:flutter/material.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final conditionCtrl = TextEditingController();
  final ageCtrl = TextEditingController();

  List<Map<String, String>> emergencyRequests = [];

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    conditionCtrl.dispose();
    ageCtrl.dispose();
    super.dispose();
  }

  void _sendEmergencyRequest() {
    if (nameCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng điền đầy đủ thông tin'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final request = {
      'name': nameCtrl.text,
      'phone': phoneCtrl.text,
      'address': addressCtrl.text,
      'condition': conditionCtrl.text,
      'age': ageCtrl.text,
      'time': DateTime.now().toString().split('.')[0],
    };

    setState(() {
      emergencyRequests.insert(0, request);
    });

    _clearFields();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Yêu cầu cấp cứu đã được gửi!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _clearFields() {
    nameCtrl.clear();
    phoneCtrl.clear();
    addressCtrl.clear();
    conditionCtrl.clear();
    ageCtrl.clear();
  }

  void _deleteRequest(int index) {
    setState(() {
      emergencyRequests.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('🚑 Hotline Xe Cấp Cứu'),
        backgroundColor: Colors.red.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildForm(),
            _buildRequestList(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin bệnh nhân',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            nameCtrl,
            'Tên bệnh nhân *',
            Icons.person,
          ),
          _buildTextField(
            phoneCtrl,
            'Số điện thoại *',
            Icons.phone,
          ),
          _buildTextField(
            ageCtrl,
            'Tuổi',
            Icons.cake,
          ),
          _buildTextField(
            addressCtrl,
            'Địa chỉ hiện tại *',
            Icons.location_on,
          ),
          _buildTextField(
            conditionCtrl,
            'Triệu chứng / Tình trạng',
            Icons.monitor_heart,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _sendEmergencyRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.phone_in_talk),
              label: const Text(
                'GỬI YÊU CẦU CẤP CỨU',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFF1F2F4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildRequestList() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (emergencyRequests.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Lịch sử yêu cầu cấp cứu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: emergencyRequests.length,
              itemBuilder: (_, index) {
                final request = emergencyRequests[index];
                return _buildRequestCard(request, index);
              },
            ),
          ] else ...[
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(Icons.local_hospital,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có yêu cầu cấp cứu',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, String> request, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: Colors.red.shade700, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tuổi: ${request['age']?.isEmpty ?? true ? "N/A" : request['age']}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteRequest(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Xóa',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildInfoRow(Icons.phone, 'SĐT', request['phone'] ?? ''),
              const SizedBox(height: 8),
              _buildInfoRow(
                  Icons.location_on, 'Địa chỉ', request['address'] ?? ''),
              if ((request['condition'] ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(Icons.health_and_safety, 'Triệu chứng',
                    request['condition'] ?? ''),
              ],
              const SizedBox(height: 8),
              Text(
                'Thời gian: ${request['time'] ?? ''}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.red.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
