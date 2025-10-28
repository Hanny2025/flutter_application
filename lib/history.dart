import 'package:flutter/material.dart';

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

// -----------------------------------------------------------------------------
// MOCK DATA
// -----------------------------------------------------------------------------
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
// HISTORY SCREEN UI
// -----------------------------------------------------------------------------

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String _selectedFilter = 'All';

  // ฟังก์ชันกรองรายการจอง
  List<BookingRecord> get _filteredBookings {
    if (_selectedFilter == 'All') {
      return mockBookings;
    }
    return mockBookings
        .where((booking) => booking.status == _selectedFilter)
        .toList();
  }

  // Widget สำหรับปุ่ม Filter
  Widget _buildFilterButton(String text) {
    final isSelected = _selectedFilter == text;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(text),
        selected: isSelected,
        selectedColor: const Color(0xFF1C6FD5),
        backgroundColor: Colors.grey.shade200,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (bool selected) {
          if (selected) {
            setState(() {
              _selectedFilter = text;
            });
          }
        },
      ),
    );
  }

  // Widget สำหรับแสดงบัตรรายการจองแต่ละรายการ
  Widget _buildBookingCard(BookingRecord record) {
    Color statusColor;
    Color statusBgColor;

    if (record.status == 'Approved') {
      statusColor = Colors.green.shade800;
      statusBgColor = Colors.green.shade100;
    } else {
      statusColor = Colors.red.shade800;
      statusBgColor = Colors.red.shade100;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Room & Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record.room,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  record.date,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Text(
                  record.time,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Row 2: Details
            Text('Booked by ${record.bookedBy}',
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            Text('Approved by ${record.approvedBy}',
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 12),

            // Row 3: Status Tag
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  record.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
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
      appBar: AppBar(
        title: const Text('Booking History'),
      ),
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  _buildFilterButton('All'),
                  _buildFilterButton('Approved'),
                  _buildFilterButton('Rejected'),
                ],
              ),
            ),
          ),
          // Booking List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: _filteredBookings
                  .map((record) => _buildBookingCard(record))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
