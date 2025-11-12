import 'package:flutter/material.dart';
import 'BottomNav.dart';
import 'package:intl/intl.dart'; // สำหรับจัดรูปแบบวันที่

class CheckPage extends StatelessWidget {
  final Map<String, dynamic>? requestData;
  const CheckPage({super.key, this.requestData});

  // ข้อมูลตัวอย่าง
  static final List<Map<String, String>> _sampleRequests = [
    {
      "roomName": "Family Deluxe Room",
      "image": "Assets/imgs/room1.jpg",
      "price": "1,250 bahts/day",
      "username": "Username 1",
      "date": "Apr 1, 2025",
      "time": "08:00 - 10:00",
    },
  ];

  void _sendToHistory(BuildContext context, Map<String, dynamic> entry) {
    final historyEntry = {
      ...entry,
      'actionAt': DateTime.now().toIso8601String(),
    };
    Navigator.pushReplacementNamed(
      context,
      '/history',
      arguments: historyEntry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = requestData;

    // เตรียมข้อมูลเริ่มต้น
    String finalImage = 'Assets/imgs/room1.jpg';
    String finalRoomName = 'No Name';
    String finalPrice = 'No Price';
    String finalUsername = 'No User';
    String finalDate = 'No Date';
    String finalTime = 'No Time';

    if (data != null) {
      finalImage = (data["image"] as String?) ?? 'Assets/imgs/room1.jpg';
      finalRoomName = data["roomName"] ?? 'No Name';
      finalPrice = (data["price"] != null)
          ? '${data["price"]} THB/HOUR'
          : 'No Price';
      finalUsername = data["username"] ?? 'No User';
      finalTime = data["time"] ?? 'No Time';

      try {
        if (data["date"] != null) {
          final dateTime = DateTime.parse(data["date"]);
          finalDate = DateFormat('dd/MM/yyyy').format(dateTime.toLocal());
        }
      } catch (e) {
        finalDate = data["date"] ?? 'Invalid Date';
      }
    }

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
                  image: finalImage,
                  roomName: finalRoomName,
                  price: finalPrice,
                  username: finalUsername,
                  date: finalDate,
                  time: finalTime,
                  onApprove: () =>
                      _sendToHistory(context, {...data, 'status': 'approved'}),
                  onReject: () =>
                      _sendToHistory(context, {...data, 'status': 'rejected'}),
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
    // Widget สำหรับแสดงรูปภาพ (รองรับทั้ง Asset / Network)
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
          // แถวข้อมูลหลัก
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

          // ปุ่ม Approve/Reject
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
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                child: const Text('Approve'),
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
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                child: const Text('Reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
