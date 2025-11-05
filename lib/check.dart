import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // 👈 (1. เพิ่ม) สำหรับจัดรูปแบบวันที่

// --- Constants ---
const Color primaryBlue = Color(0xFF1976D2);
const Color darkGrey = Color(0xFF333333);

// --- Main Screen Class (Check) ---
class Check extends StatefulWidget {
  const Check({super.key});

  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  // ‼️ (2. เพิ่ม) State ใหม่สำหรับ FutureBuilder
  late Future<List<dynamic>> _bookingsFuture;
  final String serverIp = '10.2.21.252';

  // ‼️ (3. เพิ่ม) ID ของผู้ใช้ปัจจุบัน
  // (สำคัญ!) ปกติค่านี้ต้องมาจากหน้า Login/SharedPreferences
  // ตอนนี้ขอใส่เลข 1 จำลองไปก่อน
  final int currentUserId = 1;

  // ‼️ (4. ลบ) ลบ List ข้อมูลจำลอง (statusList) ทิ้ง

  @override
  void initState() {
    super.initState();
    // ‼️ (5. เพิ่ม) สั่งให้โหลดข้อมูลเมื่อหน้านี้ถูกสร้าง
    _bookingsFuture = fetchMyBookings();
  }

  // ‼️ (6. เพิ่ม) ฟังก์ชันสำหรับเรียก API /my-bookings
  Future<List<dynamic>> fetchMyBookings() async {
    final url = Uri.parse('http://$serverIp:3000/check?user_id=$currentUserId');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // คืนค่า List ของ bookings (e.g., [ {...}, {...} ])
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception(
          'Failed to load bookings (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  // ‼️ (7. เพิ่ม) ฟังก์ชัน helpers สำหรับแปลงข้อมูล
  // (ย้ายมาจากใน Card)
  Color _mapStatusToColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending...':
        return const Color(0xFFC7B102); // เหลืองเข้ม
      case 'approved': // (ถ้าคุณมีสถานะนี้ในอนาคต)
        return const Color(0xFF00B909); // เขียว
      case 'rejected': // (ถ้าคุณมีสถานะนี้ในอนาคต)
        return const Color(0xFFD32F2F); // แดง
      default:
        return Colors.grey;
    }
  }

  Color _mapStatusToBgColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending...':
        return const Color(0xFFF9F7A2); // เหลืองอ่อน
      case 'approved':
        return const Color(0xFFB1F1B7); // เขียวอ่อน
      case 'rejected':
        return const Color(0xFFF9A2A2); // แดงอ่อน
      default:
        return Colors.grey.shade200;
    }
  }

  // Helper สำหรับจัดรูปแบบวันที่
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'No Date';
    try {
      final DateTime date = DateTime.parse(dateStr);
      // "Oct 19, 2025"
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateStr; // คืนค่าเดิมถ้าแปลงไม่ได้
    }
  }

  // Helper สำหรับจัดรูปแบบเวลา (HH:mm:ss -> HH:mm)
  String _formatTime(String? timeStr) {
    if (timeStr == null) return 'N/A';
    try {
      // 13:00:00
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}'; // "13:00"
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. AppBar (เหมือนเดิม)
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // ‼️ (แก้) เอาปุ่ม Back ออก (เพราะเป็นแท็บ)
        toolbarHeight: 100,
        backgroundColor: primaryBlue,
        centerTitle: true,
        title: const Text(
          'Check Request Status', // (แก้ Chek -> Check)
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ‼️ (8. แก้ไข) 2. Body: เปลี่ยนเป็น FutureBuilder
      body: FutureBuilder<List<dynamic>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          // --- Case 1: กำลังโหลด ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Case 2: โหลด Error ---
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Error loading data:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // --- Case 3: โหลดสำเร็จ แต่ไม่มีข้อมูล ---
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'You have no booking requests.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // --- Case 4: โหลดสำเร็จ และมีข้อมูล ---
          final List<dynamic> bookings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final item = bookings[index] as Map<String, dynamic>;

              // ‼️ (9. เพิ่ม) ส่งข้อมูลจริงไปให้ Card
              // (แปลงข้อมูลที่ได้จาก Server ให้เป็นรูปแบบที่ Card ต้องการ)
              final String status = item['status'] ?? 'Unknown';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: StatusCard(
                  imageUrl: item['image_url'] ?? 'assets/imgs/default.jpg',
                  roomNumber: item['Room_name'] ?? 'No Name',
                  date: _formatDate(item['booking_date']),
                  time:
                      '${_formatTime(item['start_time'])} - ${_formatTime(item['end_time'])}',
                  status: status,
                  statusColor: _mapStatusToColor(status),
                  backgroundColor: _mapStatusToBgColor(status),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------------
// WIDGETS ย่อย: Card (StatusCard)
// ------------------------------------------------------------------
class StatusCard extends StatelessWidget {
  // ‼️ (10. แก้ไข) เปลี่ยนจาก Model เป็นรับค่าตรงๆ
  final String imageUrl;
  final String roomNumber;
  final String date;
  final String time;
  final String status;
  final Color statusColor;
  final Color backgroundColor;

  const StatusCard({
    super.key,
    required this.imageUrl,
    required this.roomNumber,
    required this.date,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รูปภาพห้อง (ซ้ายมือ)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            child: Image.asset(
              // ‼️ (หมายเหตุ) ถ้า image_url เป็น http ให้ใช้ Image.network
              imageUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 120,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
          ),

          // รายละเอียดคำขอ (ขวามือ)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roomNumber, // 👈 ใช้ค่าที่ส่งมา
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date, // 👈 ใช้ค่าที่ส่งมา
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  Text(
                    time, // 👈 ใช้ค่าที่ส่งมา
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),

                  // สถานะ (Pending/Approved/Rejected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor, // 👈 ใช้ค่าที่ส่งมา
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: statusColor.withOpacity(
                          0.5,
                        ), // 👈 ใช้ค่าที่ส่งมา
                      ),
                    ),
                    child: Text(
                      status, // 👈 ใช้ค่าที่ส่งมา
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor, // 👈 ใช้ค่าที่ส่งมา
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
