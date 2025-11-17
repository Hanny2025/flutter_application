import 'package:flutter/material.dart';
import 'package:flutter_application/staff/dashboard.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// ⭐️ [เพิ่ม] Imports สำหรับการนำทาง
import 'addroom.dart';
import 'browse_room.dart';
import 'editroom.dart';

// ----------------------------------------
// ## 📅 HistoryPage (หน้าประวัติการจอง)
// ----------------------------------------

// ⭐️ [แก้ไข] เปลี่ยน Parameter ให้รับ userID และ userRole
class HistoryPage extends StatefulWidget {
  final String userID;
  final String userRole;

  const HistoryPage({
    super.key,
    required this.userID,
    required this.userRole,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<String> _pageTitles = [
    'Rooms',      // Index 0
    'Request',    // Index 1
    'Check',      // Index 2
    'History',    // Index 3
    'Manage',     // Index 4 🆕 สำหรับ Staff
    'User',       // Index 5
  ];
  // --- Constants & State Variables ---
  String selectedFilter = 'All';
  String currentUserName = 'Loading...';

  // ⭐️ [เพิ่ม] ตัวแปรสำหรับ BottomNavigationBar
  int _currentIndex = 4; // 4 คือ 'History'

  // Base URL
  final String _baseUrl =
      'http://26.122.43.191:3000'; // 📍 ตรวจสอบ IP ให้ถูกต้อง

  // Future สำหรับโหลดข้อมูลประวัติการจอง
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadPageData();
  }

  // ------------------------------------
  // ### 💾 Data Fetching & Refresh Logic
  // ------------------------------------

  // 1. โหลดข้อมูล Lecturer Name จาก SharedPreferences และเริ่มดึง History
  Future<List<Map<String, dynamic>>> _loadPageData() async {
    // 🔍 ดึงชื่อผู้ใช้
    try {
      final prefs = await SharedPreferences.getInstance();
      // ⭐️ [แก้ไข] ใช้ widget.userID จาก SharedPreferences (ถ้าจำเป็น)
      // หรือดึงชื่อจาก prefs.getString('user_name') ตามโค้ดเดิม
      final String? userName = prefs.getString('user_name');
      if (mounted) {
        setState(() {
          currentUserName = userName ?? 'Lecturer';
        });
      }
    } catch (e) {
      debugPrint('Error loading user name: $e');
      if (mounted) {
        setState(() {
          currentUserName = 'Error Loading Name';
        });
      }
    }

    // 🚀 ดึงประวัติการจอง
    return _fetchBookings();
  }

  // 2. ฟังก์ชันดึง History จาก API และทำการจัดเรียง 🔄
  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    // ⭐️ [ข้อสังเกต] API นี้ไม่ได้ใช้ widget.userID
    // หากต้องการประวัติเฉพาะผู้ใช้ ต้องแก้ API endpoint
    final url = Uri.parse('$_baseUrl/staff/history');
    debugPrint('Fetching ALL history from: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        List<Map<String, dynamic>> bookings =
            data.map((item) => item as Map<String, dynamic>).toList();

        // ✅ จัดเรียงตามเวลาที่รายการถูกสร้าง (created_at)
        bookings.sort((a, b) {
          final timestampA =
              a['created_at'] ?? a['action_at'] ?? a['booking_date'] ?? '';
          final timestampB =
              b['created_at'] ?? b['action_at'] ?? b['booking_date'] ?? '';

          final dateA = DateTime.tryParse(timestampA) ?? DateTime(1970);
          final dateB = DateTime.tryParse(timestampB) ?? DateTime(1970);

          return dateB.compareTo(dateA);
        });

        return bookings;
      } else {
        throw Exception(
          'Failed to load history (Code: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error fetching history: $e');
    }
  }

  // 3. ฟังก์ชัน Refresh ข้อมูล
  Future<void> refreshHistory() async {
    setState(() {
      _historyFuture = _loadPageData();
      selectedFilter = 'All'; // รีเซ็ต Filter เมื่อ Refresh
    });
    debugPrint('History list refreshed.');
  }

  // ------------------------------------
  // ### 🛠️ Helper Functions
  // ------------------------------------

  // 1. Format วันที่
  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      DateTime dateTime = DateTime.parse(dateString);
      dateTime = dateTime.toLocal();
      return DateFormat('d MMM yyyy').format(dateTime);
    } catch (e) {
      debugPrint('Date parsing error: $e for date: $dateString');
      return dateString;
    }
  }

  // 2. กำหนดสีตามสถานะ
  Color _getStatusColor(String? action) {
    if (action == null) return Colors.orangeAccent.shade100;
    final normalizedAction = action.toLowerCase();
    if (normalizedAction == 'approved') {
      return Colors.greenAccent.shade100;
    }
    if (normalizedAction == 'rejected' || normalizedAction == 'cancelled') {
      return Colors.redAccent.shade100;
    }
    return Colors.orangeAccent.shade100;
  }

  // ------------------------------------
  // ### 🎨 UI Components
  // ------------------------------------

  // Widget สำหรับ Filter Button
  Widget _buildFilterButton(String label) {
    final bool isSelected = selectedFilter == label;
    final String displayLabel = label.toUpperCase();

    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            selectedFilter = label;
          });
        },
        icon: isSelected
            ? const Icon(Icons.check, color: Colors.black, size: 18)
            : const SizedBox.shrink(),
        label: Text(
          displayLabel,
          style: TextStyle(
            color: Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? Colors.lightBlue.shade200 : Colors.grey.shade200,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          elevation: isSelected ? 2 : 0,
        ),
      ),
    );
  }

  // Widget สำหรับแสดงรายการประวัติการจอง
  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final String roomName = item['Room_name'] ?? 'Unknown Room';
    final String slotLabel = item['Slot_label'] ?? 'N/A';
    final String bookingDate = _formatDate(item['booking_date']);
    final String action = item['action'] ?? 'Pending';
    final String username = item['username'] ?? 'N/A';
    final Color statusColor = _getStatusColor(action);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                roomName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333), // darkGrey
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  action.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF333333), // darkGrey
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Requested by: $username',
            style: TextStyle(
              color: Colors.blueGrey.shade700,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(bookingDate, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 20),
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(slotLabel, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  // ⭐️ [เพิ่ม] ฟังก์ชันสำหรับ BottomNavigationBar
  void _onItemTapped(int index) {
    if (index == _currentIndex) {
      return; // ไม่ต้องทำอะไรถ้าเลือกแท็บเดิม
    }

    setState(() {
      _currentIndex = index;
    });

    // Navigation ไปยังหน้าต่างๆ
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Browse_Lecturer(
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
      case 3: // Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage_Staff(
              userID: widget.userID,
              userRole: widget.userRole,
            ),
          ),
        );
        break;
      case 4: // History (หน้าปัจจุบัน)
        break;
      // case 5: // User
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => Profile(
      //         userID: widget.userID,
      //         userRole: widget.userRole,
      //       ),
      //     ),
      //   );
      //   break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F7FF), // lightPageBg (สีพื้นหลัง)
      // ⭐️ [เพิ่ม] AppBar
      appBar: AppBar(
        title: const Text(
          "History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E63F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: refreshHistory, // ⭐️ เรียกฟังก์ชัน Refresh
          ),
        ],
      ),

      // โค้ด Body เดิมของคุณ (สมบูรณ์ดีแล้ว)
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: Color(0xFF9DB8C6), // สีฟ้าเทาอ่อน
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Current User: $currentUserName',
                  style: const TextStyle(
                    color: Color(0xFF9DB8C6), // สีฟ้าเทาอ่อน
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterButton('All'),
                const SizedBox(width: 8),
                _buildFilterButton('approved'),
                const SizedBox(width: 8),
                _buildFilterButton('rejected'),
              ],
            ),
            const SizedBox(height: 20),

            // History List (FutureBuilder)
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  // 1. Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1E63F3)), // ⭐️ ปรับสี
                      ),
                    );
                  }

                  // 2. Error
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final allBookings = snapshot.data ?? [];

                  // 3. Filter ข้อมูล
                  List<Map<String, dynamic>> filteredBookings =
                      allBookings.where((b) {
                    if (selectedFilter == 'All') return true;
                    return (b['action'] as String?)?.toLowerCase() ==
                        selectedFilter.toLowerCase();
                  }).toList();

                  // 4. No Data
                  if (filteredBookings.isEmpty) {
                    return Center(
                      child: Text(
                        allBookings.isEmpty
                            ? 'No booking history found.'
                            : 'No bookings found for "${selectedFilter.toUpperCase()}".',
                      ),
                    );
                  }

                  // 5. Display List
                  return ListView.builder(
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      return _buildHistoryItem(filteredBookings[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ⭐️ [เพิ่ม] BottomNavigationBar
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
}