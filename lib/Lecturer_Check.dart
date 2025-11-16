import 'package:flutter/material.dart';
import 'BottomNav.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// หน้านี้รับ requestData มาจากหน้า Lecturer_req
class CheckPage extends StatelessWidget {
  final Map<String, dynamic>? requestData;

  const CheckPage({super.key, this.requestData});

  // ใช้ IP เดียวกับหน้า Login (Android Emulator → 10.0.2.2)
  static const String baseUrl = 'http://10.0.2.2:3000';

  // 🔹 เรียก API เพื่อเปลี่ยนสถานะ booking (approve / reject)
  Future<void> _updateStatus(BuildContext context, String action) async {
    final data = requestData;
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No booking data.')),
      );
      return;
    }

    // 👇 เปลี่ยนให้ตรงกับ field id ที่ backend ส่งมา
    final bookingId = data['booking_id'] ?? data['id'];

    if (bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบ booking_id ในข้อมูลที่ส่งมา')),
      );
      return;
    }

    // ตัวอย่าง endpoint:
    //  POST /bookings/:id/approve
    //  POST /bookings/:id/reject
    final url = Uri.parse('$baseUrl/bookings/$bookingId/$action');

    try {
      final res = await http.post(url);

      if (res.statusCode == 200) {
        // ✅ สำเร็จ → กลับหน้า History ให้ FutureBuilder โหลดข้อมูลใหม่จาก DB
        Navigator.pushReplacementNamed(context, '/history');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('อัปเดตสถานะไม่สำเร็จ (Code: ${res.statusCode})'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้: $e'),
        ),
      );
    }
  }

  // แปลงวันที่จาก string (ISO) → รูปแบบอ่านง่าย
  String _formatDate(String? dateString) {
    if (dateString == null) return 'No Date';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateString));
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = requestData;

    if (data == null) {
      // ถ้าไม่มีข้อมูลส่งมา (ปกติจะไม่เกิดเพราะเราจะเข้าหน้านี้จาก Lecturer_req)
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D47A1),
          centerTitle: true,
          title: const Text(
            'Check status',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(
          child: Text('No booking selected.'),
        ),
        bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
      );
    }

    // ✅ เตรียมข้อมูลจาก requestData (key ให้ตรงกับที่ Lecturer_req ใช้)
    final String image = (data['image'] as String?) ?? 'Assets/imgs/room1.jpg';
    final String roomName = data['roomName'] ?? 'No Name';
    final String price = (data['price'] != null)
        ? '${data["price"]} THB/HOUR'
        : 'No Price';
    final String username = data['username'] ?? 'No User';
    final String time = data['time'] ?? 'No Time';
    final String date = _formatDate(data['date']);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
        title: const Text(
          'Check status',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: _RequestCard(
            image: image,
            roomName: roomName,
            price: price,
            username: username,
            date: date,
            time: time,
            // 🟢 กด Approve → call API /bookings/:id/approve
            onApprove: () => _updateStatus(context, 'approve'),
            // 🔴 กด Reject → call API /bookings/:id/reject
            onReject: () => _updateStatus(context, 'reject'),
          ),
        ),
      ),
      // ตอนนี้ใน BottomNav index 2 จะเด้งไป Dashboard อยู่แล้ว (เราแก้ไปก่อนหน้า)
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    );
  }
}

/// การ์ดแสดงรายละเอียด booking + ปุ่ม Approve/Reject
class _RequestCard extends StatelessWidget {
  final String image, roomName, price, username, date, time;
  final VoidCallback onApprove, onReject;

  const _RequestCard({
    required this.image,
    required this.roomName,
    required this.price,
    required this.username,
    required this.date,
    required this.time,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    // Widget แสดงภาพ (รองรับทั้ง asset / network)
    final errorWidget = Container(
      width: 72,
      height: 72,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, size: 20),
    );

    Widget imageWidget;
    if (image.startsWith('http')) {
      imageWidget = Image.network(
        image,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => errorWidget,
      );
    } else {
      imageWidget = Image.asset(
        image,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => errorWidget,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9F4FF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // แถวข้อมูลหลัก
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageWidget,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roomName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(date, style: const TextStyle(fontSize: 11)),
                  const SizedBox(height: 6),
                  Text(username, style: const TextStyle(fontSize: 11)),
                  const SizedBox(height: 6),
                  Text(time, style: const TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ปุ่ม Approve / Reject
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: onApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8CF28E),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                child: const Text('Approve'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onReject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7C7C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                child: const Text('Reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
