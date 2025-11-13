import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  // รับค่า userId สำหรับส่งต่อใน BottomNav
  final String userId;

  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // --- Constants & State Variables ---
  String selectedFilter = 'All';
  String currentUserName = 'Loading...';
  int _selectedIndex = 2; // History tab index
  static const Color primaryBlue = Color(0xFF0D47A1);

  // Base URL
  final String _baseUrl = 'http://10.2.21.252:3000';

  // Future สำหรับโหลดข้อมูลประวัติการจอง (สามารถ Refresh ได้)
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadPageData();
  }

  // ------------------------------------
  //            Data Fetching
  // ------------------------------------

  // 1. โหลดข้อมูล Lecturer Name และเริ่มดึง History
  Future<List<Map<String, dynamic>>> _loadPageData() async {
    final prefs = await SharedPreferences.getInstance();

    // ดึงชื่อ Lecturer มาแสดง
    final String? userName = prefs.getString('user_name');

    setState(() {
      currentUserName = userName ?? 'Lecturer';
    });

    // ดึงข้อมูล History ทั้งหมดสำหรับ Admin/Lecturer
    return _fetchBookings();
  }

  // 2. ฟังก์ชันดึง History จาก API
  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    final url = Uri.parse('$_baseUrl/history/all');
    print('Fetching ALL history from: $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
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
  void _refreshHistory() {
    setState(() {
      // กำหนดค่า Future ใหม่เพื่อให้ FutureBuilder โหลดซ้ำ
      _historyFuture = _loadPageData();
      selectedFilter = 'All'; // รีเซ็ต Filter
    });
    print('History list refreshed.');
  }

  // ------------------------------------
  //            Helper Functions
  // ------------------------------------

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      return DateFormat('d MMM yyyy').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String? action) {
    if (action == 'Approved') {
      return Colors.greenAccent.shade100;
    }
    if (action == 'Rejected' || action == 'Cancelled') {
      return Colors.redAccent.shade100;
    }
    return Colors.orangeAccent.shade100; // Pending
  }

  // ------------------------------------
  //            UI Components
  // ------------------------------------

  // จัดการการแตะที่ BottomNavigationBar
  void _onItemTapped(int index) {
    // ถ้าแตะแท็บ History ซ้ำ ให้ Refresh ข้อมูลแทนการนำทาง
    if (index == _selectedIndex) {
      _refreshHistory();
      return;
    }

    // นำทางไปยังหน้าอื่น
    final routes = {0: '/home', 1: '/check', 2: '/history', 3: '/user'};
    Navigator.pushReplacementNamed(
      context,
      routes[index]!,
      arguments: widget.userId,
    );
  }

  // Widget สำหรับ Filter Button
  Widget _buildFilterButton(String label) {
    final bool isSelected = selectedFilter == label;
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
          label,
          style: TextStyle(
            color: Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Colors.grey.shade400
              : Colors.grey.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. AppBar พร้อมปุ่ม Refresh
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshHistory, // ฟังก์ชัน Refresh
            tooltip: 'Refresh History',
          ),
        ],
      ),

      // 2. Body
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงชื่อผู้ใช้ปัจจุบัน
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: Color.fromARGB(255, 157, 184, 198),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  currentUserName,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 157, 184, 198),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter buttons
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

            // FutureBuilder เพื่อแสดงรายการ History
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  // 1. Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 2. Error
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final allBookings = snapshot.data ?? [];

                  // 3. Filter ข้อมูลตามสถานะ
                  List<Map<String, dynamic>> filteredBookings = allBookings
                      .where((b) {
                        if (selectedFilter == 'All') return true;
                        return b['action'] == selectedFilter;
                      })
                      .toList();

                  // 4. No Data
                  if (filteredBookings.isEmpty) {
                    return Center(
                      child: Text(
                        allBookings.isEmpty
                            ? 'No booking history found.'
                            : 'No bookings found for "$selectedFilter".',
                      ),
                    );
                  }

                  // 5. Display List
                  return ListView.builder(
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final item = filteredBookings[index];
                      final String roomName =
                          item['Room_name'] ?? 'Unknown Room';
                      final String slotLabel = item['Slot_label'] ?? 'N/A';
                      final String bookingDate = _formatDate(
                        item['booking_date'],
                      );
                      final String action = item['action'] ?? 'Pending';
                      final String username = item['username'] ?? 'N/A';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roomName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'User: $username',
                              style: TextStyle(
                                color: Colors.blueGrey.shade700,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('$bookingDate   $slotLabel'),
                            const SizedBox(height: 8),

                            // Status Badge
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(action),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  action,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
