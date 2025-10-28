import 'package:flutter/material.dart';
import 'dart:async'; // สำหรับ Stream/Timer

// นำเข้าหน้าจอทั้งหมดที่ใช้งานจริง
import 'history.dart';
import 'user.dart';
import 'browse_room.dart';
import 'manage.dart'; 

// -----------------------------------------------------------------------------
// 1. DATA MODEL & MOCK DATABASE STREAM (จำลองการดึงข้อมูลสถิติจาก Database)
// -----------------------------------------------------------------------------

// Model สำหรับเก็บสถิติห้องพัก
class RoomStats {
  final int totalRooms;
  final int freeRooms;
  final int reservedRooms;
  final int disabledRooms;

  RoomStats({
    required this.totalRooms,
    required this.freeRooms,
    required this.reservedRooms,
    required this.disabledRooms,
  });

  // สร้าง factory method เพื่ออัปเดตค่า
  factory RoomStats.initial() => RoomStats(
      totalRooms: 25, freeRooms: 12, reservedRooms: 9, disabledRooms: 4);
}

// **จำลอง Database Stream (Database Connection Mock)**
// ในการใช้งานจริง จะแทนที่ด้วย Firebase Firestore Stream หรือ API WebSocket
Stream<RoomStats> get roomStatsStream {
  final controller = StreamController<RoomStats>();

  var currentStats = RoomStats.initial();
  controller.add(currentStats);

  // จำลองการอัปเดตข้อมูลทุก 5 วินาที
  Timer.periodic(const Duration(seconds: 5), (timer) {
    currentStats = RoomStats(
      totalRooms: currentStats.totalRooms, 
      freeRooms: currentStats.freeRooms,
      reservedRooms: currentStats.reservedRooms,
      disabledRooms: (currentStats.disabledRooms % 6) + 1, // วนค่า Disabled
    );
    controller.add(currentStats);
    debugPrint(
        'Database Mock: Stats updated. Disabled: ${currentStats.disabledRooms}');
  });

  return controller.stream;
}

// -----------------------------------------------------------------------------
// 2. MAIN APP & DASHBOARD SCREEN
// -----------------------------------------------------------------------------

void main() {
  debugPrint('--- Application Starting ---');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booking Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C6FD5),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFE8F6FF),
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Bottom Nav 5 ปุ่ม: Home, Requested, Check, History, User
  final List<Map<String, dynamic>> _bottomNavItems = [
    {'icon': Icons.home, 'label': 'Home'},
    {'icon': Icons.list_alt, 'label': 'Requested'}, // ต้องมีปุ่ม
    {'icon': Icons.check_circle_outline, 'label': 'Check'}, // ต้องมีปุ่ม
    {'icon': Icons.history, 'label': 'History'},
    {'icon': Icons.person, 'label': 'User'},
  ];

  // Map สำหรับการนำทางไปยังหน้าจอที่กำหนด
  final Map<int, Widget> _pageMap = {
    0: const BrowseRoom(), // Home (Index 0) - ไม่ได้ใช้งานโดยตรง
    3: const BookingHistoryScreen(), // History (Index 3)
    4: const UserScreen(), // User (Index 4)
  };

  void _onItemTapped(int index) {
    
    // 1. Home (Index 0): คงอยู่ที่หน้า Dashboard
    if (index == 0) {
        setState(() => _selectedIndex = 0); 
        return;
    }

    // 2. Requested (Index 1) และ Check (Index 2): กดได้เฉยๆ แต่มี Feedback
    if (index == 1 || index == 2) { 
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('ปุ่ม ${_bottomNavItems[index]['label']} ถูกกดแล้ว (รอพัฒนาฟีเจอร์)'),
                duration: const Duration(seconds: 1),
            ),
        );
        setState(() => _selectedIndex = 0); // รีเซ็ตกลับไปหน้า Home/Dashboard
        return;
    }

    // 3. History (Index 3) และ User (Index 4): นำทางไปยังหน้าจอใหม่
    if (index == 3 || index == 4) {
      debugPrint('Bottom Nav Item Pressed: ${_bottomNavItems[index]['label']} (Index $index) - Navigating');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _pageMap[index]!),
      ).then((_) {
        // เมื่อกลับมาจากหน้าจอใหม่ ให้ตั้งค่า Selected Index เป็น Home เสมอ
        setState(() => _selectedIndex = 0);
      });
    }
  }

  // Widget สำหรับแสดงบัตรสถิติห้องพัก
  Widget _buildStatisticCard(
      String number, String title, Color color, Color textColor) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          height: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                number,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                    fontSize: 16, color: textColor.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget สำหรับปุ่ม 'Quick Action'
  Widget _buildQuickActionButton(
      IconData icon, String title, Color color, Widget destinationScreen) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            debugPrint('Quick Action: $title Pressed - Navigating');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destinationScreen),
            ).then((_) {
              // เมื่อกลับมาจากหน้าจอ Quick Action ให้ตั้งค่า Selected Index เป็น Home
              setState(() => _selectedIndex = 0);
            });
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 36, color: Colors.black54),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // แยก Widget สำหรับเนื้อหาหลักของ Dashboard เพื่อนำไปใช้ใน StreamBuilder
  Widget _buildDashboardContent(BuildContext context, RoomStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. ส่วนสถิติด้านบน (4 บัตร) - รอเชื่อมกับ Database (ดึงค่าจาก stats)
          Row(
            children: <Widget>[
              _buildStatisticCard(
                stats.totalRooms.toString(),
                'Total Rooms',
                const Color(0xFF3B5998),
                Colors.white,
              ),
              _buildStatisticCard(
                stats.freeRooms.toString(),
                'Free Rooms',
                const Color(0xFF89B3F8),
                Colors.white,
              ),
              _buildStatisticCard(
                stats.reservedRooms.toString(),
                'Reserved',
                const Color(0xFFD9F46A),
                Colors.black87,
              ),
            ],
          ),

          // 2. ปุ่ม Disable Rooms - รอเชื่อมกับ Database (ดึงค่าจาก stats)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                debugPrint('Action: Disable Rooms Pressed');
                // โค้ดสำหรับการจัดการห้องที่ถูก Disable
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE84A5F),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                foregroundColor: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Disable Rooms',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ไอคอนตัวเลข Disabled Rooms
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Text(
                      stats.disabledRooms.toString(), // **ดึงค่าจาก stats**
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE84A5F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3. หัวข้อ Quick Action
          const Text(
            'Quick Action',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // 4. ส่วน Quick Action (3 ปุ่ม)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 1. ปุ่ม Browse Rooms (เชื่อมกับ browse_room.dart)
              _buildQuickActionButton(
                Icons.search,
                'Browse Rooms',
                const Color(0xFFB4E0F8),
                const BrowseRoom(),
              ),
              // 2. ปุ่ม History (เชื่อมกับ history.dart)
              _buildQuickActionButton(
                Icons.history,
                'History',
                const Color(0xFFE1B4F8),
                const BookingHistoryScreen(),
              ),
              // 3. ปุ่ม Manage Booking (เชื่อมกับ manage.dart)
              _buildQuickActionButton(
                Icons.person_pin_outlined,
                'Manage Booking',
                const Color(0xFFF8F4B4),
                const ManageBooking(),
              ),
            ],
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      // ใช้ StreamBuilder เพื่อรอข้อมูลจาก Database (จำลอง)
      body: StreamBuilder<RoomStats>(
        stream: roomStatsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            // แสดงข้อมูลเริ่มต้นหากมีปัญหาในการโหลดข้อมูล
            final stats = RoomStats.initial(); 
            return _buildDashboardContent(context, stats);
          }

          // ดึงข้อมูลสถิติที่อัปเดตล่าสุด
          final stats = snapshot.data!;
          return _buildDashboardContent(context, stats);
        },
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1C6FD5),
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, 

        items: _bottomNavItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item['icon']),
            label: item['label'],
          );
        }).toList(),
      ),
    );
  }
}
