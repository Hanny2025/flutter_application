// ...existing code...
import 'package:flutter/material.dart';
import 'BottomNav.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> bookings = [
    {
      'room': 'Room 101',
      'date': 'Oct 19, 2025',
      'time': '8:00 AM - 10:00 AM',
      'bookedBy': 'Jayden Smith',
      'approvedBy': 'Manager Sam',
      'status': 'Approved',
    },
    {
      'room': 'Room 201',
      'date': 'Oct 20, 2025',
      'time': '8:00 AM - 10:00 AM',
      'bookedBy': 'Arthur Wilson',
      'approvedBy': 'Manager Sam',
      'status': 'Approved',
    },
    {
      'room': 'Room 301',
      'date': 'Oct 21, 2025',
      'time': '8:00 AM - 10:00 AM',
      'bookedBy': 'Kevin Evan',
      'approvedBy': 'Manager Sam',
      'status': 'Rejected',
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredBookings = bookings.where((b) {
      if (selectedFilter == 'All') return true;
      return b['status'] == selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text(
          'Booking History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton('All'),
                _buildFilterButton('Approved'),
                _buildFilterButton('Rejected'),
              ],
            ),
            const SizedBox(height: 20),

            // Booking cards
            Expanded(
              child: ListView.builder(
                itemCount: filteredBookings.length,
                itemBuilder: (context, index) {
                  final item = filteredBookings[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['room'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('${item['date']}   ${item['time']}'),
                        Text('Booked by ${item['bookedBy']}'),
                        Text('Approved by ${item['approvedBy']}'),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: item['status'] == 'Approved'
                                  ? Colors.greenAccent.shade100
                                  : Colors.redAccent.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['status'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // bottom navigation bar added
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 0),
        child: AppBottomNavigationBar(currentIndex: 0),
      ),
    );
  }

  // Filter Button Widget
  Widget _buildFilterButton(String label) {
    final bool isSelected = selectedFilter == label;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedFilter = label;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.grey.shade400 : Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
// ...existing code...