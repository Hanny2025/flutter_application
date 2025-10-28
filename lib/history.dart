import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// MODEL & MOCK DATA
// -----------------------------------------------------------------------------

// Model สำหรับรายการจอง
class BookingRecord {
  final String room;
  final String date;
  final String time;
  final String bookedBy;
  final String approvedBy;
  final String status;

  BookingRecord({
    required this.room,
    required this.date,
    required this.time,
    required this.bookedBy,
    required this.approvedBy,
    required this.status,
  });
}

// ข้อมูลจำลอง
final List<BookingRecord> mockBookings = [
  BookingRecord(
    room: 'Room 101',
    date: 'Oct 19, 2025',
    time: '8:00 AM - 10:00 AM',
    bookedBy: 'Jayden Smith',
    approvedBy: 'Manager Sam',
    status: 'Approved',
  ),
  BookingRecord(
    room: 'Room 201',
    date: 'Oct 20, 2025',
    time: '8:00 AM - 10:00 AM',
    bookedBy: 'Arthur Wilson',
    approvedBy: 'Manager Sam',
    status: 'Approved',
  ),
  BookingRecord(
    room: 'Room 301',
    date: 'Oct 21, 2025',
    time: '8:00 AM - 10:00 AM',
    bookedBy: 'Kevin Evan',
    approvedBy: 'Manager Sam',
    status: 'Rejected',
  ),
  BookingRecord(
    room: 'Room 402',
    date: 'Oct 22, 2025',
    time: '1:00 PM - 3:00 PM',
    bookedBy: 'Lisa Brown',
    approvedBy: 'Manager Sam',
    status: 'Approved',
  ),
];

// -----------------------------------------------------------------------------
// BOOKING HISTORY SCREEN
// -----------------------------------------------------------------------------
class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String _selectedFilter = 'All';
  final primaryBlue = const Color(0xFF1C6FD5);
  final lightBlueBackground = const Color.fromARGB(255, 230, 245, 255);

  // --- ส่วนจัดการ Bottom Navigation Bar ---
  int _currentIndex = 3; // 3 คือ "History"

  void _onNavTap(int index) {
    if (index == _currentIndex) return; // ไม่โหลดหน้าเดิมซ้ำ

    // ใช้ pushReplacementNamed เพื่อสลับหน้าจอ (เหมือนไฟล์ browse_room.dart)
    switch (index) {
      case 0: // Home
        Navigator.pushReplacementNamed(context, '/browse');
        break;
      case 1: // Requested
        Navigator.pushReplacementNamed(context, '/manage');
        break;
      case 2: // Check
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 3: // History
        // เราอยู่ที่นี่แล้ว
        break;
      case 4: // User
        Navigator.pushReplacementNamed(context, '/user');
        break;
    }
  }
  // --- [สิ้นสุดส่วน Bottom Nav] ---


  // ฟังก์ชันกรองและเรียงลำดับรายการจอง (ล่าสุดไปเก่าสุด)
  List<BookingRecord> get _filteredBookings {
    List<BookingRecord> listToFilter = [...mockBookings]; 

    if (_selectedFilter != 'All') {
      listToFilter = listToFilter
          .where((booking) => booking.status == _selectedFilter)
          .toList();
    }

    listToFilter.sort((a, b) {
      try {
        DateTime dateA = DateTime.parse(a.date.replaceAll(',', ''));
        DateTime dateB = DateTime.parse(b.date.replaceAll(',', ''));
        return dateB.compareTo(dateA); 
      } catch (e) {
        return 0;
      }
    });

    return listToFilter;
  }

  // Widget สำหรับปุ่ม Filter
  Widget _buildFilterButton(String text) {
    final isSelected = _selectedFilter == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
          border: isSelected
              ? Border.all(color: Colors.grey.shade300, width: 1)
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black87 : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Widget สำหรับแสดงบัตรรายการจองแต่ละรายการ
  Widget _buildBookingCard(BookingRecord record) {
    Color statusColor;
    Color statusBgColor;
    Color cardBgColor = Colors.grey.shade200;

    if (record.status == 'Approved') {
      statusBgColor = Colors.green.shade200;
      statusColor = Colors.green.shade800;
    } else {
      statusBgColor = const Color.fromARGB(255, 255, 215, 215);
      statusColor = Colors.red.shade800;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      record.room,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${record.date}  ${record.time}',
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Booked by ${record.bookedBy}',
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black54)),
                Text('Approved by ${record.approvedBy}',
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlueBackground,
      appBar: AppBar(
        title: const Text('Booking History'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false, // เอาปุ่ม Back (ถ้ามี) ออก
        // --- [แก้ไข] ลบ leading และ actions ออก ---
      ),
      body: Column(
        children: [
          // Filter Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: <Widget>[
                _buildFilterButton('All'),
                _buildFilterButton('Approved'),
                _buildFilterButton('Rejected'),
              ],
            ),
          ),
          // Booking List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: _filteredBookings
                  .map((record) => _buildBookingCard(record))
                  .toList(),
            ),
          ),
        ],
      ),

      // --- Bottom Navigation Bar (คงไว้เหมือนเดิม) ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        selectedItemColor: Colors.blue.shade700, 
        unselectedItemColor: Colors.black, 
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), 
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined), 
            label: 'Requested'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined), 
            label: 'Check'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined), 
            label: 'History'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), 
            label: 'User'
          ),
        ],
      ),
    );
  }
}