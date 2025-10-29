import 'package:flutter/material.dart';
import 'package:flutter_application/login.dart';

// --- Constants ---
const Color primaryBlue = Color(0xFF1976D2);
const Color lightBlueBackground = Color(
  0xFFE8F6FF,
); // สีฟ้าอ่อนสำหรับ Card ข้อมูล
const Color darkGrey = Color(0xFF333333);

// --- Main Screen Class (Profile) ---
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // สถานะสำหรับ Bottom Navigation Bar
  int _selectedIndex = 4; // 'User' ถูกเลือกตามภาพ

  // ข้อมูลจำลองผู้ใช้
  final String userId = '123456';
  final String username = 'John Doe';
  final String position = 'User';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // ในแอปพลิเคชันจริง คุณจะใช้ Navigator เพื่อเปลี่ยนหน้า
  }

  // <<< 1. แก้ไข _handleLogout ให้เรียก Dialog
  void _handleLogout() {
    // เรียกฟังก์ชันที่เพิ่มเข้ามาใหม่
    _showLogoutDialog(context);
  }

  // <<< 2. เพิ่มฟังก์ชัน _showLogoutDialog ที่คุณส่งมา
  // 🔐 ฟังก์ชันแสดงกล่องยืนยันออกจากระบบ
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirm Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // <<< 3. แก้ไข Navigator ให้ล้าง Stack (เหมือน _handleLogout เดิม)
                Navigator.pop(context); // ปิด Dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. AppBar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: primaryBlue,
        centerTitle: true,
        title: const Text(
          'User',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // 2. Body: เนื้อหาหลัก
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card แสดงข้อมูลผู้ใช้
            UserProfileCard(
              userId: userId,
              username: username,
              position: position,
            ),

            const SizedBox(height: 30),

            // ปุ่ม Log Out
            LogoutTile(onTap: _handleLogout),
          ],
        ),
      ),

      // 3. BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
            label: 'Requested',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Check',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ------------------------------------------------------------------
// WIDGETS ย่อย: Card แสดงข้อมูลผู้ใช้
// ------------------------------------------------------------------
class UserProfileCard extends StatelessWidget {
  final String userId;
  final String username;
  final String position;

  const UserProfileCard({
    super.key,
    required this.userId,
    required this.username,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: lightBlueBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ไอคอนผู้ใช้ขนาดใหญ่
          const Icon(Icons.person_pin, size: 60, color: primaryBlue),
          const SizedBox(width: 20),

          // รายละเอียดผู้ใช้
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID: $userId',
                style: const TextStyle(fontSize: 16, color: darkGrey),
              ),
              const SizedBox(height: 4),
              Text(
                'Username: $username',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkGrey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Position: $position',
                style: const TextStyle(fontSize: 16, color: darkGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// WIDGETS ย่อย: ปุ่ม Log Out
// ------------------------------------------------------------------
class LogoutTile extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // ไอคอน Log Out สีแดง
                const Icon(Icons.logout, color: Colors.red, size: 28),
                const SizedBox(width: 15),
                // ข้อความ Log Out
                const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            // ลูกศรขวา
            const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }
}
