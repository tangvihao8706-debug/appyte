import 'package:flutter/material.dart';

class HealthDetailPage extends StatelessWidget {
  final String title;
  final String content;

  const HealthDetailPage({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Thông tin sức khỏe",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: const [
          Icon(Icons.share),
          SizedBox(width: 16),
          Icon(Icons.bookmark_border),
          SizedBox(width: 12),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== TITLE =====
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.35,
              ),
            ),

            const SizedBox(height: 8),

            // ===== META =====
            Row(
              children: const [
                Icon(Icons.schedule, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text("Cập nhật hôm nay",
                    style: TextStyle(color: Colors.grey)),
                SizedBox(width: 12),
                Icon(Icons.visibility, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text("1.234 lượt xem",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 18),

            // ===== SAPO (RẤT QUAN TRỌNG) =====
            _sapo(
              "Nhiều chuyên gia cảnh báo rằng việc chủ quan trong chăm sóc sức khỏe "
              "và tự ý điều trị có thể dẫn đến những hậu quả nghiêm trọng, đặc biệt "
              "ở người cao tuổi và người có bệnh nền.",
            ),

            const SizedBox(height: 24),

            // ===== NỘI DUNG CHÍNH =====
            _paragraph(content),

            _sectionTitle("Thực trạng đáng lo ngại"),

            _paragraph(
              "Theo ghi nhận từ các cơ sở y tế, số ca nhập viện liên quan đến "
              "việc sử dụng thuốc sai cách đang có xu hướng gia tăng trong "
              "những năm gần đây. Đáng chú ý, nhiều trường hợp xuất phát từ "
              "việc tự chẩn đoán bệnh dựa trên thông tin không chính thống.",
            ),

            _bullet([
              "Tự ý mua thuốc không cần đơn",
              "Dùng sai liều lượng hoặc thời gian",
              "Kết hợp nhiều loại thuốc không kiểm soát",
            ]),

            _sectionTitle("Đối tượng nguy cơ cao"),

            _paragraph(
              "Người cao tuổi, người mắc bệnh mạn tính và phụ nữ mang thai "
              "là những nhóm dễ gặp biến chứng nghiêm trọng nếu điều trị "
              "không đúng cách.",
            ),

            _infoBox(
              icon: Icons.groups,
              title: "Nhóm dễ bị ảnh hưởng",
              content:
                  "• Người trên 60 tuổi\n"
                  "• Người có bệnh nền (tim mạch, tiểu đường)\n"
                  "• Người suy giảm miễn dịch",
            ),

            _sectionTitle("Nguyên nhân và rủi ro"),

            _paragraph(
              "Các chuyên gia cho biết, nhiều công cụ hỗ trợ hiện nay "
              "không thể đánh giá đầy đủ tiền sử bệnh, tương tác thuốc "
              "hay tình trạng dị ứng của người dùng.",
            ),

            _warningBox(
              "Việc trì hoãn thăm khám y tế có thể khiến người bệnh "
              "bỏ lỡ thời điểm vàng trong điều trị, làm tăng nguy cơ "
              "biến chứng và tử vong.",
            ),

            _sectionTitle("Khuyến nghị từ chuyên gia"),

            _paragraph(
              "Người dân cần chủ động bảo vệ sức khỏe bằng cách thăm khám "
              "định kỳ, tuân thủ chỉ định của bác sĩ và không tự ý sử dụng thuốc.",
            ),

            _bullet([
              "Chỉ dùng thuốc khi có chỉ định chuyên môn",
              "Không tin tuyệt đối vào thông tin trên mạng",
              "Đến cơ sở y tế khi có dấu hiệu bất thường",
            ]),

            const SizedBox(height: 24),

            // ===== SOURCE =====
            _sectionTitle("Nguồn tham khảo"),

            _sourceBox(),
          ],
        ),
      ),
    );
  }

  // ================== WIDGETS ==================

  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16.5,
          height: 1.8,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _sapo(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          height: 1.6,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _bullet(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: items
            .map(
              (e) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ",
                      style:
                          TextStyle(fontSize: 20, height: 1.6)),
                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(
                          fontSize: 16.5, height: 1.6),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(height: 1.6)),
        ],
      ),
    );
  }

  Widget _warningBox(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sourceBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tổ chức Y tế Thế giới (WHO)",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            "• World Health Organization\n"
            "• https://www.who.int\n"
            "• Nguồn thông tin y tế chính thống",
            style: TextStyle(height: 1.6),
          ),
        ],
      ),
    );
  }
}
