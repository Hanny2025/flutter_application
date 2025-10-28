import 'package:flutter/material.dart';
import 'BottomNav.dart'; // ใช้ import เดิมของคุณ

// ----------------------------------------
// Model (โครงสร้างข้อมูลแบบใหม่)
// ----------------------------------------
class Room {
  final String imagePath;
  final String title;
  final String subtitle;
  final String maxText;
  final String price;
  final List<({String time, String status, Color color})> slots;

  Room({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.maxText,
    required this.price,
    required this.slots,
  });
}

// ----------------------------------------
// หน้าจอ (ใช้ชื่อคลาสเดิมของคุณ)
// ----------------------------------------
class Browse_Lecturer extends StatefulWidget {
  const Browse_Lecturer({super.key});

  @override
  State<Browse_Lecturer> createState() => _Browse_LecturerState();
}

class _Browse_LecturerState extends State<Browse_Lecturer> {
  // ข้อมูลตัวอย่างที่ใช้ Model 'Room'
  final List<Room> rooms = [
    Room(
      imagePath: 'assets/images/room.jpg', // Path เดิมของคุณ
      title: 'Deluxe Twin Room',
      subtitle: '2 single beds • breakfast',
      maxText: 'Max 2 adults',
      price: '900 bahts/day',
      slots: [
        (time: '08:00 - 10:00', status: 'Free', color: Colors.green),
        (time: '10:00 - 12:00', status: 'Pending', color: Colors.orange),
        (time: '13:00 - 15:00', status: 'Reserved', color: Colors.red),
        (time: '15:00 - 17:00', status: 'Disabled', color: Colors.grey),
      ],
    ),
    Room(
      imagePath: 'assets/images/room.jpg', // Path เดิมของคุณ
      title: 'King Deluxe Room',
      subtitle: '1 king bed • breakfast • air',
      maxText: 'Max 1 adult',
      price: '650 bahts/day',
      slots: [
        (time: '08:00 - 10:00', status: 'Free', color: Colors.green),
        (time: '10:00 - 12:00', status: 'Free', color: Colors.green),
        (time: '13:00 - 15:00', status: 'Reserved', color: Colors.red),
        (time: '15:00 - 17:00', status: 'Disabled', color: Colors.grey),
      ],
    ),
    Room(
      imagePath: 'assets/images/room.jpg', // Path เดิมของคุณ
      title: 'Family Deluxe Room',
      subtitle: '1 queen bed • 1 single bed • breakfast',
      maxText: 'Max 3 adults',
      price: '1,250 bahts/day',
      slots: [
        (time: '08:00 - 10:00', status: 'Free', color: Colors.green),
        (time: '10:00 - 12:00', status: 'Pending', color: Colors.orange),
        (time: '13:00 - 15:00', status: 'Reserved', color: Colors.red),
        (time: '15:00 - 17:00', status: 'Disabled', color: Colors.grey),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // สีตามโค้ดตัวอย่าง
    const lightPageBg = Color(0xFFE7F7FF);
    const lightCardBg = Color(0xFFE0F7FF);

    return Scaffold(
      backgroundColor: lightPageBg,
      appBar: AppBar(
        // ใช้สี AppBar จากโค้ดต้นฉบับของคุณ (ถ้าต้องการ)
        // backgroundColor: Color.fromARGB(255, 0, 62, 195),

        // หรือใช้สีจากโค้ดตัวอย่างที่สอง
        backgroundColor: Colors.blue.shade800,
        title: const Text(
          'Rooms',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: rooms.length,
        itemBuilder: (context, i) => _roomCard(rooms[i], lightCardBg),
      ),

      // กลับมาใช้ BottomNavigationBar เดิมของคุณ
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 0),
        child: AppBottomNavigationBar(currentIndex: 0),
      ),
    );
  }

  // Widget สำหรับสร้างการ์ดแต่ละใบ (แบบใหม่)
  Widget _roomCard(Room r, Color lightCardBg) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: ไปหน้า Room Detail (ถ้าต้องการ)
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.asset(
                r.imagePath,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              color: lightCardBg,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r.subtitle,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(r.maxText, style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            r.price,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // วนลูปแสดง
                  for (final s in r.slots)
                    _buildTimeSlot(s.time, s.status, s.color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Utility: แถวเวลา/สถานะ (แบบใหม่)
Widget _buildTimeSlot(String time, String status, Color statusColor) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(time, style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 8),
        Text(
          status,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
      ],
    ),
  );
}
