import 'package:flutter/material.dart';
import 'BottomNav.dart';

class CheckPage extends StatelessWidget {
  final Map<String, dynamic>? requestData;
  const CheckPage({super.key, this.requestData});

  static final List<Map<String, String>> _sampleRequests = [
    {
      "roomName": "Family Deluxe Room",
      "image": "Assets/imgs/room1.jpg",
      "price": "1,250 bahts/day",
      "username": "Username 1",
      "date": "Apr 1, 2025",
      "time": "08:00 - 10:00",
    },
    {
      "roomName": "King Deluxe Room",
      "image": "Assets/imgs/room2.jpg",
      "price": "650 bahts/day",
      "username": "Username 2",
      "date": "Apr 1, 2025",
      "time": "15:00 - 17:00",
    },
    {
      "roomName": "Deluxe Twin Room",
      "image": "Assets/imgs/room3.jpg",
      "price": "800 bahts/day",
      "username": "Username 3",
      "date": "Apr 1, 2025",
      "time": "10:00 - 12:00",
    },
  ];

  void _sendToHistory(BuildContext context, Map<String, dynamic> entry) {
    final historyEntry = {
      ...entry,
      'actionAt': DateTime.now().toIso8601String(),
    };
    Navigator.pushReplacementNamed(context, '/history', arguments: historyEntry);
  }

  @override
  Widget build(BuildContext context) {
    final data = requestData;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
        title: const Text(
          'Check status',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: data == null
            ? ListView.separated(
                itemCount: _sampleRequests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final item = _sampleRequests[i];
                  return _RequestCard(
                    image: item['image']!,
                    roomName: item['roomName']!,
                    price: item['price']!,
                    username: item['username']!,
                    date: item['date']!,
                    time: item['time']!,
                    onApprove: () => _sendToHistory(context, {
                      ...item,
                      'status': 'approved',
                    }),
                    onReject: () => _sendToHistory(context, {
                      ...item,
                      'status': 'rejected',
                    }),
                  );
                },
              )
            : SingleChildScrollView(
                child: _RequestCard(
                  image: (data["image"] as String?) ?? 'Assets/imgs/room1.jpg',
                  roomName: data["roomName"] ?? '',
                  price: data["price"] ?? '',
                  username: data["username"] ?? '',
                  date: data["date"] ?? '',
                  time: data["time"] ?? '',
                  onApprove: () => _sendToHistory(context, {
                    ...data,
                    'status': 'approved',
                  }),
                  onReject: () => _sendToHistory(context, {
                    ...data,
                    'status': 'rejected',
                  }),
                ),
              ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    );
  }
}

/// การ์ดคำขอแต่ละรายการ
class _RequestCard extends StatelessWidget {
  final String image, roomName, price, username, date, time;
  final VoidCallback onApprove, onReject;

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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9F4FF), // ฟ้าอ่อน
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
          // แถวข้อมูลหลัก (รูป + รายละเอียด + วันเวลา/ชื่อ)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  image,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, size: 20),
                  ),
                ),
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

          // ปุ่มด้านล่าง-ขวา (ไม่เต็มความกว้าง)
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // 🔹 ชิดขวา
            children: [
              // ปุ่ม Approve
              ElevatedButton(
                onPressed: onApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8CF28E),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                child: const Text('Approve'),
              ),
              const SizedBox(width: 10),
              // ปุ่ม Reject
              ElevatedButton(
                onPressed: onReject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7C7C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                child: const Text('reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
