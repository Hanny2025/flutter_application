import 'package:flutter/material.dart';

// --- Constants ---
const Color primaryBlue = Color(0xFF1976D2);
const Color darkGrey = Color(0xFF333333);

// --- Model สำหรับ History Item ---
class HistoryItem {
  final String roomNumber;
  final String date;
  final String time;
  final String bookedBy;
  final String approvedBy;
  final String status;
  final Color statusColor;
  final Color backgroundColor;

  const HistoryItem({
    required this.roomNumber,
    required this.date,
    required this.time,
    required this.bookedBy,
    required this.approvedBy,
    required this.status,
    required this.statusColor,
    required this.backgroundColor,
  });
}

// --- Main Screen Class (History) ---
class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  // สถานะสำหรับ Bottom Navigation Bar และแถบ Filter
  int _selectedIndex = 3; // 'History' ถูกเลือกตามภาพ
  String _selectedFilter = 'All'; // 'All' ถูกเลือกเป็นค่าเริ่มต้น

  final List<String> filters = const ['All', 'Approved', 'Rejected'];

  final List<HistoryItem> historyList = const [
    HistoryItem(
      roomNumber: 'Room 201',
      date: 'Oct 20, 2025',
      time: '8:00 AM - 10:00 AM',
      bookedBy: 'Arthur Wilson',
      approvedBy: 'Manager Sam',
      status: 'Approved',
      statusColor: Color(0xFF00B909), // สีเขียวเข้ม
      backgroundColor: Color(0xFFD4FFD6), // สีพื้นหลังเขียวอ่อน
    ),
    HistoryItem(
      roomNumber: 'Room 301',
      date: 'Oct 21, 2025',
      time: '8:00 AM - 10:00 AM',
      bookedBy: 'Kevin Evan',
      approvedBy: 'Manager Sam',
      status: 'Rejected',
      statusColor: Color(0xFFD32F2F), // สีแดงเข้ม
      backgroundColor: Color(0xFFFFD4D4), // สีพื้นหลังแดงอ่อน
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  // ฟังก์ชันสำหรับกรองข้อมูลตามสถานะที่เลือก
  List<HistoryItem> get _filteredHistoryList {
    if (_selectedFilter == 'All') {
      return historyList;
    }
    return historyList.where((item) => item.status == _selectedFilter).toList();
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
          'Booking History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // 2. Body: เนื้อหาหลัก
      body: Column(
        children: [
          // แถบตัวเลือก (All, Approved, Rejected)
          FilterChipRow(
            filters: filters,
            selectedFilter: _selectedFilter,
            onSelected: _onFilterSelected,
          ),

          // รายการประวัติ
          Expanded(
            child: _filteredHistoryList.isEmpty
                ? const Center(child: Text('No history found for this status.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: _filteredHistoryList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: HistoryCard(item: _filteredHistoryList[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// WIDGETS ย่อย: แถบ Filter Chips
// ------------------------------------------------------------------

class FilterChipRow extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const FilterChipRow({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: filters.map((filter) {
          final isSelected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              selectedColor: darkGrey, // สีพื้นหลังเมื่อถูกเลือก (สีเทาเข้ม)
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.grey[200], // สีพื้นหลังปกติ (สีเทาอ่อน)
              onSelected: (selected) {
                if (selected) {
                  onSelected(filter);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ------------------------------------------------------------------
// WIDGETS ย่อย: Card สำหรับแต่ละรายการประวัติ
// ------------------------------------------------------------------
class HistoryCard extends StatelessWidget {
  final HistoryItem item;

  const HistoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.grey[200], // สีพื้นหลัง Card เป็นสีเทาอ่อนตามรูป
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ชื่อห้อง วันที่ เวลา
            Text(
              item.roomNumber,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkGrey,
              ),
            ),
            Text(
              '${item.date} · ${item.time}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),

            // รายละเอียดผู้จองและผู้อนุมัติ
            Text(
              'Booked by ${item.bookedBy}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            Text(
              'Approved by ${item.approvedBy}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // สถานะ (Approved/Rejected)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: item.backgroundColor,
                  borderRadius: BorderRadius.circular(5),
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
            ),
          ],
        ),
      ),
    );
  }
}
