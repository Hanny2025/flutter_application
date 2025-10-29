import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// 1. DATA MODEL & MOCK DATA (จำลองข้อมูลผู้ใช้และ Auth Service)
// -----------------------------------------------------------------------------

class UserProfile {
  final String id;
  final String username;
  final String position;

  UserProfile({
    required this.id,
    required this.username,
    required this.position,
  });
}

// -----------------------------------------------------------------------------
// 2. USER SCREEN UI
// -----------------------------------------------------------------------------

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  // สถานะสำหรับเก็บข้อมูลผู้ใช้ที่ดึงมาจากฐานข้อมูล (จำลอง)
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // เริ่มดึงข้อมูลเมื่อหน้าจอถูกสร้าง
  }

  // **จำลองการดึงข้อมูลผู้ใช้จาก Database**
  // ในการใช้งานจริง โค้ดส่วนนี้จะทำการเรียก API หรือ Firestore เพื่อดึงข้อมูล User
  Future<void> _fetchUserData() async {
    // กำหนดให้รอ 1 วินาที เพื่อจำลองการโหลดข้อมูล
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      // ข้อมูลผู้ใช้จำลอง (Mock data)
      _userProfile = UserProfile(
        id: '2025001',
        username: 'Somchai Thepnakorn',
        position: 'Admin', // หรือ 'User'
      );
      _isLoading = false;
    });
  }

  // **จำลองการ Log Out**
  // ในการใช้งานจริง โค้ดส่วนนี้จะเรียก Firebase Auth หรือ API เพื่อทำการ Sign Out
  void _handleLogout() {
    // 1. แสดงผลใน console ว่ากำลังจะ Log out
    debugPrint('*** LOG OUT INITIATED ***');

    // 2. แสดง Dialog ยืนยัน
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context), // ปิด Dialog
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // 3. ทำการ Log out (จำลอง)
              debugPrint('User Logged Out Successfully!');

              // สำหรับ Mock: ปิดหน้า UserScreen 2 ครั้งเพื่อกลับไปหน้า Dashboard หลัก (Home)
              Navigator.of(context).pop(); // ปิด Dialog
              // ปิดหน้า UserScreen (กลับไปหน้าหลัก) - ต้องแน่ใจว่ากลับไปที่ Root
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // Widget สำหรับแสดงบัตรข้อมูลผู้ใช้
  Widget _buildProfileCard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ใช้ข้อมูลที่ดึงมาแล้ว
    final user = _userProfile!;

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F8FF), // สีฟ้าอ่อนตามรูปภาพ
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 50, color: Colors.black54),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${user.id}',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Text(
                  'Username: ${user.username}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Position: ${user.position}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget สำหรับปุ่ม Log Out
  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _handleLogout, // เรียกฟังก์ชัน Log Out
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.logout, color: Colors.red, size: 28),
                const SizedBox(width: 16),
                const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User')),
      // ไม่ต้องใส่ BottomNavigationBar ที่นี่ เพราะจะนำทางไปที่หน้าใหม่
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. บัตรข้อมูลผู้ใช้ (ID, Username, Position)
            _buildProfileCard(),

            const Divider(), // เส้นแบ่ง
            // 2. ปุ่ม Log Out
            _buildLogoutButton(),

            const Divider(),
          ],
        ),
      ),
    );
  }
}
