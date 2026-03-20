import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shop Demo',
      theme: ThemeData(useMaterial3: true),
      home: const ProductPage(),
    );
  }
}

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  // DỮ LIỆU MẪU
  final List<Map<String, String>> products = const [
    {
      "name": "Combo 2 Enfagrow A+ số 4 1700g",
      "price": "1.881.000đ",
      "img": "🥛"
    },
    {
      "name": "Combo 2 Sữa Enfagrow A+ 830g",
      "price": "1.017.000đ",
      "img": "🍼"
    },
    {
      "name": "Combo 2 Thực phẩm dinh dưỡng y học",
      "price": "2.338.000đ",
      "img": "🥫"
    },
    {"name": "Sữa Abbott Grow 2+ 1.6kg", "price": "1.250.000đ", "img": "🧃"},
    {"name": "Sữa Similac 2+ 800g", "price": "980.000đ", "img": "🥛"},
    {"name": "Combo 3 lon Abbott Grow", "price": "2.025.000đ", "img": "🍼"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cửa hàng sữa"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 210, // 🔑 QUAN TRỌNG: gọn, không lỗi
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final item = products[index];
            return _ProductCard(item: item);
          },
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, String> item;

  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBuyDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ẢNH
            Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: Center(
                    child: Text(
                      item['img']!,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Tặng",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // THÔNG TIN
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['price']!,
                    style: const TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // POPUP MUA HÀNG
  void _showBuyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận mua"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🛒 Sản phẩm: ${item['name']}"),
            const SizedBox(height: 8),
            Text("💰 Giá: ${item['price']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Mua hàng thành công")),
              );
            },
            child: const Text("Mua"),
          ),
        ],
      ),
    );
  }
}
