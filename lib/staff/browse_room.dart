import 'package:flutter/material.dart';


class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E63F3),
        centerTitle: true,
        title: const Text(
          'Rooms',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            // 🔧 ถ้าต้องการเปลี่ยนสีข้อความหัวข้อ ให้แก้ตรงนี้
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          RoomCard(
            // 🔲 เว้นไว้สำหรับรูปภายหลัง
            imageUrl: "",
            roomName: 'Deluxe Twin Room',
            details: '2 single beds · breakfast',
            capacity: 'Max 2 adult',
            price: '800 bahts/day',
            timeSlots: [
              TimeSlot(time: '08:00 - 10:00', status: 'Free', color: Colors.green),
              TimeSlot(time: '10:00 - 12:00', status: 'Pending', color: Colors.orange),
              TimeSlot(time: '13:00 - 15:00', status: 'Reserved', color: Colors.red),
              TimeSlot(time: '15:00 - 17:00', status: 'Disabled', color: Colors.grey),
            ],
          ),
          RoomCard(
            imageUrl: "",
            roomName: 'King Deluxe Room',
            details: '1 king bed · breakfast · air',
            capacity: 'Max 1 adult',
            price: '650 bahts/day',
            timeSlots: [
              TimeSlot(time: '08:00 - 10:00', status: 'Free', color: Colors.green),
              TimeSlot(time: '10:00 - 12:00', status: 'Pending', color: Colors.orange),
              TimeSlot(time: '13:00 - 15:00', status: 'Reserved', color: Colors.red),
              TimeSlot(time: '15:00 - 17:00', status: 'Disabled', color: Colors.grey),
            ],
          ),
          RoomCard(
            imageUrl: "",
            roomName: 'Family Deluxe Room',
            details: '1 queen bed · 1 single bed · breakfast',
            capacity: 'Max 3 adults',
            price: '1,250 bahts/day',
            timeSlots: [
              TimeSlot(time: '08:00 - 10:00', status: 'Free', color: Colors.green),
              TimeSlot(time: '10:00 - 12:00', status: 'Pending', color: Colors.orange),
              TimeSlot(time: '13:00 - 15:00', status: 'Reserved', color: Colors.red),
              TimeSlot(time: '15:00 - 17:00', status: 'Disabled', color: Colors.grey),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E63F3),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Edit'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
      ),
    );
  }
}


// =====================================================
// Room Card Widget
// =====================================================
class RoomCard extends StatelessWidget {
  final String imageUrl; // 🔲 เว้นช่องไว้สำหรับรูป
  final String roomName;
  final String details;
  final String capacity;
  final String price;
  final List<TimeSlot> timeSlots;


  const RoomCard({
    super.key,
    required this.imageUrl,
    required this.roomName,
    required this.details,
    required this.capacity,
    required this.price,
    required this.timeSlots,
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFFE6F3FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 ตรงนี้คือที่ใส่รูปภายหลัง (ตอนนี้แสดงเป็นกล่องเทาแทน)
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: imageUrl.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: Colors.black45,
                        size: 40,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
            ),


            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  roomName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                Text(
                  capacity,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(details, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 4),
            Text(price, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: timeSlots
                  .map((slot) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          '${slot.time}   ${slot.status}',
                          style: TextStyle(color: slot.color, fontWeight: FontWeight.w500),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}


// =====================================================
// TimeSlot Model
// =====================================================
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


