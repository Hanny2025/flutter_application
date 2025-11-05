import 'package:flutter/material.dart';
import 'package:flutter_application/check.dart';
import 'package:http/http.dart' as http; // 👈 (1. เพิ่ม) Import http
import 'dart:convert'; // 👈 (2. เพิ่ม) Import convert

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
  // 3. (แก้ไข) รับข้อมูลห้องที่ส่งมาจากหน้า Browse
  final Map<String, dynamic> roomData;

  const Bookrequest({
    super.key,
    required this.roomData, // 👈 (เพิ่ม)
  });

  @override
  State<Bookrequest> createState() => _BookrequestState();
}

class _BookrequestState extends State<Bookrequest> {
  /// index เริ่มต้น (08:00 - 10:00)
  int? _selectedTimeIndex = 0;

  /// ค่าเวลา (ข้อความ) ที่เลือกไว้สำหรับ dropdown
  String? _selectedTime;

  final String serverIp = '10.2.21.252';

  final int currentUserId = 1; // สมมติ user id ปัจจุบันเป็น 1
  final List<RoomTimeSlot> timeSlots = const [
    RoomTimeSlot('08:00 - 10:00'),
    RoomTimeSlot('10:00 - 12:00'),
    RoomTimeSlot('13:00 - 15:00'),
    RoomTimeSlot('15:00 - 17:00'),
  ];

  // (เพิ่ม) Map สำหรับแปลงเวลาไปเป็น Key ใน DB
  // ‼️ (สำคัญ) ตรวจสอบว่า Key ตรงกับ DB (Time_status_08)
  final Map<String, String> _timeSlotToDbKey = {
    '08:00 - 10:00': 'Time_status_08',
    '10:00 - 12:00': 'Time_status_10',
    '13:00 - 15:00': 'Time_status_13',
    '15:00 - 17:00': 'Time_status_15',
  };

  bool _isLoading = false;

  // (เพิ่มฟังก์ชันนี้ทั้งก้อน)
  Future<void> _handleBooking() async {
    if (_selectedTime == null) return; // กันเหนียว

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://10.2.21.252:3000/bookrequest');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'room_id': widget.roomData['Room_id'],
              'user_id': currentUserId,
              // ❌ 'time_slot': _selectedTime,
              // ✅ ใช้ชื่อคอลัมน์ใน DB แทน เช่น Time_status_08
              'time_column': _timeSlotToDbKey[_selectedTime],
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 201) {
        // สำเร็จ (Server ตอบ 201 Created)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking Successful! Status set to Pending'),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ ลิ้งก์ไปหน้า Check (ตามที่คุณขอ)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Check()),
        );
      } else {
        // ไม่สำเร็จ (เช่น ห้องโดนจองตัดหน้า 409, หรือ 500)
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking Failed: ${body['message'] ?? 'Server Error'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Error (เช่น ต่อ Server ไม่ได้, Timeout)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // ‼️ (สำคัญ) ไม่ว่าจะสำเร็จหรือล้มเหลว ต้องหยุดหมุน
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    // หา Slot ที่ "Free" อันแรก เพื่อตั้งเป็นค่าเริ่มต้น
    String? firstFreeSlot;
    int? firstFreeIndex;

    for (int i = 0; i < timeSlots.length; i++) {
      final timeString = timeSlots[i].time;
      final dbKey = _timeSlotToDbKey[timeString];
      // ใช้ widget.roomData เพื่อเข้าถึงข้อมูลที่ส่งมา
      final status = widget.roomData[dbKey] as String? ?? 'Disabled';

      if (status.toLowerCase() == 'free') {
        firstFreeSlot = timeString;
        firstFreeIndex = i;
        break; // เจออันแรกแล้วหยุด
      }
    }

    // ตั้งค่า state (ถ้ามีช่อง Free)
    if (firstFreeSlot != null) {
      _selectedTime = firstFreeSlot;
      _selectedTimeIndex = firstFreeIndex;
    }
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
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BookingRoomCard(
              // ‼️ ตรวจสอบ Key (เช่น 'image_url') ให้ตรงกับ DB
              imageUrl:
                  widget.roomData['image_url'] ?? 'assets/imgs/default.jpg',
              roomName: widget.roomData['Room_name'] ?? 'No Name',
              roomDetails: widget.roomData['Room_detail'] ?? 'No Detail',
              maxAdult: widget.roomData['max_adult'] as int? ?? 1,
              pricePerDay: widget.roomData['price_per_day'] as int? ?? 0,
              dateText: 'Apr 1, 2025', // (อันนี้ยัง Hardcode ไว้ก่อน)
            ),
            const SizedBox(height: 30),

            const Text(
              'Select time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkGrey,
              ),
            ),
            const SizedBox(height: 10),

            // ===== Dropdown เวลา =====
            DropdownButtonFormField<String>(
              value: _selectedTime,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
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

              // --- สร้าง Dropdown Items ---
              items: timeSlots.map((t) {
                // ดึง Key (เช่น 'Time_status_08')
                final dbKey = _timeSlotToDbKey[t.time];
                // ดึงสถานะจากข้อมูลที่ส่งมา
                final status = widget.roomData[dbKey] as String? ?? 'Disabled';
                // ‼️ ถ้าสถานะไม่ใช่ 'free' (ตัวพิมพ์เล็ก) = ปิด
                final bool isDisabled = status.toLowerCase() != 'free';

                return DropdownMenuItem<String>(
                  value: isDisabled ? null : t.time,
                  enabled: !isDisabled,
                  child: Text(
                    '${t.time} ($status)', // แสดงสถานะ (Free), (Reserved)
                    style: TextStyle(
                      color: isDisabled ? Colors.grey : darkGrey,
                    ),
                  ),
                );
              }).toList(),

              // --- กำหนด onChanged ให้เลือกได้เฉพาะเวลาที่เปิด ---
              onChanged: (newValue) {
                if (newValue == null) return; // ถ้า null = disabled
                _onDropdownChanged(newValue);
              },
            ),

            const SizedBox(height: 30),

            // ===== ปุ่มจอง =====
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: (_isLoading || _selectedTime == null)
                    ? null
                    : _handleBooking, // 👈 2. (แก้ไข) เรียกฟังก์ชันจอง
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Book Now', style: TextStyle(fontSize: 18)),
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
                    child: const Text(
                      'Image not found',
                      style: TextStyle(color: Colors.black54),
                    ),
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
                            roomDetails,
                            style: const TextStyle(
                              fontSize: 12,
                              color: darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ขวา: Max adults + ราคา
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Max $maxAdult adults',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          // ถ้าอยากมี comma ให้ใช้ intl แทน
                          '$pricePerDay',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkGrey,
                          ),
                        ),
                        const Text(
                          'bahts/day',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                dateText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
