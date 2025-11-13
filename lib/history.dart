import 'package:flutter/material.dart';


class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});


  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}


class _BookingHistoryPageState extends State<BookingHistoryPage> {
  String selectedFilter = "All"; // 👈 เปลี่ยนค่าเริ่มต้นตรงนี้ได้ตามต้องการ


  final List<Map<String, dynamic>> bookings = [
    {
      "room": "Room 101",
      "date": "Oct 19, 2025",
      "time": "8:00 AM - 10:00 AM",
      "bookedBy": "Jayden Smith",
      "approvedBy": "Manager Sam",
      "status": "Approved"
    },
    {
      "room": "Room 201",
      "date": "Oct 20, 2025",
      "time": "8:00 AM - 10:00 AM",
      "bookedBy": "Arthur Wilson",
      "approvedBy": "Manager Sam",
      "status": "Approved"
    },
    {
      "room": "Room 301",
      "date": "Oct 21, 2025",
      "time": "8:00 AM - 10:00 AM",
      "bookedBy": "Kevin Evan",
      "approvedBy": "Manager Sam",
      "status": "Rejected"
    },
  ];


  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredBookings = bookings.where((b) {
      if (selectedFilter == "All") return true;
      return b["status"] == selectedFilter;
    }).toList();


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Booking History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E63F3),
      ),


      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 🔘 Filter buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterButton("All"),
                _filterButton("Approved"),
                _filterButton("Rejected"),
              ],
            ),


            const SizedBox(height: 10),


            // 🧾 Booking Cards
            Expanded(
              child: ListView.builder(
                itemCount: filteredBookings.length,
                itemBuilder: (context, index) {
                  final booking = filteredBookings[index];
                  final status = booking["status"];
                  final statusColor = status == "Approved"
                      ? Colors.green[200]
                      : Colors.red[200];


                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking["room"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${booking["date"]}   ${booking["time"]}",
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          "Booked by ${booking["bookedBy"]}",
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          "Approved by ${booking["approvedBy"]}",
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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


      // ⚙️ Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E63F3),
        unselectedItemColor: Colors.grey,
        currentIndex: 4, // “History”
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


  // 🟢 Filter Button Widget
  Widget _filterButton(String label) {
    bool isSelected = selectedFilter == label;
    return ElevatedButton(
      onPressed: () {
        setState(() => selectedFilter = label);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF1E63F3) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        side: const BorderSide(color: Colors.black12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: isSelected ? 3 : 0,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}


