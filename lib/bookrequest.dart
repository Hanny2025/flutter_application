import 'package:flutter/material.dart';
import 'package:flutter_application/check.dart';

/// ====== THEME / COLORS ======
const Color primaryBlue = Color(0xFF1976D2);
const Color darkGrey = Color(0xFF333333);
const Color selectedTimeSlotColor = Color(0xFFE0E0E0);

/// ====== MODEL ======
class RoomTimeSlot {
  final String time;
  const RoomTimeSlot(this.time);
}

/// ====== PAGE: Booking Now ======
class Bookrequest extends StatefulWidget {
  const Bookrequest({super.key});

  @override
  State<Bookrequest> createState() => _BookrequestState();
}

class _BookrequestState extends State<Bookrequest> {
  /// index เริ่มต้น (08:00 - 10:00)
  int? _selectedTimeIndex = 0;

  /// ค่าเวลา (ข้อความ) ที่เลือกไว้สำหรับ dropdown
  String? _selectedTime;

  final List<RoomTimeSlot> timeSlots = const [
    RoomTimeSlot('08:00 - 10:00'),
    RoomTimeSlot('10:00 - 12:00'),
    RoomTimeSlot('13:00 - 15:00'),
    RoomTimeSlot('15:00 - 17:00'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedTime = timeSlots[_selectedTimeIndex!].time;
  }

  void _onDropdownChanged(String? newValue) {
    if (newValue == null) return;
    final i = timeSlots.indexWhere((t) => t.time == newValue);
    setState(() {
      _selectedTime = newValue;
      _selectedTimeIndex = i >= 0 ? i : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // แนะนำให้หน้านี้ **ไม่ใส่** BottomNavigationBar
      // เพื่อกันสับสนว่าเป็นแท็บหลัก (Requested ให้เข้ามาจากปุ่ม Book)
      appBar: AppBar(
        automaticallyImplyLeading: true, // มีปุ่ม back
        toolbarHeight: 100,
        backgroundColor: primaryBlue,
        centerTitle: true,
        title: const Text(
          'Booking Now',
          style: TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BookingRoomCard(
              imageUrl: 'assets/imgs/room3.jpg',
              roomName: 'Family Deluxe Room',
              roomDetails:
                  '1 queen bed 1 single bed\n'
                  'breakfast included - electric kettle - free wifi\n'
                  '- hair dryer - refrigerator - blackout curtains',
              maxAdult: 3,
              pricePerDay: 1250,
              dateText: 'Apr 1, 2025',
            ),
            const SizedBox(height: 30),

            const Text(
              'Select time',
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: darkGrey),
            ),
            const SizedBox(height: 10),

            // ===== Dropdown เวลา =====
            DropdownButtonFormField<String>(
              value: _selectedTime,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: darkGrey),
              items: timeSlots
                  .map((t) => DropdownMenuItem<String>(
                        value: t.time,
                        child: Text(t.time,
                            style: const TextStyle(color: darkGrey)),
                      ))
                  .toList(),
              onChanged: _onDropdownChanged,
            ),

            const SizedBox(height: 30),

            // ===== ปุ่มจอง =====
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Booking $_selectedTime ...')),
                  );

                  await Future.delayed(const Duration(seconds: 1));
                  if (!mounted) return;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const Check()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text('Book Now', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// ====== ROOM CARD (รูป + รายละเอียด + ราคา/คนสูงสุด + ป้ายวันที่) ======
class BookingRoomCard extends StatelessWidget {
  final String imageUrl;
  final String roomName;
  final String roomDetails;
  final int maxAdult;
  final int pricePerDay; // ใช้ int และไม่เรียก toStringAsFixed
  final String dateText;

  const BookingRoomCard({
    super.key,
    required this.imageUrl,
    required this.roomName,
    required this.roomDetails,
    required this.maxAdult,
    required this.pricePerDay,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // รูปภาพ (กันรูปหายด้วย errorBuilder)
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
                  errorBuilder: (context, error, stack) => Container(
                    height: 180,
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Text('Image not found',
                        style: TextStyle(color: Colors.black54)),
                  ),
                ),
              ),

              // รายละเอียด
              Container(
                color: const Color(0xFFE8F6FF),
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ซ้าย: ชื่อ+รายละเอียด
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(roomName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkGrey,
                              )),
                          const SizedBox(height: 4),
                          Text(roomDetails,
                              style: const TextStyle(
                                fontSize: 12,
                                color: darkGrey,
                              )),
                        ],
                      ),
                    ),

                    // ขวา: Max adults + ราคา
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Max $maxAdult adults',
                            style: const TextStyle(
                              fontSize: 14, color: Colors.black54)),
                        Text(
                          // ถ้าอยากมี comma ให้ใช้ intl แทน
                          '$pricePerDay',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkGrey,
                          ),
                        ),
                        const Text('bahts/day',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ป้ายวันที่ซ้อนมุมขวาบน
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                dateText,
                style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
