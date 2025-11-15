import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? requestData;

  const CheckPage({super.key, required this.userId, this.requestData});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  bool _isLoading = false;

  Future<void> _updateBookingStatus(String newStatus) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final bookingId = widget.requestData?['Booking_id'];

    if (bookingId == null) {
      print("Error: Booking ID is null!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาด: ไม่พบ Booking ID'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
      'http://172.27.9.232:3000/bookings/$bookingId/status',
    );

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'new_status': newStatus}),
      );

      if (response.statusCode == 200) {
        // ---  สำเร็จ ---
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('updated status to"$newStatus"Successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // กลับไปหน้า List พร้อมส่งสัญญาณให้ Refresh (true)
        Navigator.pop(context, true);
      } else {
        // --- ❌ ล้มเหลว (Server มีปัญหา) ---
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('updated faild: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // --- ❌ ล้มเหลว (เช่น ไม่มีเน็ต) ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('server error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.requestData;

    if (data == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text(
            'Room reservation request not found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // ส่วนแปลงข้อมูล
    String finalImage = (data["image"] as String?) ?? 'assets/imgs/room1.jpg';
    String finalRoomName = data["roomName"] ?? 'No Name';
    String finalPrice = (data["price"] != null)
        ? '${data["price"]} THB/HOUR'
        : 'No Price';
    String finalUsername = data["username"] ?? 'No User';
    String finalDate = 'No Date';
    String finalTime = data["time"] ?? 'No Time';
    try {
      if (data["date"] != null) {
        final dateTime = DateTime.parse(data["date"]);
        finalDate = DateFormat('dd/MM/yyyy').format(dateTime.toLocal());
      }
    } catch (e) {
      finalDate = data["date"] ?? 'Invalid Date';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(finalRoomName),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: _RequestCard(
            image: finalImage,
            roomName: finalRoomName,
            price: finalPrice,
            username: finalUsername,
            date: finalDate,
            time: finalTime,
            // เชื่อมปุ่มเข้ากับฟังก์ชัน API (ส่ง null เมื่อกำลังโหลด)
            onApprove: _isLoading
                ? null
                : () => _updateBookingStatus('approved'),
            onReject: _isLoading
                ? null
                : () => _updateBookingStatus('rejected'),
          ),
        ),
      ),
    );
  }
}

/// การ์ดคำขอแต่ละรายการ
class _RequestCard extends StatelessWidget {
  final String image, roomName, price, username, date, time;
  final VoidCallback? onApprove, onReject;

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

          // ⭐️ ปุ่ม Approve / Reject
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
                // ✅ แก้ไข: ต้องเช็ค onApprove == null
                child: (onApprove == null)
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text('Approve'),
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
                // ✅ โค้ดนี้ถูกต้องแล้ว: เช็ค onReject == null
                child: (onReject == null)
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
