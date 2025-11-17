import 'package:flutter/material.dart';
import 'package:flutter_application/shared/login.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// ⭐️ [เพิ่ม] Imports สำหรับหน้า Staff
import 'addroom.dart';
import 'editroom.dart';
import 'dashboard.dart';
import 'history.dart';

// ----------------------------------------
// ## 🎨 Theme Constants
// ----------------------------------------
const Color primaryBlue = Color(0xFF1976D2);
const Color lightPageBg = Color(0xFFE7F7FF);
const Color lightCardBg = Color(0xFFE0F7FF);

const Color lightBlueBackground = Color(0xFFE8F6FF);
const Color darkGrey = Color(0xFF333333);

// ----------------------------------------
// ## 📊 Model
// ----------------------------------------
class Room {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String maxText;
  final String price;
  final List<({String time, String status, Color color})> slots;

  Room({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.maxText,
    required this.price,
    required this.slots,
  });
}

// ----------------------------------------
// ## 🏠 Browse_Lecturer (Main Screen)
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
  int _currentIndex = 0; // ⭐️ ตั้งค่าเริ่มต้นเป็น Index 0 (Home)
  late Future<List<Room>> _roomsFuture;

  final String serverIp = '26.122.43.191'; // 📍 **IP Server**

  final GlobalKey<_ProfileState> _profileKey = GlobalKey<_ProfileState>();

  // ⭐️ [แก้ไข] Title 6 เมนูสำหรับ Staff
  final List<String> _pageTitles = [
    'Rooms', // Index 0
    'Edit', // Index 1
    'Add', // Index 2
    'Dashboard', // Index 3
    'History', // Index 4
    'User', // Index 5
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

  // ⭐️ [แก้ไข] ฟังก์ชัน Refresh ให้ตรงกับ Index 6 เมนู
  void _handleRefresh() {
    setState(() {
      switch (_currentIndex) {
        case 0: // Rooms
          _refreshRooms();
          break;
        case 1: // Edit
          debugPrint('Refreshing Edit page (Index 1)...');
          break;
        case 2: // Add
          debugPrint('Refreshing Add page (Index 2)...');
          break;
        case 3: // Dashboard
          debugPrint('Refreshing Dashboard page (Index 3)...');
          break;
        case 4: // History
          debugPrint('Refreshing History page (Index 4)...');
          break;
        case 5: // User (Profile)
          _profileKey.currentState?.fetchUserData();
          debugPrint('Refreshing Profile page (Index 5)...');
          break;
      }
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

      // ⭐️ DEBUG: แสดงข้อมูลดิบ
      debugPrint('📊 Raw data received: ${data.length} rooms');
      for (var room in data) {
        debugPrint('📦 Room: ${room['Room_name']}, Raw Image: "${room['image_url']}"');
      }

      return data.map((roomData) {
        final List<dynamic> slotsData = roomData['slots'] ?? [];
        final List<({String time, String status, Color color})> slots =
            slotsData.map((slot) {
          String status = slot['Slot_status'] as String? ?? 'Free';
          return (
            time: slot['Slot_label'] as String? ?? 'N/A',
            status: status,
            color: _mapStatusToColor(status),
          );
        }).toList();

        // ⭐️ แก้ไข: แปลง URL ให้ถูกต้อง
        String imageUrl = roomData['image_url']?.toString() ?? '';
        debugPrint('🖼️ Before conversion - Room: ${roomData['Room_name']}, URL: "$imageUrl"');

        if (imageUrl.isNotEmpty) {
          // ทำความสะอาด URL - ลบ space และอักขระแปลกๆ
          imageUrl = imageUrl.replaceAll(' ', '').trim();
          
          // ถ้ายังเป็น relative path
          if (imageUrl.startsWith('/uploads/')) {
            imageUrl = 'http://$serverIp:3000$imageUrl';
          } else if (imageUrl.contains('uploads') && !imageUrl.startsWith('http')) {
            // แก้ไข path ที่ผิดพลาด
            if (imageUrl.contains('roomsyroom')) {
              imageUrl = imageUrl.replaceAll('roomsyroom', 'rooms/room');
            }
            if (imageUrl.contains('rooms room')) {
              imageUrl = imageUrl.replaceAll('rooms room', 'rooms/room');
            }
            imageUrl = 'http://$serverIp:3000/$imageUrl';
          }
        }

        debugPrint('🔗 After conversion - Room: ${roomData['Room_name']}, URL: "$imageUrl"');

        return Room(
          title: roomData['Room_name']?.toString() ?? 'No Name',
          slots: slots,
          imageUrl: imageUrl,
          subtitle: roomData['Room_status']?.toString() ?? '',
          maxText: 'Max: 4 people',
          price: '${roomData['price_per_day']?.toString() ?? '0'} baht/day'
        );
      }).toList();
    } else {
      throw Exception('Failed to load rooms (Status: ${response.statusCode})');
    }
  } catch (e) {
    debugPrint('❌ Error fetching rooms: $e');
    throw Exception('Failed to fetch rooms: $e');
  }
}

  // ⭐️ [แก้ไข] ฟังก์ชันสำหรับสลับหน้า - ใช้ Navigator แบบที่คุณต้องการ
  void _onItemTapped(int index) {
    if (index == _currentIndex) {
      return; // ไม่ต้องทำอะไรถ้ากดหน้าเดิม
    }

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Home (หน้าปัจจุบัน)
        // ไม่ต้องทำอะไร เพราะอยู่ที่หน้า Home แล้ว
        break;
      case 1: // Edit
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EditRoomListPage(
              userID: widget.userId,
              userRole: widget.userRole,
            ),
          ),
        );
        break;
      case 2: // Add
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddRoomPage(
              userID: widget.userId,
              userRole: widget.userRole,
            ),
          ),
        );
        break;
      case 3: // Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage_Staff(
              userID: widget.userId,
              userRole: widget.userRole,
            ),
          ),
        );
        break;
      case 4: // History
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryPage(
              userID: widget.userId,
              userRole: widget.userRole,
            ),
          ),
        );
        break;
      case 5: // User
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Profile(
              userId: widget.userId,
              userRole: widget.userRole,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⭐️ [แก้ไข] สร้างหน้า Rooms โดยตรงแทนการใช้ pages list
    final Widget roomListPage = FutureBuilder<List<Room>>(
      future: _roomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
            ),
          );
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

    return Scaffold(
      backgroundColor: lightPageBg,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: Text(
          _pageTitles[_currentIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _handleRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),

      // ⭐️ [แก้ไข] แสดงเฉพาะหน้า Rooms เพราะหน้าเดียวที่อยู่ในนี้
      body: roomListPage,

      // ⭐️ [แก้ไข] เปลี่ยนเป็น BottomNavigationBar 6 เมนู
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E63F3),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: _onItemTapped, // 👈 ใช้งานฟังก์ชันสลับหน้า
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Edit'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined), label: 'Add'),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
      ),
    );
  }

  Widget _roomCard(Room r, Color lightCardBg) {
    debugPrint('🎯 Building card for: ${r.title}');
  debugPrint('🖼️ Final Image URL: "${r.imageUrl}"');
  if (r.imageUrl.isNotEmpty) {
    debugPrint('🔗 Test this URL in browser: ${r.imageUrl}');
  }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Add navigation to Room Details page
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⭐️ [แก้ไข] 3. เปลี่ยนจาก Image.asset เป็น Image.network
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              // ⭐️ ตรวจสอบว่า URL ว่างหรือไม่
              child: r.imageUrl.isEmpty
                  ? Container( // 👈 ถ้า URL ว่าง, แสดง Icon
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[600],
                        size: 50,
                      ),
                    )
                  : Image.network(
                    r.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    headers: const {
                      'Accept': 'image/*',
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        debugPrint('✅ Image loaded: ${r.imageUrl}');
                        return child;
                      }
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / 
                                  loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.broken_image_outlined, // 👈 Icon เมื่อโหลดรูป_
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
                  // แสดง Time Slots
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
// ## 👤 Profile Screen (มาจาก Profile.dart)
// ===================================================================

class Profile extends StatefulWidget {
  final String userId;
  final String userRole; // ⭐️ [เพิ่ม] รับ userRole

  const Profile({super.key, required this.userId, required this.userRole});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMessage = '';

  final String serverIp = '26.122.43.191';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
    }

    try {
      final response = await http.get(
        Uri.parse("http://$serverIp:3000/get_user?user_id=${widget.userId}"),
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (!mounted) return;

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
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  // --- Logout Logic ---
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
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (route) => false,
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
              onPressed: fetchUserData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (userData == null) {
      return const Center(child: Text("No user data found"));
    }

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

// ... ส่วนของ UserProfileCard และ LogoutTile เหมือนเดิม ...

// ----------------------------------------
// ## 💳 UserProfileCard Widget
// ----------------------------------------
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

  // ⭐️ [แก้ไข] ย้ายเมธอด build ที่หลุดไป กลับเข้ามาในคลาส
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
          const Icon(Icons.person_pin, size: 60, color: primaryBlue),
          const SizedBox(width: 20),
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

// ----------------------------------------
// ## 🚪 LogoutTile Widget
// ----------------------------------------
class LogoutTile extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade100, width: 1),
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