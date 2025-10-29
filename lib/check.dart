import 'package:flutter/material.dart';

// --- Constants ---
const Color primaryBlue = Color(0xFF1976D2);
const Color darkGrey = Color(0xFF333333);

// --- Model สำหรับ Request Status Item ---
class RequestStatusItem {
  final String imageUrl;
  final String roomNumber;
  final String date;
  final String time;
  final String status;
  final Color statusColor;
  final Color backgroundColor;

  const RequestStatusItem({
    required this.imageUrl,
    required this.roomNumber,
    required this.date,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.backgroundColor,
  });
}

// --- Main Screen Class (Check) ---
class Check extends StatefulWidget {
  const Check({super.key});

  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  // สถานะสำหรับ Bottom Navigation Bar
  int _selectedIndex = 2; // 'Check' ถูกเลือกตามภาพ

  // ข้อมูลจำลองสำหรับแสดงผลสถานะคำขอ
  final List<RequestStatusItem> statusList = const [
    RequestStatusItem(
      imageUrl: 'assets/imgs/room4.jpg',
      roomNumber: 'Room 101',
      date: 'Oct 19, 2025',
      time: '8:00 AM - 10:00 AM',
      status: 'Pending',
      statusColor: Color(0xFFC7B102), // สีเหลืองเข้ม
      backgroundColor: Color(0xFFF9F7A2), // สีพื้นหลังเหลืองอ่อน
    ),
    RequestStatusItem(
      imageUrl: 'assets/imgs/room2.jpg',
      roomNumber: 'Room 201',
      date: 'Oct 20, 2025',
      time: '8:00 AM - 10:00 AM',
      status: 'Approved',
      statusColor: Color(0xFF00B909), // สีเขียวเข้ม
      backgroundColor: Color(0xFFB1F1B7), // สีพื้นหลังเขียวอ่อน
    ),
    RequestStatusItem(
      imageUrl: 'assets/imgs/room3.jpg',
      roomNumber: 'Room 301',
      date: 'Oct 21, 2025',
      time: '8:00 AM - 10:00 AM',
      status: 'Rejected',
      statusColor: Color(0xFFD32F2F), // สีแดงเข้ม
      backgroundColor: Color(0xFFF9A2A2), // สีพื้นหลังแดงอ่อน
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. AppBar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: primaryBlue,
        centerTitle: true,
        title: const Text(
          'Chek Request Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // 2. Body: เนื้อหาหลัก
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: statusList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: StatusCard(item: statusList[index]),
          );
        },
      ),

      // 3. BottomNavigationBar
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
        onTap: _onItemTapped,
      ),
    );
  }
}

// ------------------------------------------------------------------
// WIDGETS ย่อย: Card สำหรับแต่ละสถานะคำขอ (StatusCard)
// ------------------------------------------------------------------
class StatusCard extends StatelessWidget {
  final RequestStatusItem item;

  const StatusCard({super.key, required this.item});

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
              item.imageUrl,
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
                    item.roomNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.date,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  Text(
                    item.time,
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
                      color: item.backgroundColor,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: item.statusColor.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: item.statusColor,
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
