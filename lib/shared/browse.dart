import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../student/bookrequest.dart';
import '../student/check.dart';
import '../student/history.dart';
import 'profile.dart';

const Color primaryBlue = Color(0xFF1976D2);
const Color darkGrey = Color(0xFF333333);

class TimeSlot {
  final int slotId;
  final String label;
  final String status;
  final Color color;
  const TimeSlot({
    required this.slotId,
    required this.label,
    required this.status,
    required this.color,
  });
}

class RoomCard extends StatelessWidget {
  final String roomName;
  final List<TimeSlot> timeSlots;
  final Map<String, dynamic> roomData;
  final String userId;
  final String userRole; // ✅ รับ userRole
  final VoidCallback onBookingComplete;

  const RoomCard({
    super.key,
    required this.roomName,
    required this.timeSlots,
    required this.roomData,
    required this.userId,
    required this.userRole, // ✅ รับ userRole
    required this.onBookingComplete,
  });

  // ✅ ฟังก์ชันตรวจสอบว่ามี slot ที่จองได้สำหรับ Student หรือไม่
  bool _hasAvailableSlots() {
    if (userRole != 'Users') return true;

    final DateTime now = DateTime.now();
    return timeSlots.any((slot) {
      if (slot.status.toLowerCase() != 'free') return false;
      return _isFutureTimeSlot(slot.label, now);
    });
  }

  // ✅ ตรวจสอบว่า slot นี้ยังไม่ผ่านเวลา
  bool _isFutureTimeSlot(String slotLabel, DateTime now) {
    final timeMap = {
      '8:00-10:00': 8,
      '10:00-12:00': 10,
      '13:00-15:00': 13,
      '15:00-17:00': 15,
    };

    final startHour = timeMap[slotLabel];
    if (startHour == null) return true;

    final currentHour = now.hour;
    return currentHour < startHour;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ตรวจสอบเงื่อนไขเบื้องหลัง
    final bool canBook = _hasAvailableSlots();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Image.asset(
              'assets/imgs/room.jpg',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.business,
                    color: Colors.grey[600],
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roomName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...timeSlots
                          .map(
                            (slot) => Row(
                              children: [
                                Text(
                                  '${slot.label} - ',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  slot.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: slot.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // ✅ ตรวจสอบเงื่อนไขก่อนจอง
                    if (userRole == 'Users' && !canBook) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No available time slots for booking'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Bookrequest(
                          roomData: roomData,
                          userId: userId,
                          userRole: userRole, // ✅ ส่ง userRole ไป
                        ),
                      ),
                    );
                    if (result == true) {
                      onBookingComplete();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue, // ✅ UI เดิม สีเหมือนเดิม
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('Book'), // ✅ UI เดิม ป้ายเหมือนเดิม
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  final String userId;
  final String userRole;

  const HomeScreenContent({
    super.key,
    required this.userId,
    required this.userRole,
  });

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  late Future<List<dynamic>> _roomsFuture;
  final String serverIp = '172.27.9.232';

  @override
  void initState() {
    super.initState();
    _roomsFuture = fetchRooms();
  }

  Future<List<dynamic>> fetchRooms() async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final url = Uri.parse(
      'http://$serverIp:3000/rooms-with-status?date=$today',
    );
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      // Debug: log fetch result
      debugPrint('GET rooms -> url:$url status:${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        debugPrint('GET rooms -> received ${data.length} rooms');
        return data;
      } else {
        throw Exception(
          'Failed to load rooms (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch rooms: $e');
    }
  }

  // ✅ ฟังก์ชันตรวจสอบเงื่อนไข Student (ทำงานเบื้องหลัง)
  bool _isRoomAvailable(Map<String, dynamic> room) {
    final roomStatus = room['Room_status']?.toString().toLowerCase() ?? '';

    // ✅ ใช้ค่า enum ใหม่: 'free', 'pending', 'disabled'
    // ✅ แสดงเฉพาะห้องที่มีสถานะ 'free' หรือ 'pending'
    return roomStatus == 'free' || roomStatus == 'pending';
  }

  // ✅ ตรวจสอบว่า slot นี้ยังไม่ผ่านเวลา
  bool _isFutureTimeSlot(String slotLabel, DateTime now) {
    final timeMap = {
      '8:00-10:00': 8,
      '10:00-12:00': 10,
      '13:00-15:00': 13,
      '15:00-17:00': 15,
    };

    final startHour = timeMap[slotLabel];
    if (startHour == null) return true;

    final currentHour = now.hour;
    return currentHour < startHour;
  }

  Color _mapStatusToColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'free':
        return Colors.green;
      case 'reserved':
        return Colors.red;
      case 'disabled':
        return Colors.black;
      case 'pending':
        return Colors.orange;
      case 'not available':
        return Colors.grey;
      default:
        return Colors.grey[400]!;
    }
  }

  List<TimeSlot> _buildTimeSlots(List<dynamic> slotsData) {
    List<TimeSlot> slots = [];

    for (var slot in slotsData) {
      String status = slot['Slot_status'] as String? ?? 'Disabled';

      slots.add(
        TimeSlot(
          slotId: slot['Slot_id'] as int? ?? 0,
          label: slot['Slot_label'] as String? ?? 'N/A',
          status: status,
          color: _mapStatusToColor(status),
        ),
      );
    }
    return slots;
  }

  void _refreshRoomData() {
    setState(() {
      _roomsFuture = fetchRooms();
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
          'Rooms',
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
      body: FutureBuilder<List<dynamic>>(
        future: _roomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Error loading rooms:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No rooms found.'));
          }

          final List<dynamic> rooms = snapshot.data!;

          return Column(
            children: [
              // Date header showing today's date
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Today: ${DateFormat('EEEE, MMM d, yyyy').format(DateTime.now())}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    final List<TimeSlot> slots = _buildTimeSlots(
                      room['slots'] ?? [],
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: RoomCard(
                        roomName: room['Room_name'] ?? 'No Name',
                        timeSlots: slots,
                        roomData: room,
                        userId: widget.userId,
                        userRole: widget.userRole, // ✅ ส่ง userRole ไป
                        onBookingComplete: _refreshRoomData,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Browse extends StatefulWidget {
  final String userId;
  final String userRole;

  const Browse({super.key, required this.userId, required this.userRole});

  @override
  State<Browse> createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  int _selectedIndex = 0;

  List<Widget> _buildWidgetOptions() {
    return <Widget>[
      HomeScreenContent(userId: widget.userId, userRole: widget.userRole),
      Check(userId: widget.userId),
      History(userId: widget.userId),
      Profile(userId: widget.userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _buildWidgetOptions(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Check',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
