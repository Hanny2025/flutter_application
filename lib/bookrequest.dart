import 'package:flutter/material.dart';
import 'package:flutter_application/check.dart';

// --- Constants (กำหนดสีหลัก) ---
const Color primaryBlue = Color(0xFF1976D2);
const Color darkGrey = Color(0xFF333333);
const Color selectedTimeSlotColor = Color(
  0xFFE0E0E0,
); // สีเทาอ่อนสำหรับช่องเวลาที่เลือก

// --- Model สำหรับ Time Slot ---
class RoomTimeSlot {
  final String time;
  const RoomTimeSlot(this.time);
}

// --- Main Screen Class (Bookrequest) ---
class Bookrequest extends StatefulWidget {
  const Bookrequest({super.key});

  @override
  State<Bookrequest> createState() => _BookrequestState();
}

class _BookrequestState extends State<Bookrequest> {
  // สถานะสำหรับ Bottom Navigation Bar และ Time Slot
  int _selectedIndex = 1; // 'Requested' ถูกเลือก
  int? _selectedTimeIndex = 0; // ช่องเวลา 08:00 - 10:00 ถูกเลือกตามภาพ

  final List<RoomTimeSlot> timeSlots = [
    const RoomTimeSlot('08:00 - 10:00'),
    const RoomTimeSlot('10:00 - 12:00'),
    const RoomTimeSlot('13:00 - 15:00'),
    const RoomTimeSlot('15:00 - 17:00'),
  ];

  // ✅ ฟังก์ชันเปลี่ยนชื่อ title ตามแท็บที่เลือก
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

  // เมื่อกดแท็บใน BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // สามารถเพิ่ม Navigator.pushNamed() เพื่อเปลี่ยนหน้าได้
  }

  // เมื่อเลือก Time Slot
  void _onTimeSlotTapped(int index) {
    setState(() {
      _selectedTimeIndex = index;
    });
  }

  // <<< (แก้ไข _onTimeSlotTapped สำหรับ Dropdown ที่รับ int? ได้)
  // (DropdownButton's onChanged passes an int?)
  void _onDropdownChanged(int? newIndex) {
    if (newIndex != null) {
      setState(() {
        _selectedTimeIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. เพิ่ม AppBar ของตัวเอง
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: primaryBlue,
        centerTitle: true,
        title: const Text(
          'Booking Now', // นี่คือหัวข้อของหน้า Home
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // ✅ Body: เนื้อหาหลัก
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card รายละเอียดห้อง (Family Deluxe Room)
            const BookingRoomCard(
              imageUrl: 'assets/imgs/room3.jpg',
              roomName: 'Family Deluxe Room',
              roomDetails:
                  '1 queen bed 1 single bed\nbreakfast included - electric bottle - free wifi\n- hair dryer - refrigerator - blackout curtains',
              maxAdult: 3,
              pricePerDay: 1250,
              dateText: 'Apr 1, 2025',
            ),

            const SizedBox(height: 30),

            // ส่วนหัวข้อ Select time
            const Text(
              'Select time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkGrey,
              ),
            ),
            const SizedBox(height: 10),

            // Dropdown (จำลอง)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(5),
              ),
              child: DropdownButton<int>(
                // ค่าที่เลือกอยู่ (คือ index)
                value: _selectedTimeIndex,

                // ทำให้ลูกศรอยู่ขวาสุด
                isExpanded: true,

                // เอาเส้นใต้สีเทาๆ ออก
                underline: const SizedBox(),

                // Icon (เหมือนเดิม)
                icon: const Icon(Icons.arrow_drop_down, color: darkGrey),

                // ฟังก์ชันที่ทำงานเมื่อเลือก item ใหม่
                onChanged: _onDropdownChanged,
                // สร้างรายการ Dropdown จาก List 'timeSlots'
                items: List.generate(timeSlots.length, (index) {
                  return DropdownMenuItem<int>(
                    value: index, // ค่าของ item นี้คือ index
                    child: Text(
                      timeSlots[index].time, // ข้อความที่แสดงคือเวลา
                      style: const TextStyle(color: darkGrey),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // รายการเลือกช่วงเวลา (Time Slot Selector)
            TimeSlotSelector(
              timeSlots: timeSlots,
              selectedIndex: _selectedTimeIndex,
              onTimeSlotTapped: _onTimeSlotTapped,
            ),

            const SizedBox(height: 30),

            // ปุ่ม Book Now
            SizedBox(
              height: 50,
              child: ElevatedButton(
                // <<< 2. เพิ่ม 'async' ตรงนี้
                onPressed: () async {
                  // 1. แสดงข้อความ (เหมือนเดิม)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking request sent!')),
                  );

                  // <<< 3. รอ 1 วินาที (เพื่อให้คนอ่านข้อความทัน)
                  await Future.delayed(const Duration(seconds: 1));

                  // <<< 4. ไปหน้าใหม่ (เช่น หน้า History)
                  // (ต้องเช็ค 'mounted' ก่อนเสมอหลัง await)
                  if (mounted) {
                    Navigator.pushReplacement(
                      // (หรือ Navigator.push)
                      context,
                      MaterialPageRoute(
                        // <<< 5. ใส่ชื่อคลาสของหน้าใหม่ตรงนี้
                        builder: (context) => const Check(),
                      ),
                    );
                  }
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

// ====================================================================
// WIDGETS ย่อย: Card รายละเอียดห้อง (เหมือนกับภาพ Booking Now)
// ====================================================================

class BookingRoomCard extends StatelessWidget {
  final String imageUrl;
  final String roomName;
  final String roomDetails;
  final int maxAdult;
  final int pricePerDay;
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
                ),
              ),

              // รายละเอียด
              Container(
                color: const Color(0xFFE8F6FF),
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
                            roomDetails,
                            style: const TextStyle(
                              fontSize: 12,
                              color: darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // รายละเอียดราคา (ขวา)
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
                          '${pricePerDay.toStringAsFixed(0)},',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkGrey,
                          ),
                        ),
                        const Text(
                          'Bahts/day',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // วันที่ (วางทับบนรูปภาพ)
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

// ====================================================================
// WIDGETS ย่อย: รายการเลือกช่วงเวลา (Time Slot Selector)
// ====================================================================

class TimeSlotSelector extends StatelessWidget {
  final List<RoomTimeSlot> timeSlots;
  final int? selectedIndex;
  final Function(int) onTimeSlotTapped;

  const TimeSlotSelector({
    super.key,
    required this.timeSlots,
    required this.selectedIndex,
    required this.onTimeSlotTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: List.generate(timeSlots.length, (index) {
          final isSelected = index == selectedIndex;
          return InkWell(
            onTap: () => onTimeSlotTapped(index),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? selectedTimeSlotColor : Colors.transparent,
                borderRadius: index == 0
                    ? const BorderRadius.vertical(top: Radius.circular(10))
                    : index == timeSlots.length - 1
                    ? const BorderRadius.vertical(bottom: Radius.circular(10))
                    : BorderRadius.zero,
              ),
              child: Center(
                child: Text(
                  timeSlots[index].time,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? darkGrey : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
