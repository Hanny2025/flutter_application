import 'package:flutter/material.dart';
import 'package:flutter_application/bookrequest.dart';
import 'package:flutter_application/check.dart';
import 'package:flutter_application/history.dart';
import 'package:flutter_application/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// สีหลักที่ใช้ในแอป
const Color primaryBlue = Color(0xFF1976D2);
const Color darkGrey = Color(0xFF333333);

// ====================================================================
// WIDGETS ย่อย
// ====================================================================

/// 1. Model (โค้ดเดิม)
class TimeSlot {
  final String time;
  final String status;
  final Color color;
  const TimeSlot({
    required this.time,
    required this.status,
    required this.color,
  });
}

/// 2. RoomCard (แก้ไข)
class RoomCard extends StatelessWidget {
  final String imageUrl;
  final String roomName;
  final String roomDetail;
  final int maxAdult;
  final int pricePerDay;
  final List<TimeSlot> timeSlots;
  final Map<String, dynamic> roomData; // 👈 (1. เพิ่ม) รับข้อมูลดิบ

  const RoomCard({
    super.key,
    required this.imageUrl,
    required this.roomName,
    required this.roomDetail,
    required this.maxAdult,
    required this.pricePerDay,
    required this.timeSlots,
    required this.roomData, // 👈 (1. เพิ่ม)
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (ส่วน Image, Text รายละเอียด เหมือนเดิม) ...
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Image.asset(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[300],
                child: Center(
                  child: Text(
                    "Image not found: $imageUrl",
                    style: TextStyle(color: Colors.grey[600]),
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
                // รายละเอียดห้อง (ซ้าย)
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
                      const SizedBox(height: 4),
                      Text(
                        roomDetail,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 3. แสดง TimeSlots ที่ได้รับมา
                      ...timeSlots
                          .map(
                            (slot) => Row(
                              children: [
                                Text(
                                  '${slot.time} - ',
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

                // รายละเอียดราคาและปุ่ม (ขวา)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Max $maxAdult adult${maxAdult > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      '$pricePerDay Bahts/day',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // 👈 (3. แก้ไข) ส่ง roomData ไปยังหน้า Bookrequest
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Bookrequest(roomData: roomData),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Book'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// MAIN SCREEN SHELL (Browse)
// ====================================================================

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  late Future<List<dynamic>> _roomsFuture;
  final String serverIp = '10.2.21.252';

  @override
  void initState() {
    super.initState();
    _roomsFuture = fetchRooms();
  }

  Future<List<dynamic>> fetchRooms() async {
    final url = Uri.parse('http://$serverIp:3000/browse');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception(
          'Failed to load rooms (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch rooms: $e');
    }
  }

  // (แก้ไข 5. แก้ 'pending...' -> 'pending' และใช้สีส้ม)
  Color _mapStatusToColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'free':
        return Colors.green;
      case 'reserved':
        return Colors.red;
      case 'disabled':
        return Colors.black;
      case 'pending...': // 👈 แก้ไข
        return Colors.yellow; // 👈 แก้ไข
      default:
        return Colors.grey[400]!;
    }
  }

  List<TimeSlot> _buildTimeSlots(Map<String, dynamic> room) {
    // (แก้ไข 4. แก้ 'Time_status_8' -> 'Time_status_08')
    final Map<String, String> timeKeyMap = {
      'Time_status_08': '08:00 - 10:00', // 👈 แก้ไข
      'Time_status_10': '10:00 - 12:00',
      'Time_status_13': '13:00 - 15:00',
      'Time_status_15': '15:00 - 17:00',
    };

    List<TimeSlot> slots = [];
    timeKeyMap.forEach((key, timeRange) {
      final String status = room[key] as String? ?? 'Disabled';
      slots.add(
        TimeSlot(
          time: timeRange,
          status: status,
          color: _mapStatusToColor(status),
        ),
      );
    });
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ... (AppBar เหมือนเดิม) ...
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
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _roomsFuture,
        builder: (context, snapshot) {
          // ... (ส่วน Loading, Error, No Data เหมือนเดิม) ...
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

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              final List<TimeSlot> slots = _buildTimeSlots(room);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: RoomCard(
                  // ‼️ ตรวจสอบ Key ให้ตรงกับ DB
                  imageUrl: room['image_url'] ?? 'assets/imgs/default.jpg',
                  roomName: room['Room_name'] ?? 'No Name',
                  roomDetail: room['Room_detail'] ?? 'No Detail',
                  maxAdult: room['max_adult'] as int? ?? 1,
                  pricePerDay: room['price_per_day'] as int? ?? 0,
                  timeSlots: slots,
                  roomData: room, // 👈 (2. เพิ่ม) ส่งข้อมูลดิบเข้าไป
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ====================================================================
// BROWSE PAGE (Bottom Navigation) - (โค้ดเดิม ไม่เปลี่ยนแปลง)
// ====================================================================

class Browse extends StatefulWidget {
  const Browse({super.key});

  @override
  State<Browse> createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreenContent(), // 0. Home
    const Check(), // 1. Check
    const History(), // 2. History
    const Profile(), // 3. User
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
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
        onTap: _onItemTapped,
      ),
    );
  }
}
