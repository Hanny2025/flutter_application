import 'package:flutter/material.dart';
import '../Bottom_Nav.dart'; // 📍 (ใช้ import เดิมของคุณ)
import 'package:flutter_application/shared/login.dart'; // 📍 (เพิ่ม) Import สำหรับหน้า Login

import 'Lecturer_Check.dart';
import 'Lecturer_History.dart';
import 'Lecturer_request.dart';

// 📍 (เพิ่ม) Imports สำหรับ API (จากทั้ง 2 ไฟล์)
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// ----------------------------------------
// Constants (รวมจากทั้ง 2 ไฟล์)
// ----------------------------------------
const Color primaryBlue = Color(0xFF1976D2);
const Color lightPageBg = Color(0xFFE7F7FF); // 👈 สีพื้นหลังหลัก (จาก Browse)
const Color lightCardBg = Color(0xFFE0F7FF); // 👈 สีการ์ดห้อง (จาก Browse)

// 📍 (เพิ่ม) สีจากหน้า Profile
const Color lightBlueBackground = Color(0xFFE8F6FF);
const Color darkGrey = Color(0xFF333333);

// ----------------------------------------
// Model (จาก Browse_Lecturer)
// ----------------------------------------
class Room {
  final String imagePath;
  final String title;
  final String subtitle;
  final String maxText;
  final String price;
  final List<({String time, String status, Color color})> slots;

  Room({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.maxText,
    required this.price,
    required this.slots,
  });
}

// ----------------------------------------
// หน้าจอหลัก (Browse_Lecturer)
// ----------------------------------------
class Browse_Lecturer extends StatefulWidget {
  final String userId;
  final String userRole;
  const Browse_Lecturer({
    super.key,
    required this.userId,
    required this.userRole,
  });

  @override
  State<Browse_Lecturer> createState() => _Browse_LecturerState();
}

class _Browse_LecturerState extends State<Browse_Lecturer> {
  // --- State Variables ---
  int _selectedIndex = 0;
  late Future<List<Room>> _roomsFuture;
  final String serverIp = '10.2.21.252'; // 👈 ใส่ IP ของคุณ

  // 📍 (เพิ่ม) List ของ Title สำหรับ AppBar
  final List<String> _pageTitles = [
    'Rooms', // Index 0
    'Request', // Index 1 <-- ✅
    'Check', // Index 2 <-- ✅
    'History', // Index 3
    'User', // Index 4
  ];

  @override
  void initState() {
    super.initState();
    _roomsFuture = fetchRooms();
  }

  void _refreshRooms() {
    setState(() {
      _roomsFuture = fetchRooms();
    });
  }

  Color _mapStatusToColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'free':
        return Colors.green;
      case 'reserved':
        return Colors.red;
      case 'disabled':
        return Colors.black;
      case 'pending':
        return Colors.orange;
      case 'not available':
        return Colors.grey;
      default:
        return Colors.grey[400]!;
    }
  }

  Future<List<Room>> fetchRooms() async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final url = Uri.parse(
      'http://$serverIp:3000/rooms-with-status?date=$today',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      debugPrint('GET rooms -> url:$url status:${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

        return data.map((roomData) {
          final List<dynamic> slotsData = roomData['slots'] ?? [];
          final List<({String time, String status, Color color})> slots =
              slotsData.map((slot) {
                String status = slot['Slot_status'] as String? ?? 'Disabled';
                return (
                  time: slot['Slot_label'] as String? ?? 'N/A',
                  status: status,
                  color: _mapStatusToColor(status),
                );
              }).toList();

          return Room(
            title: roomData['Room_name'] ?? 'No Name',
            slots: slots,
            imagePath: 'assets/imgs/room.jpg',
            subtitle: '',
            maxText: '',
            price: '',
          );
        }).toList();
      } else {
        throw Exception(
          'Failed to load rooms (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch rooms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. สร้างหน้า List ห้อง
    final Widget roomListPage = FutureBuilder<List<Room>>(
      future: _roomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Error loading rooms:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No rooms found.'));
        }
        final List<Room> rooms = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: rooms.length,
          itemBuilder: (context, i) => _roomCard(rooms[i], lightCardBg),
        );
      },
    );

    // 2. 📍 (แก้ไข) สร้าง List ของหน้าจอทั้งหมด
    final List<Widget> pages = [
      // Index 0: Home (หน้า List ห้อง)
      roomListPage,

      // Index 1: Request (หน้าใหม่)  <-- ⭐️ เพิ่ม
      Lecturer_req(userId: widget.userId),

      // Index 2: Check (เปลี่ยนเป็นหน้าจริง)
      CheckPage(userId: widget.userId),

      // Index 3: History (เปลี่ยนเป็นหน้าจริง)
      HistoryPage(userId: widget.userId),

      // Index 4: User
      Profile(userId: widget.userId),
    ];

    return Scaffold(
      backgroundColor: lightPageBg, // 👈 สีพื้นหลังจาก Browse
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,

        leading: IconButton(
          icon: const Icon(Icons.dashboard, color: Colors.white),
          onPressed: () {
            // 📍 ใช้ pushReplacementNamed เพื่อกลับไปหน้า Dashboard
            // พร้อมล้างหน้าปัจจุบันออกจาก Stack
            // และส่งข้อมูลผู้ใช้กลับไปด้วย
            Navigator.pushReplacementNamed(
              context,
              '/Lecturer_Browse', // 👈 เปลี่ยนเป็นชื่อ Route ของหน้า Dashboard ของคุณ
              arguments: {'userId': widget.userId, 'userRole': widget.userRole},
            );
          },
          tooltip: 'Dashboard / Back',
        ),
        // 📍 (แก้ไข) ทำให้ Title เปลี่ยนตาม Tab ที่เลือก
        title: Text(
          _pageTitles[_selectedIndex], // 👈 ใช้ Title จาก List
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          // 📍 (แก้ไข) แสดงปุ่ม Refresh เมื่ออยู่ที่หน้า Rooms (Index 0) เท่านั้น
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _refreshRooms,
              tooltip: 'Refresh',
            ),
        ],
      ),

      // 📍 (แก้ไข) body จะสลับหน้าไปตาม List 'pages'
      body: pages[_selectedIndex],

      // BottomNavigationBar เดิม
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.description), // 👈 (เลือกไอคอนตามชอบ)
            label: 'Request',
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
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        showUnselectedLabels: true,
      ),
    );
  }

  // --- Widgets ย่อยของ Browse ---
  Widget _roomCard(Room r, Color lightCardBg) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: ไปหน้า Room Detail (ถ้าต้องการ)
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.asset(
                r.imagePath,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.business,
                    color: Colors.grey[600],
                    size: 50,
                  ),
                ),
              ),
            ),
            Container(
              color: lightCardBg,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r.subtitle,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(r.maxText, style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            r.price,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final s in r.slots)
                    _buildTimeSlot(s.time, s.status, s.color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(String time, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(time, style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// 📍 (เพิ่ม) โค้ดทั้งหมดจากหน้า Profile.dart ย้ายมาไว้ที่นี่
// ===================================================================

class Profile extends StatefulWidget {
  final String userId;

  const Profile({super.key, required this.userId});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMessage = '';
  final String serverIp = '10.2.21.252'; // 👈 (ใช้ IP เดียวกัน)

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // 📍 (แก้ไข) ทำให้ isLoading = true ตอนเริ่ม fetch
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse("http://$serverIp:3000/get_user?user_id=${widget.userId}"),
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userData = data;
          isLoading = false;
        });
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? "Failed to load user data");
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  void _handleLogout() {
    _showLogoutDialog(context);
  }

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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // ปิด Dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (route) => false, // ลบทุกหน้าจอใน Stack
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
    // 📍 (แก้ไข) ลบ Scaffold และ AppBar ออก
    // และคืนค่าเป็น Widget ที่แสดงผลตามสถานะ (isLoading, errorMessage, userData)

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Error: $errorMessage",
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchUserData, // 👈 เรียก Retry
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (userData == null) {
      return const Center(child: Text("No user data found"));
    }

    // 📍 (แก้ไข) ถ้าโหลดสำเร็จ ให้คืนค่า SingleChildScrollView
    // (ซึ่งเดิมเคยอยู่ใน body: ... ของ Scaffold)
    // 📍 (เพิ่ม) Padding ที่นี่ เพราะไม่มี Scaffold แล้ว
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserProfileCard(
            userId: userData!['User_id'].toString(),
            username: userData!['username'],
            position: userData!['role'],
          ),
          const SizedBox(height: 30),
          LogoutTile(onTap: _handleLogout),
        ],
      ),
    );
  }
}

// --- Widgets ย่อยของ Profile ---

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
        color: lightBlueBackground, // 👈 ใช้สีจาก Constants
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
          const Icon(Icons.person_pin, size: 60, color: primaryBlue),
          const SizedBox(width: 20),
          // 📍 (แก้ไข) ใช้ Expanded เพื่อกันข้อความล้น
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: $userId',
                  style: const TextStyle(fontSize: 16, color: darkGrey),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Username: $username',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkGrey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Position: $position',
                  style: const TextStyle(fontSize: 16, color: darkGrey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LogoutTile extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8), // 📍 (เพิ่ม) ให้ขอบมนตอนกด
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.white, // 📍 (เพิ่ม) สีพื้นหลัง
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade100, width: 1),
          // 📍 (เปลี่ยน) ใช้ Border รอบๆ แทนเส้นล่าง
          // border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.logout, color: Colors.red, size: 28),
                SizedBox(width: 15),
                Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }
}
