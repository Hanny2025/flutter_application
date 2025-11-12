// ...existing imports
import 'package:flutter/material.dart';
import 'BottomNav.dart';
import 'dart:async'; // 👈 สำหรับ Future

// 🔻 --- เพิ่ม imports สำหรับ API, SharedPreferences, และ Date Formatting ---
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
// 🔺 --- สิ้นสุดส่วนที่เพิ่ม ---

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedFilter = 'All';
  String currentUserName = 'Loading...';
  int? currentUserId; // 👈 [ 1. ชื่อ/ID ] สร้างตัวแปรสำหรับเก็บ User ID

  // ⚠️ เปลี่ยน URL นี้ให้เป็น Base URL ของ API จริงของคุณ
  final String _baseUrl =
      'http://10.2.21.252:3000'; // 👈 (10.0.2.2 คือ localhost สำหรับ Android Emulator)

  // 👈 [ 2. ข้อมูล ] สร้าง Future ที่จะใช้โหลดข้อมูลทั้งหมด
  late Future<List<Map<String, dynamic>>> _initFuture;

  @override
  void initState() {
    super.initState();
    // 👈 สั่งให้ FutureBuilder ทำงานกับฟังก์ชัน _loadPageData() นี้
    _initFuture = _loadPageData();
  }

  // ❗️ [ 1. ชื่อ/ID ]
  // ฟังก์ชันหลักที่ทำงานเมื่อเปิดหน้านี้
  // 1. โหลด User ID และ Name
  // 2. ถ้ามี ID, ไปดึง History ที่ตรงกับ ID นั้น
  Future<List<Map<String, dynamic>>> _loadPageData() async {
    final prefs = await SharedPreferences.getInstance();

    // ❗️ ในแอปจริง:
    // คุณ "ต้อง" บันทึก 'user_id' และ 'user_name' ลงใน SharedPreferences
    // ใน "หน้า Login" หลังจากที่ผู้ใช้ Login สำเร็จ
    //
    // ตัวอย่างโค้ดใน "หน้า Login" (หลังจาก login สำเร็จ):
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setInt('user_id', 123); // 👈 ID ที่ได้จาก API
    // await prefs.setString('user_name', 'Manager Sam'); // 👈 ชื่อที่ได้จาก API

    // --- ตอนนี้เราจะดึงค่านั้นออกมา ---
    final int? userId = prefs.getInt('user_id');
    final String? userName = prefs.getString('user_name');

    if (userId == null) {
      // ไม่พบ User ID (อาจจะยังไม่ Login)
      setState(() {
        currentUserName = 'Error: Not Logged In';
      });
      // คืนค่า List ว่าง หรือ โยน Error เพื่อให้ FutureBuilder แสดงผล
      throw Exception('User ID not found in SharedPreferences. Please log in.');
    }

    // ถ้าพบ ID, อัปเดต UI และไปขั้นตอนถัดไป
    setState(() {
      currentUserName = userName ?? 'User';
      currentUserId = userId;
    });

    // ❗️ [ 2. ข้อมูล ]
    // เรียกฟังก์ชันดึง History โดยส่ง ID ที่เราเพิ่งโหลดมา
    return _fetchBookings(userId);
  }

  // ❗️ [ 2. แก้ไขเรื่องการดึงข้อมูล ]
  // ฟังก์ชันดึงข้อมูลจาก Backend โดยต้องมี user_id
  Future<List<Map<String, dynamic>>> _fetchBookings(int userId) async {
    // สร้าง URL ให้ตรงกับที่ Backend ต้องการ: /history?user_id=...
    final url = Uri.parse('$_baseUrl/history?user_id=$userId');

    print('Fetching history from: $url'); // 👈 debug

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

  // -----------------------------------------------------------------
  // 🔹 🔹 🔹 Helper Functions (ฟังก์ชันตัวช่วย) 🔹 🔹 🔹
  // -----------------------------------------------------------------

  // ฟังก์ชันสำหรับแปลง Date String (เช่น "2025-10-21T...") ให้อ่านง่าย
  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      // 👈 ใช้ package 'intl'
      return DateFormat('d MMM yyyy').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString; // คืนค่าเดิมถ้าแปลงไม่ได้
    }
  }

  // ฟังก์ชันสำหรับกำหนดสีของ Status (action)
  Color _getStatusColor(String? action) {
    if (action == 'Approved') {
      return Colors.greenAccent.shade100;
    }
    if (action == 'Rejected' || action == 'Cancelled') {
      return Colors.redAccent.shade100;
    }
    // 'Booked', 'Pending', หรืออื่นๆ
    return Colors.orangeAccent.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // ... (ส่วน AppBar เหมือนเดิม) ...
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text(
          'Booking History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16), child: Row()),
        ],
      ),

      // Body
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 [ 1. แก้ไขเรื่องชื่อ ] - แสดงชื่อผู้ใช้ (ที่ดึงมา)
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: Color.fromARGB(255, 157, 184, 198),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  currentUserName, // 👈 ใช้ตัวแปรที่ดึงมา
                  style: const TextStyle(
                    color: Color.fromARGB(255, 157, 184, 198),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🔹 Filter buttons (full width row)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildFilterButton('All')),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterButton('Approved')),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterButton('Rejected')),
                // 💡 คุณอาจจะเพิ่ม 'Booked' หรือ 'Cancelled' ที่นี่ได้
              ],
            ),
            const SizedBox(height: 20),

            // 🔹 [ 2. แก้ไขเรื่องการดึงข้อมูล ] - ใช้ FutureBuilder
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future:
                    _initFuture, // 👈 สั่งให้รอ Future ที่เราสร้างใน initState
                builder: (context, snapshot) {
                  // 1. ขณะกำลังรอข้อมูล (จาก _loadPageData)
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 2. ถ้ามีข้อผิดพลาด (เช่น Login ไม่เจอ, API ล่ม)
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // 3. ถ้าไม่มีข้อมูล หรือข้อมูลเป็น 0
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No booking history found.'),
                    );
                  }

                  // 4. ถ้ามีข้อมูลสำเร็จ
                  final allBookings = snapshot.data!;

                  // ❗️❗️❗️ เปลี่ยนตรรกะการกรอง
                  List<Map<String, dynamic>>
                  filteredBookings = allBookings.where((b) {
                    if (selectedFilter == 'All') return true;
                    // ❗️ เปลี่ยนจาก 'status' เป็น 'action' ให้ตรงกับ Backend
                    return b['action'] == selectedFilter;
                  }).toList();

                  // (กรณีย่อย) ถ้าข้อมูลที่กรองแล้วไม่มี
                  if (filteredBookings.isEmpty) {
                    return Center(
                      child: Text('No bookings found for "$selectedFilter".'),
                    );
                  }

                  // 5. แสดงผล List
                  return ListView.builder(
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final item = filteredBookings[index];

                      // ❗️❗️❗️ เปลี่ยน field ให้ตรงกับ Backend
                      final String roomName =
                          item['Room_name'] ?? 'Unknown Room';
                      final String slotLabel = item['Slot_label'] ?? 'N/A';
                      final String bookingDate = _formatDate(
                        item['booking_date'],
                      );
                      final String action = item['action'] ?? 'Pending';

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
                              roomName, // 👈 ใช้ field จาก API
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // 👈 ใช้ field จาก API
                            Text('$bookingDate   $slotLabel'),

                            // ❗️ ลบ 'Booked by' และ 'Approved by'
                            // (เพราะ API ไม่ได้ส่งมา, ถ้าอยากได้ ต้องแก้ SQL ที่ Backend)
                            // Text('Booked by ${item['bookedBy']}'),
                            // Text('Approved by ${item['approvedBy']}'),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  // 👈 ใช้ field 'action' และ helper
                                  color: _getStatusColor(action),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  action, // 👈 ใช้ field 'action'
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

      // Bottom navigation bar
      bottomNavigationBar: const AppBottomNavigationBar(
        currentIndex: 3,
      ), // History tab
    );
  }

  // 🔹 Filter Button Widget (with checkmark)
  // (ฟังก์ชันนี้เหมือนเดิม ไม่ต้องแก้ไข)
  Widget _buildFilterButton(String label) {
    final bool isSelected = selectedFilter == label;
    return ElevatedButton.icon(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
