import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

const Color primaryBlue = Color(0xFF1976D2);
const Color darkGrey = Color(0xFF333333);

class Check extends StatefulWidget {
  final String userId;
  const Check({super.key, required this.userId});

  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  late Future<List<dynamic>> _bookingsFuture;
  final String serverIp = '26.122.43.191';

  @override
  void initState() {
    super.initState();
    _bookingsFuture = fetchPendingBookings();
  }

  Future<List<dynamic>> fetchPendingBookings() async {
    final url = Uri.parse(
      'http://$serverIp:3000/check?user_id=${widget.userId}',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;

        final pendingBookings = data.where((item) {
          final status = item['status']?.toString().toLowerCase() ?? '';
          return status == 'pending';
        }).toList();

        return pendingBookings;
      } else {
        throw Exception(
          'Failed to load bookings (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch pending bookings: $e');
    }
  }

  Color _mapStatusToColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return const Color(0xFFC7B102); // เหลือง
      default:
        return Colors.grey;
    }
  }

  Color _mapStatusToBgColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF9F7A2); // เหลืองอ่อน
      default:
        return Colors.grey.shade200;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'No Date';
    try {
      // 1. แปลงสตริงให้เป็น DateTime
      final DateTime date = DateTime.parse(dateStr);

      // 2. แปลงเป็นเวลาท้องถิ่นของอุปกรณ์ (สำคัญ!)
      // ถ้า dateStr เป็น UTC, .toLocal() จะปรับวันที่/เวลา ให้ตรงกับ Timezone ของอุปกรณ์
      final DateTime localDate = date.toLocal();

      // 3. จัดรูปแบบเฉพาะวันที่
      // DateFormat.yMMMd().format(localDate) จะดีกว่าเพราะรองรับ Locale
      return DateFormat('MMM d, yyyy').format(localDate);
    } catch (e) {
      // ในกรณีที่สตริงเป็นแค่ "YYYY-MM-DD" ที่ไม่มีเวลา
      if (dateStr.length <= 10) {
        // ให้ใช้ DateFormat.yMMMd() เพื่อจัดการกับสตริงวันที่เท่านั้น
        try {
          final DateTime dateOnly = DateFormat('yyyy-MM-dd').parse(dateStr);
          return DateFormat('MMM d, yyyy').format(dateOnly);
        } catch (_) {
          return dateStr;
        }
      }
      return dateStr;
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _bookingsFuture = fetchPendingBookings();
    });
  }

  // Alias used by AppBar/other widgets for consistency with other pages
  // Keeps the method signature synchronous (void) so it can be passed
  // directly to IconButton.onPressed without type issues.
  void _refreshRoomData() {
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: primaryBlue,
        centerTitle: true,
        title: const Text(
          'Pending Requests',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _refreshRoomData,
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<dynamic>>(
          future: _bookingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading data:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.pending_actions,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No pending booking requests.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }

            final List<dynamic> bookings = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final item = bookings[index];
                final String status =
                    item['status']?.toString().toLowerCase() ?? 'pending';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: StatusCard(
                    imageUrl: 'assets/imgs/room.jpg',
                    roomNumber: item['Room_name']?.toString() ?? 'No Name',
                    date: _formatDate(item['booking_date']?.toString()),
                    time: item['Slot_label']?.toString() ?? 'N/A',
                    status: status,
                    statusColor: _mapStatusToColor(status),
                    backgroundColor: _mapStatusToBgColor(status),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-width image at top
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Image.asset(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.meeting_room, color: Colors.grey, size: 50),
                ),
              ),
            ),
          ),
          // Details section below image
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkGrey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pending, size: 18, color: statusColor),
                      const SizedBox(width: 8),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
