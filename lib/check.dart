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
  final String serverIp = '192.168.1.36';

  @override
  void initState() {
    super.initState();
    _bookingsFuture = fetchPendingBookings();
  }

  Future<List<dynamic>> fetchPendingBookings() async {
    final url = Uri.parse('http://$serverIp:3000/check?user_id=${widget.userId}');
    
    print("📡 Fetching PENDING bookings for user: ${widget.userId}");
    
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      print("📊 Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        // ✅ กรองเอาเฉพาะ pending
        final pendingBookings = data.where((item) {
          final status = item['status']?.toString().toLowerCase() ?? '';
          return status == 'pending';
        }).toList();
        
        print("✅ Pending bookings: ${pendingBookings.length} items");
        return pendingBookings;
      } else {
        throw Exception('Failed to load bookings (Status: ${response.statusCode})');
      }
    } catch (e) {
      print("🚨 Error fetching pending bookings: $e");
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
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _bookingsFuture = fetchPendingBookings();
    });
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
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading data:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _refreshData,
                        child: const Text('Retry'),
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
                    const Icon(Icons.pending_actions, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No pending booking requests.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('Refresh'),
                    ),
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
                final String status = item['status']?.toString().toLowerCase() ?? 'pending';

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            child: Image.asset(
              imageUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 120,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.meeting_room, color: Colors.grey, size: 40),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roomNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pending,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 6),
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
          ),
        ],
      ),
    );
  }
}