import 'package:flutter/material.dart';
import 'package:flutter_application/staff/browse_room.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ⭐️ [แก้ไข] import หน้าที่จำเป็นให้ครบ และลบตัวซ้ำ
import 'addroom.dart';
// import 'browse_room.dart'; // 👈 (ไฟล์นี้ไม่ได้ใช้ในหน้านี้)
import 'history.dart';
import '../shared/profile.dart';
import 'editroom.dart';
// ⭐️ [เพิ่ม] ต้อง import หน้า 'Browse_Lecturer' (หน้า Home)
import 'browse_room.dart'; 

class DashboardPage_Staff extends StatefulWidget {
  final String userID;
  final String userRole;

  const DashboardPage_Staff({
    super.key,
    required this.userID,
    required this.userRole,
  });

  @override
  State<DashboardPage_Staff> createState() => _DashboardPage_StaffState();
}

class _DashboardPage_StaffState extends State<DashboardPage_Staff> {
  // ⭐️ [ลบ] List นี้ไม่ได้ใช้งานในไฟล์นี้
  // final List<String> _pageTitles = [ ... ];

  // ตัวแปรสำหรับเก็บข้อมูลจาก API
  Map<String, dynamic> _dashboardData = {
    'totalSlots': 0,
    'freeSlots': 0,
    'pendingSlots': 0,
    'disabledRooms': 0,
  };

  bool _isLoading = true;
  String _errorMessage = '';

  final int _currentIndex = 3; // 3 คือ index ของ Dashboard

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // 🔹 ฟังก์ชันสำหรับเรียก API Dashboard Summary
  Future<void> _fetchDashboardData() async {
    // (โค้ดส่วนนี้ถูกต้องอยู่แล้ว... )
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await http.get(
        Uri.parse('http://26.122.43.191:3000/api/dashboard/summary'),
        headers: {
          'Content-Type': 'application/json',
          'UserID': widget.userID,
          'UserRole': widget.userRole,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final int totalRooms = data['totalRooms'] ?? 0;
        final int bookedSlotsToday = data['bookedSlotsToday'] ?? 0;
        final int freeRooms = totalRooms - bookedSlotsToday;

        setState(() {
          _dashboardData = {
            'totalRooms': totalRooms,
            'freeRooms': data['freeRooms'] ?? 0, 
            'pendingSlots': data['pendingSlots'] ?? 0,
            'disabledRooms': data['disabledRooms'] ?? 0,
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E63F3),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _fetchDashboardData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E63F3)),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _fetchDashboardData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E63F3),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(
                        _dashboardData['totalRooms'].toString(),
                        "Total\nRooms",
                        const Color(0xFF1E63F3),
                        Colors.white,
                      ),
                      _buildInfoCard(
                        _dashboardData['freeRooms'].toString(),
                        "Free\nRooms",
                        const Color(0xFFDCE8FF),
                        Colors.black,
                      ),
                      _buildInfoCard(
                        _dashboardData['pendingSlots'].toString(),
                        "Pending\nSlots",
                        const Color(0xFFFFF6BF),
                        Colors.black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF5350),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Disabled\nRooms",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _dashboardData['disabledRooms'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E63F3),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
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

  // ⭐️ [แก้ไข] ฟังก์ชัน _onItemTapped ให้ครบ 6 ปุ่ม
  void _onItemTapped(int index) {
    if (index == _currentIndex) {
      return; // ไม่ต้องทำอะไรถ้ากดหน้าเดิม
    }

    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Browse_Staff( 
              userId: widget.userID,
              userRole: widget.userRole,
            ),
          ),
        );
        break;
      case 1: // Edit
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EditRoomListPage(
              userID: widget.userID,
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
              userID: widget.userID,
              userRole: widget.userRole,
            ),
          ),
        );
        break;
      case 3: // Dashboard (หน้าปัจจุบัน)
        // ไม่ต้องทำอะไร
        break;
      case 4: // History
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryPage(
              userID: widget.userID,
              userRole: widget.userRole,
            ),
          ),
        );
        break;
      // ⭐️ [เพิ่ม] case 5 ที่หายไปสำหรับหน้า User
      // case 5: // User
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => Profile(
      //         userId: widget.userID, // ⭐️ ( Profile รับ 'userId' ตัวเล็ก)
      //       ),
      //     ),
      //   );
        // break;
    }
  }

  // 🔹 ฟังก์ชัน _buildInfoCard (ถูกต้องอยู่แล้ว)
  Widget _buildInfoCard(
    String value,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      width: 105,
      height: 100,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}