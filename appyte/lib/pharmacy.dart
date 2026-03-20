import 'package:flutter/material.dart';

class PharmacyPage extends StatefulWidget {
  const PharmacyPage({super.key});

  @override
  State<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends State<PharmacyPage> {
  final searchCtrl = TextEditingController();
  List<Map<String, String>> filteredPharmacies = [];

  final List<Map<String, String>> pharmacies = [
    {
      'name': 'Long Châu - Chi nhánh Tân Bình',
      'address': '123 Đường Lê Văn Sỹ, Quận Tân Bình, TP HCM'
    },
    {
      'name': 'Long Châu - Chi nhánh Quận 1',
      'address': '456 Đường Nguyễn Huệ, Quận 1, TP HCM'
    },
    {
      'name': 'Long Châu - Chi nhánh Quận 3',
      'address': '789 Đường Võ Văn Tần, Quận 3, TP HCM'
    },
    {
      'name': 'Long Châu - Chi nhánh Gò Vấp',
      'address': '321 Đường Nguyễn Ấn Ninh, Quận Gò Vấp, TP HCM'
    },
    {
      'name': 'Long Châu - Chi nhánh Bình Thạnh',
      'address': '654 Đường Hoàng Hoa Thám, Quận Bình Thạnh, TP HCM'
    },
    {
      'name': 'Nhà thuốc An Khang',
      'address': '111 Đường Cộng Hòa, Quận Tân Bình, TP HCM'
    },
    {
      'name': 'Nhà thuốc Thương Mại',
      'address': '222 Đường Trần Hưng Đạo, Quận 1, TP HCM'
    },
    {
      'name': 'Nhà thuốc Sài Gòn',
      'address': '333 Đường Đinh Tiên Hoàng, Quận 1, TP HCM'
    },
  ];

  @override
  void initState() {
    super.initState();
    filteredPharmacies = pharmacies;
    searchCtrl.addListener(_filterPharmacies);
  }

  void _filterPharmacies() {
    String query = searchCtrl.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredPharmacies = pharmacies;
      } else {
        filteredPharmacies = pharmacies
            .where((pharmacy) =>
                pharmacy['name']!.toLowerCase().contains(query) ||
                pharmacy['address']!.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('🏥 Tìm nhà thuốc'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildPharmacyList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: searchCtrl,
        decoration: InputDecoration(
          hintText: 'Tìm theo tên hoặc địa chỉ...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    searchCtrl.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF1F2F4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPharmacyList() {
    if (filteredPharmacies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy nhà thuốc',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredPharmacies.length,
      itemBuilder: (context, index) {
        final pharmacy = filteredPharmacies[index];
        return _buildPharmacyCard(pharmacy);
      },
    );
  }

  Widget _buildPharmacyCard(Map<String, String> pharmacy) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: Colors.blue.shade700,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      pharmacy['name']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 44),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showPharmacyDetail(pharmacy),
                      child: Text(
                        pharmacy['address']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showPharmacyDetail(Map<String, String> pharmacy) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pharmacy['name'] ?? '',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pharmacy['address'] ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
