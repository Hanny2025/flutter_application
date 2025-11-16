import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// ----------------------------------------
// ## 📅 HistoryPage (หน้าประวัติการจอง)
// ----------------------------------------
class HistoryPage extends StatefulWidget {
  final String userId;

  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // --- Constants & State Variables ---
  String selectedFilter = 'All';
  String currentUserName = 'Loading...';

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
      final String? userName = prefs.getString('user_name');
      setState(() {
        currentUserName = userName ?? 'Lecturer';
      });
    } catch (e) {
      debugPrint('Error loading user name: $e');
      setState(() {
        currentUserName = 'Error Loading Name';
      });
    }

    // 🚀 ดึงประวัติการจอง
    return _fetchBookings();
  }

  // 2. ฟังก์ชันดึง History จาก API และทำการจัดเรียง 🔄
  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    final url = Uri.parse('$_baseUrl/staff/history');
    debugPrint('Fetching ALL history from: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        List<Map<String, dynamic>> bookings = data
            .map((item) => item as Map<String, dynamic>)
            .toList();

        // ✅ **แก้ไข: จัดเรียงตามเวลาที่รายการถูกสร้าง (created_at) หรือดำเนินการ (action_at) ล่าสุด**
        // 💡 หากไม่มีฟิลด์ 'created_at' หรือ 'action_at' จะย้อนกลับไปใช้ 'booking_date' แทน
        bookings.sort((a, b) {
          // ดึงค่า timestamp ที่น่าจะถูกต้องที่สุด
          final timestampA =
              a['created_at'] ?? a['action_at'] ?? a['booking_date'] ?? '';
          final timestampB =
              b['created_at'] ?? b['action_at'] ?? b['booking_date'] ?? '';

          final dateA = DateTime.tryParse(timestampA) ?? DateTime(1970);
          final dateB = DateTime.tryParse(timestampB) ?? DateTime(1970);

          // การเปรียบเทียบ: b.compareTo(a) สำหรับการเรียงจากมากไปน้อย (ล่าสุดไปเก่าสุด)
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

  // 1. Format วันที่ (แก้ไขเวอร์ชัน)
  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      // แยกส่วนวันที่และเวลาเพื่อป้องกัน timezone issues
      DateTime dateTime = DateTime.parse(dateString);

      // ใช้ local timezone ของ device
      dateTime = dateTime.toLocal();

      // หรือถ้าต้องการให้เป็นเวลาไทยโดยเฉพาะ
      // dateTime = dateTime.add(const Duration(hours: 7));

      return DateFormat('d MMM yyyy').format(dateTime);
    } catch (e) {
      debugPrint('Date parsing error: $e for date: $dateString');
      return dateString;
    }
  }

  // 2. กำหนดสีตามสถานะการดำเนินการ
  Color _getStatusColor(String? action) {
    if (action == null) return Colors.orangeAccent.shade100;

    final normalizedAction = action.toLowerCase();

    if (normalizedAction == 'approved') {
      return Colors.greenAccent.shade100;
    }
    if (normalizedAction == 'rejected' || normalizedAction == 'cancelled') {
      return Colors.redAccent.shade100;
    }
    // สำหรับ 'pending' หรือสถานะอื่น ๆ
    return Colors.orangeAccent.shade100;
  }

  // ------------------------------------
  // ### 🎨 UI Components
  // ------------------------------------

  // Widget สำหรับ Filter Button
  Widget _buildFilterButton(String label) {
    final bool isSelected = selectedFilter == label;
    final String displayLabel = label
        .toUpperCase(); // ทำให้ตัวใหญ่เพื่อความสวยงาม

    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            selectedFilter = label;
          });
        },
        // Icon สำหรับสถานะที่ถูกเลือก
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
          backgroundColor: isSelected
              ? Colors
                    .lightBlue
                    .shade200 // ใช้สีฟ้าอ่อนเมื่อถูกเลือก
              : Colors.grey.shade200,
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
                  action.toUpperCase(), // แสดงสถานะเป็นตัวพิมพ์ใหญ่
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // เพิ่ม Scaffold เพื่อให้มีโครงสร้างหน้าจอที่ถูกต้อง
      backgroundColor: const Color(0xFFE7F7FF), // lightPageBg (สีพื้นหลัง)
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
                        // 💡 เปลี่ยนเป็น .toLowerCase() เพื่อให้ Filter ตรงกัน
                        return (b['action'] as String?)?.toLowerCase() ==
                            selectedFilter.toLowerCase();
                      })
                      .toList();

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
    );
  }
}