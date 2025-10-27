import 'package:flutter/material.dart';
import 'package:flutter_application/bookrequest.dart';
import 'package:flutter_application/check.dart';
import 'package:flutter_application/history.dart';
import 'package:flutter_application/profile.dart';

// สีหลักที่ใช้ในแอป
const Color primaryBlue = Color(0xFF1976D2);
const Color darkGrey = Color(0xFF333333);

// ====================================================================
// WIDGETS ย่อย (RoomCard และ TimeSlot) - นำมาจากโค้ดเดิม
// ====================================================================

/// Model สำหรับเก็บข้อมูลช่วงเวลาและสถานะ
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

/// Widget สำหรับแสดง Card ห้องพักแต่ละรายการ
class RoomCard extends StatelessWidget {
  final String imageUrl;
  final String roomName;
  final String roomDetail;
  final int maxAdult;
  final int pricePerDay;
  final List<TimeSlot> timeSlots;

  const RoomCard({
    super.key,
    required this.imageUrl,
    required this.roomName,
    required this.roomDetail,
    required this.maxAdult,
    required this.pricePerDay,
    required this.timeSlots,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รูปภาพ
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
              // Fallback หากไม่มี asset
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
                      // รายละเอียดช่วงเวลา
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
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // 👉 เปลี่ยนจาก SnackBar เป็นการไปหน้า Bookrequest()
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Bookrequest(),
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
                          horizontal: 20,
                          vertical: 8,
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

// สร้าง Widget แยกสำหรับการแสดงเนื้อหาหลักของ Browse (Home)
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          // แสดง Card ห้องพักตัวอย่าง 1
          RoomCard(
            imageUrl: 'assets/deluxe_twin.jpg',
            roomName: 'Deluxe Twin Room',
            roomDetail: '2 single beds  -breakfast',
            maxAdult: 2,
            pricePerDay: 800,
            timeSlots: [
              TimeSlot(
                time: '08:00 - 10:00',
                status: 'Free',
                color: Colors.green,
              ),
              TimeSlot(
                time: '10:00 - 12:00',
                status: 'Reserved',
                color: Colors.red,
              ),
              TimeSlot(
                time: '13:00 - 15:00',
                status: 'Disabled',
                color: Colors.yellow,
              ),
              TimeSlot(
                time: '15:00 - 17:00',
                status: 'Disabled',
                color: Colors.black,
              ),
            ],
          ),
          SizedBox(height: 16),

          // แสดง Card ห้องพักตัวอย่าง 2
          RoomCard(
            imageUrl: 'assets/king_deluxe.jpg',
            roomName: 'King Deluxe Room',
            roomDetail: '1 King bed - breakfast',
            maxAdult: 1,
            pricePerDay: 650,
            timeSlots: [
              TimeSlot(
                time: '08:00 - 10:00',
                status: 'Free',
                color: Colors.green,
              ),
              TimeSlot(
                time: '10:00 - 12:00',
                status: 'Reserved',
                color: Colors.red,
              ),
              TimeSlot(
                time: '13:00 - 15:00',
                status: 'Disabled',
                color: Colors.yellow,
              ),
              TimeSlot(
                time: '15:00 - 17:00',
                status: 'Disabled',
                color: Colors.black,
              ),
            ],
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}

class Browse extends StatefulWidget {
  const Browse({super.key});

  @override
  State<Browse> createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  // สถานะสำหรับ Bottom Navigation Bar
  int _selectedIndex = 0;

  // รายการ Widget ที่จะแสดงในแต่ละ Tab
  // ให้แทนที่ Placeholder ด้วยคลาสหน้าจอจริงของคุณ
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreenContent(), // 0. Home/Browse Content
    const Bookrequest(), // 1. Requested (Bookrequest)
    const Check(), // 2. Check (Check Status)
    const History(), // 3. History
    const Profile(), // 4. User/Profile
  ];

  // อัปเดต Index เมื่อแตะ Icon
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // กำหนดชื่อ Title สำหรับแต่ละหน้า
  String get _currentTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Rooms';
      case 1:
        return 'Requested';
      case 2:
        return 'Check Status';
      case 3:
        return 'History';
      case 4:
        return 'Profile';
      default:
        return 'Rooms';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. AppBar จะเปลี่ยน Title ไปตาม Index ที่เลือก
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: primaryBlue,
        centerTitle: true,
        title: Text(
          _currentTitle, // ใช้ Title ที่อัปเดตแล้ว
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // 2. Body: ใช้ IndexedStack เพื่อแสดงเฉพาะ Widget ที่ถูกเลือก
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),

      // 3. BottomNavigationBar (เชื่อมต่อกับ _onItemTapped)
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
            label: 'Requested',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Check',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        onTap:
            _onItemTapped, // นี่คือส่วนที่ทำให้ Icon เชื่อมต่อ (เปลี่ยน Index)
      ),
    );
  }
}
