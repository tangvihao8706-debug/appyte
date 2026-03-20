import 'package:flutter/material.dart';
import 'medicine_detail_page.dart';

class MedicineSearchOverlay extends StatefulWidget {
  const MedicineSearchOverlay({super.key});

  @override
  State<MedicineSearchOverlay> createState() => _MedicineSearchOverlayState();
}

class _MedicineSearchOverlayState extends State<MedicineSearchOverlay> {
  String keyword = "";
  late TextEditingController _controller;

  // Danh sách thuốc mẫu
  final List<Map<String, String>> medicines = [
    {
      "name": "Paracetamol 500mg",
      "desc": "Giảm đau, hạ sốt",
      "image": "assets/image/thuoc_ha_sot.jpg",
    },
    {
      "name": "Amoxicillin 500mg",
      "desc": "Kháng sinh điều trị nhiễm khuẩn",
      "image": "assets/image/thuoc_khang_sinh.webp",
    },
    {
      "name": "Losartan 50mg",
      "desc": "Điều trị huyết áp cao",
      "image": "assets/image/thuoc_huyet_ap.jpg",
    },
    {
      "name": "Vitamin C",
      "desc": "Tăng sức đề kháng",
      "image": "assets/image/vitamin_c.webp",
    },
    {
      "name": "Aspirin 100mg",
      "desc": "Giảm đau, kháng viêm",
      "image": "assets/image/giam_dau_khang_viem.jpg",
    },
    {
      "name": "Ibuprofen 400mg",
      "desc": "Giảm đau, hạ sốt",
      "image": "assets/image/tang_suc_de_khang.jpg",
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lọc theo từ khóa
    final filteredMedicines = medicines.where((medicine) {
      final medicineName = medicine["name"]!.toLowerCase();
      final searchKeyword = keyword.trim().toLowerCase();

      // Nếu keyword rỗng, hiển thị tất cả
      if (searchKeyword.isEmpty) {
        return true;
      }

      // Tìm từ khóa ở bất kỳ đâu trong tên thuốc
      return medicineName.contains(searchKeyword);
    }).toList();

    return Material(
      color: Colors.transparent,
      child: Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFFF6F8FC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // ===== SEARCH BAR =====
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                // Drag indicator
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // Search field
                TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm thuốc...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: keyword.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _controller.clear();
                              setState(() {
                                keyword = "";
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      keyword = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // ===== MEDICINE LIST =====
          Expanded(
            child: filteredMedicines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Không tìm thấy thuốc",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: filteredMedicines.length,
                    itemBuilder: (context, index) {
                      final medicine = filteredMedicines[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MedicineDetailPage(
                                name: medicine["name"]!,
                                desc: medicine["desc"]!,
                                image: medicine["image"]!,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Medicine image
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: AssetImage(medicine["image"]!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Medicine info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      medicine["name"]!,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      medicine["desc"]!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Arrow icon
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    )
    );
  }
}
