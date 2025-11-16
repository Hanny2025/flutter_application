import 'package:flutter/material.dart';


class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,


      // 🔹 AppBar
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E63F3),
        elevation: 0,
      ),


      // 🔹 เนื้อหาหลัก
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔸 แถวแรก (3 กล่อง)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard(
                  "25",
                  "Total\nRooms",
                  const Color(0xFF1E63F3),
                  Colors.white,
                ),
                _buildInfoCard(
                  "12",
                  "Free\nRooms",
                  const Color(0xFFDCE8FF),
                  Colors.black,
                ),
                _buildInfoCard(
                  "9",
                  "Reserved",
                  const Color(0xFFFFF6BF),
                  Colors.black,
                ),
              ],
            ),


            const SizedBox(height: 16),


            // 🔸 กล่องใหญ่สีแดง (Disabled Rooms)
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFEF5350),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Disabled Rooms",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "4",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),


      // 🔹 Bottom Navigation Bar (เหมือนหน้าอื่น)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E63F3),
        unselectedItemColor: Colors.grey,
        currentIndex: 3, // หน้า Dashboard
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


  // 🔹 กล่องข้อมูล 3 ช่องบน
  Widget _buildInfoCard(
    String value,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      width: 105,
      height: 100,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
 }