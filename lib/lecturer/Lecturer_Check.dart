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
  bool _isLoading = false; // สำหรับปุ่ม Approve/Reject
  bool _loadingData = true; // สำหรับตอนโหลดข้อมูล
  Map<String, dynamic>? _bookingData;

  @override
  void initState() {
    super.initState();
    _loadData(); // 🔹 เรียกโหลดข้อมูลตอนเปิดหน้า
  }

  // 🔹 ฟังก์ชันโหลดข้อมูลจาก backend
  Future<void> _loadData() async {
    final data = await _fetchBookingDetail();
    setState(() {
      _bookingData = data ?? widget.requestData;
      _loadingData = false;
    });
  }

  // 🔹 ฟังก์ชัน GET ดึงข้อมูลการจองจาก backend
  Future<Map<String, dynamic>?> _fetchBookingDetail() async {
    final bookingId = widget.requestData?['Booking_id'];
    if (bookingId == null) return null;

    try {
      final url = Uri.parse('http://10.2.21.252:3000/bookings/$bookingId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ Booking Detail: $data");
        return data;
      } else {
        print("❌ Error fetching booking: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Exception: $e");
      return null;
    }
  }

  // 🔹 ฟังก์ชัน PATCH อัปเดตสถานะการจอง
  Future<void> _updateBookingStatus(String newStatus) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final bookingId =
        _bookingData?['Booking_id'] ?? widget.requestData?['Booking_id'];

    if (bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Booking ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    final url = Uri.parse('http://10.2.21.252:3000/bookings/$bookingId/status');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'new_status': newStatus}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated status to "$newStatus" successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔸 ถ้ายังโหลดข้อมูลอยู่
    if (_loadingData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final data = _bookingData;
    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Check Booking")),
        body: const Center(
          child: Text(
            'Room reservation request not found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // 🔸 เตรียมข้อมูลแสดงผล
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
            onApprove: _isLoading
                ? null
                : () => _updateBookingStatus('approved'),
            onReject: _isLoading
                ? null
                : () => _updateBookingStatus('rejected'),
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }
}

/// การ์ดแสดงข้อมูลการจอง + ปุ่ม Approve / Reject
class _RequestCard extends StatelessWidget {
  final String image, roomName, price, username, date, time;
  final VoidCallback? onApprove, onReject;
  final bool isLoading;

  const _RequestCard({
    required this.image,
    required this.roomName,
    required this.price,
    required this.username,
    required this.date,
    required this.time,
    required this.onApprove,
    required this.onReject,
    required this.isLoading,
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
                ),
                child: isLoading
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
                ),
                child: isLoading
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
