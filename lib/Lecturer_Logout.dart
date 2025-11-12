import 'package:flutter/material.dart';
import 'BottomNav.dart'; // 👈 1. Import BottomNav
import 'package:http/http.dart' as http; // 👈 2. Import HTTP
import 'dart:convert'; // 👈 3. Import Convert
import 'package:shared_preferences/shared_preferences.dart'; // 👈 4. Import SharedPreferences

// ------------------------------------
// (1) 🌟 เปลี่ยนเป็น StatefulWidget
// ------------------------------------
class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // ------------------------------------
  // (2) 🌟 เพิ่ม State สำหรับเก็บข้อมูล
  // ------------------------------------
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // 👈 (3) สั่งดึงข้อมูลตอนเปิดหน้า
  }

  // ------------------------------------
  // (4) 🌟 ฟังก์ชันสำหรับดึงข้อมูลผู้ใช้
  // ------------------------------------
  Future<void> _fetchUserData() async {
    setStateIfMounted(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 4.1. 🔑 ค้นหา user_id ที่เราเก็บไว้ตอน Login
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id'); // (เราเก็บเป็น int ตอน Login)

      if (userId == null) {
        setStateIfMounted(() {
          _errorMessage = "User not logged in.";
          _isLoading = false;
        });
        // (ถ้าไม่มี user_id ก็อาจจะเด้งไปหน้า Login เลย)
        // Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // 4.2. 📞 เรียก API /get_user
      final url = Uri.parse('http://10.2.21.252:3000/get_user?user_id=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setStateIfMounted(() {
          _userData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setStateIfMounted(() {
          _errorMessage =
              "Failed to load user data (Code: ${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      setStateIfMounted(() {
        _errorMessage = "Error connecting: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  // (Helper function)
  void setStateIfMounted(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text(
          'User',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // ------------------------------------
      // (5) 🌟 แสดงผล Body ตามสถานะ
      // ------------------------------------
      body: _buildBodyContent(),

      // ------------------------------------
      // (6) 🌟 (แก้ไขจุดที่ 2) เพิ่ม BottomNav ใน Scaffold
      // (ตาม BottomNav.dart ของคุณ, 'User' คือ index 4)
      // ------------------------------------
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 4),
    );
  }

  // ------------------------------------
  // (7) 🌟 แยก Widget แสดงผล Body
  // ------------------------------------
  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          'Error: $_errorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // (ข้อมูลที่ได้จาก API)
    final username = _userData?['username'] ?? '...';
    final role = _userData?['role'] ?? '...';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🧍‍♂️ กล่องข้อมูลผู้ใช้ (ที่ดึงข้อมูลจริง)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 50, color: Colors.black54),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🌟 ใช้ข้อมูลจริง
                    Text(
                      'Username: $username', // 👈
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 🌟 ใช้ข้อมูลจริง
                    Text(
                      'Position: $role', // 👈
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 60),

          // 🚪 ปุ่ม Log Out
          InkWell(
            onTap: () {
              _showLogoutDialog(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.logout, color: Colors.red, size: 30),
                SizedBox(width: 8),
                Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, color: Colors.red, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------
  // (8) 🌟 (แก้ไขจุดที่ 1) ฟังก์ชัน Logout
  // ------------------------------------
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
              onPressed: () async {
                // 🌟 (เพิ่ม) เคลียร์ user_id ที่จำไว้
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_id');

                if (!mounted) return;
                Navigator.pop(context); // ปิด Dialog
                Navigator.pushReplacementNamed(
                  context,
                  '/login',
                ); // ไปหน้า Login
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],

          // ❌ (แก้ไขจุดที่ 1) ลบ BottomNav ที่ผิดออกจากตรงนี้
        );
      },
    );
  }
}
