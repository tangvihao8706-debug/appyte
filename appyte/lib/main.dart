import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/medicine_search_overlay.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'config/firebase_config.dart';
import 'services/firebase_auth_service.dart';
import 'login_page.dart';

import 'reminder_page.dart';
import 'doctor_list_page.dart';
import 'hospital_list_page.dart';
import 'profile_page.dart';
import 'pharmacy.dart';
import 'emergency_page.dart';

import 'health_detail_page.dart';
import 'checkup_list_page.dart';
import 'models/checkup.dart';
import 'services/checkup_service.dart';
import 'services/notification_service.dart';
import 'services/firebase_user_service.dart';
import 'vaccine_search_page.dart';
import 'mom_baby_page.dart';


// ================= MODEL =================
class HealthArticle {
  final String title;
  final String content;
  final IconData icon;

  HealthArticle(this.title, this.content, this.icon);
}

// ================= FAKE API =================
class HealthService {
  static Future<List<HealthArticle>> fetchArticles() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      // ===================== 1 =====================
      HealthArticle(
        "Nguy hiểm từ đơn thuốc AI",
        '''
Trong bối cảnh trí tuệ nhân tạo (AI) phát triển mạnh mẽ, nhiều người có xu hướng hỏi AI để tự chẩn đoán bệnh và kê đơn thuốc.
Các chuyên gia y tế cảnh báo, AI không thể thay thế hoàn toàn bác sĩ trong điều trị.

AI không có khả năng nắm rõ tiền sử bệnh, bệnh nền, tình trạng dị ứng và tương tác thuốc phức tạp.
Việc sử dụng đơn thuốc do AI gợi ý có thể gây hậu quả nghiêm trọng.

RỦI RO KHI DÙNG ĐƠN THUỐC AI:
- Uống thuốc không đúng bệnh
- Dùng sai liều, quá liều
- Không phát hiện tương tác thuốc
- Che lấp triệu chứng bệnh nặng

HẬU QUẢ:
- Dị ứng thuốc, sốc phản vệ
- Tổn thương gan, thận
- Làm nặng bệnh nền
- Chậm trễ điều trị

KHUYẾN CÁO:
- Chỉ dùng AI để tham khảo kiến thức
- Không tự ý dùng thuốc kê đơn
- Luôn hỏi bác sĩ hoặc dược sĩ

Người dân cần tỉnh táo trước các thông tin y tế trên mạng để bảo vệ sức khỏe bản thân.
''',
        Icons.warning_amber_rounded,
      ),

      // ===================== 2 =====================
      HealthArticle(
        "Gia tăng ngộ độc thực phẩm",
        '''
Ngộ độc thực phẩm đang có xu hướng gia tăng, đặc biệt vào mùa nắng nóng.
Theo ngành y tế, nguyên nhân chủ yếu đến từ thực phẩm không đảm bảo vệ sinh an toàn.

Vi khuẩn, virus và độc tố có thể phát triển nhanh trong điều kiện bảo quản kém.

NGUYÊN NHÂN PHỔ BIẾN:
- Thức ăn để lâu ngoài môi trường
- Thực phẩm sống và chín không tách biệt
- Dụng cụ chế biến không sạch
- Thực phẩm ôi thiu

TRIỆU CHỨNG:
- Đau bụng, tiêu chảy
- Buồn nôn, nôn ói
- Sốt, mệt mỏi
- Mất nước nghiêm trọng

XỬ TRÍ:
- Ngừng ăn thực phẩm nghi ngờ
- Bù nước, điện giải
- Đến cơ sở y tế nếu triệu chứng nặng

PHÒNG TRÁNH:
- Ăn chín uống sôi
- Rửa tay trước khi ăn
- Chọn thực phẩm có nguồn gốc rõ ràng
''',
        Icons.restaurant,
      ),

      // ===================== 3 =====================
      HealthArticle(
        "Não mô cầu dễ gây tử vong",
        '''
Bệnh não mô cầu là bệnh truyền nhiễm nguy hiểm do vi khuẩn não mô cầu gây ra.
Bệnh có thể dẫn đến viêm màng não và nhiễm trùng huyết, tiến triển rất nhanh.

ĐƯỜNG LÂY:
- Qua đường hô hấp
- Tiếp xúc gần nơi đông người

DẤU HIỆU:
- Sốt cao đột ngột
- Đau đầu dữ dội
- Buồn nôn, cứng cổ
- Xuất huyết dưới da

XỬ TRÍ:
- Cấp cứu ngay
- Không tự điều trị tại nhà

PHÒNG BỆNH:
- Tiêm vắc xin đầy đủ
- Giữ vệ sinh cá nhân
- Đeo khẩu trang nơi đông người
''',
        Icons.health_and_safety,
      ),

      // ===================== 4 =====================
      HealthArticle(
        "Tăng huyết áp ở người cao tuổi",
        '''
Tăng huyết áp là bệnh lý phổ biến ở người cao tuổi và là nguyên nhân hàng đầu gây đột quỵ.
Bệnh thường diễn tiến âm thầm, khó phát hiện sớm.

DẤU HIỆU THƯỜNG GẶP:
- Đau đầu, chóng mặt
- Mệt mỏi
- Khó thở
- Mất ngủ

BIẾN CHỨNG:
- Tai biến mạch máu não
- Nhồi máu cơ tim
- Suy tim

PHÒNG NGỪA:
- Kiểm tra huyết áp định kỳ
- Ăn nhạt, giảm muối
- Tập thể dục nhẹ nhàng
- Tuân thủ điều trị của bác sĩ
''',
        Icons.monitor_heart,
      ),

      // ===================== 5 =====================
      HealthArticle(
        "Tiểu đường và biến chứng nguy hiểm",
        '''
Tiểu đường là bệnh mạn tính ngày càng phổ biến, đặc biệt ở người trung niên và cao tuổi.
Nếu không kiểm soát tốt, bệnh có thể gây nhiều biến chứng nguy hiểm.

BIẾN CHỨNG:
- Tổn thương mắt, mù lòa
- Suy thận
- Tổn thương thần kinh
- Tim mạch

DẤU HIỆU CẢNH BÁO:
- Khát nước nhiều
- Đi tiểu nhiều
- Sụt cân nhanh
- Mệt mỏi kéo dài

KIỂM SOÁT BỆNH:
- Kiểm tra đường huyết định kỳ
- Chế độ ăn hợp lý
- Tập luyện đều đặn
- Dùng thuốc theo chỉ định
''',
        Icons.bloodtype,
      ),

      // ===================== 6 =====================
      HealthArticle(
        "Loãng xương ở người lớn tuổi",
        '''
Loãng xương khiến xương trở nên giòn và dễ gãy, thường gặp ở người cao tuổi.
Bệnh tiến triển âm thầm và chỉ phát hiện khi đã xảy ra gãy xương.

NGUY CƠ:
- Tuổi cao
- Thiếu canxi, vitamin D
- Ít vận động

HẬU QUẢ:
- Gãy xương hông, cột sống
- Giảm chất lượng cuộc sống

PHÒNG NGỪA:
- Bổ sung canxi và vitamin D
- Tập thể dục phù hợp
- Khám sức khỏe định kỳ
''',
        Icons.accessibility_new,
      ),
    ];
  }
}

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId:
      "113645662886-9a065d8e8a75neu370i38t0idcrf8fgt.apps.googleusercontent.com",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      home: const AuthWrapper(),
    );
  }
}

// ================= AUTH WRAPPER =================
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Connection state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Đang tải...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          );
        }

        // Check if user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in
          return const HomeScreen();
        }

        // User is not logged in
        return LoginPage(
          onLoginSuccess: () {
            // Trigger rebuild when login is successful
            // The StreamBuilder will automatically rebuild
          },
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  GoogleSignInAccount? _currentUser;
  List<Checkup> _notificationCheckups = [];
  late Timer _notificationTimer;
  final _authService = FirebaseAuthService();

  
@override
  void initState() {
    super.initState();
    // Nghe tín hiệu từ Firebase Auth thay vì GoogleSignIn
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          // Ép kiểu hoặc lấy thông tin từ Firebase User để hiển thị
          // Tui dùng tạm object lồng để ông không phải sửa code UI bên dưới nhiều
          _currentUser = user as dynamic; 
        });
      }
    });

       // Load notifications khi mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
      // Bắt đầu periodic reload mỗi 30 giây
      _startNotificationTimer();
    });
  }

  @override
  void dispose() {
    _notificationTimer.cancel();
    super.dispose();
  }

  void _startNotificationTimer() {
    _notificationTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (mounted) {
          _loadNotifications();
        }
      },
    );
  }

  Future<void> _loadNotifications() async {
    try {
      final checkupService = CheckupService();
      final all = await checkupService.getAll();
      final notifications = NotificationService.getCheckupNotifications(all);
      if (mounted) {
        setState(() {
          _notificationCheckups = notifications;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homeBody(),
      const Center(child: Text("Trang Video")),
      const Center(child: Text("Trang Tư vấn")),
      const Center(child: Text("Trang Giỏ hàng")),
      ProfilePage(
        user: _currentUser,
        onSignIn: () => _googleSignIn.signIn(),
        onSignOut: () async {
    await GoogleSignIn().signOut(); 
    await FirebaseAuth.instance.signOut(); // Dòng này cực quan trọng để AuthWrapper nhảy về Login
    if (mounted) setState(() => _currentUser = null);
  },
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          // Refresh badge khi vào trang chủ
          if (i == 0) {
            _loadNotifications();
          }
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined), label: "Trang chủ"),
          NavigationDestination(
              icon: Icon(Icons.video_library_outlined), label: "Video"),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline), label: "Tư vấn"),
          NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined), label: "Giỏ hàng"),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: "Tài khoản"),
        ],
      ),
    );
  }

  // ================= HOME =================
  Widget _homeBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
             Expanded(
              child: Text(
                FirebaseAuth.instance.currentUser != null
                    ? "Chào ${FirebaseAuth.instance.currentUser!.displayName ?? 'Bạn'} 👋"
                    : "Chào khách 👋",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              // Icon chuông với badge
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, size: 26),
                    onPressed: () {
                      NotificationService.showNotificationDialog(
                          context, _notificationCheckups);
                    },
                  ),
                  if (_notificationCheckups.isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          _notificationCheckups.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _searchBar(),
          const SizedBox(height: 20),
          _buildMenu(),
          const SizedBox(height: 28),
          _healthSection(context),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MedicineSearchOverlay()),
        );
      },
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 8),
            Text("Tìm kiếm thuốc",
                style: TextStyle(color: Colors.grey))
          ],
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        const MenuItem(Icons.medication, "Cần mua thuốc", Color(0xFF1E88E5)),
       MenuItem(
   Icons.vaccines,
  "Tiêm vắc xin",
  const Color(0xFF00BFA5),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const VaccineSearchPage()),
  ),
),
        MenuItem(
          Icons.location_on,
          "Tìm nhà thuốc",
          const Color(0xFF7C4DFF),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PharmacyPage()),
          ),
        ),
        MenuItem(
          Icons.alarm,
          "Nhắc uống thuốc",
          const Color(0xFFFFA000),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReminderPage()),
          ),
        ),
        MenuItem(
          Icons.phone,
          "Xe cấp cứu",
          const Color(0xFFD32F2F),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EmergencyPage()),
          ),
        ),
        MenuItem(
          Icons.local_hospital,
          "Bác sĩ",
          const Color(0xFF00ACC1),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DoctorListPage()),
          ),
        ),
        MenuItem(
          Icons.local_hospital,
          "Bệnh viện",
          const Color(0xFF4E89AE),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HospitalListPage()),
          ),
        ),
        MenuItem(
          Icons.calendar_today,
          "Thăm khám định kỳ",
          const Color(0xFFD32F2F),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CheckupListPage()),
          ),
        ),
        const MenuItem(Icons.shopping_bag, "Danh mục", Color(0xFF1976D2)),
        MenuItem(
  Icons.favorite, 
  "Mẹ và bé", 
  const Color(0xFFE91E63),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductPage()),
    );
  },
),
           
      ],
    );
  }
}

/* ================= GÓC SỨC KHỎE ================= */

Widget _healthSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle("Góc sức khỏe"),
      const SizedBox(height: 12),
      FutureBuilder<List<HealthArticle>>(
        future: HealthService.fetchArticles(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children:
                snapshot.data!.map((a) => _healthItem(context, a)).toList(),
          );
        },
      ),
    ],
  );
}

Widget _sectionTitle(String title) {
  return Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
  );
}

Widget _healthItem(BuildContext context, HealthArticle article) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HealthDetailPage(
            title: article.title,
            content: article.content,
          ),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(article.icon, color: const Color(0xFF1E88E5), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  article.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
}

// ================= MENU ITEM =================
class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const MenuItem(this.icon, this.title, this.color, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 46) / 2,
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
