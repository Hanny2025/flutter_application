import 'package:flutter/material.dart';

class ManageBooking extends StatefulWidget {
  const ManageBooking({super.key});

  @override
  State<ManageBooking> createState() => _ManageBookingState();
}

class _ManageBookingState extends State<ManageBooking> {
  // ตั้ง tab ที่เลือกอยู่ (ให้ Home = 0 ตามไอคอนภาพ)
  int _currentIndex = 1;

  void _onNavTap(int i) {
  if (i == _currentIndex) return;
  switch (i) {
    case 0:
      // หน้า Home (Browse)
      break;
    case 1:
      // ✅ Requested -> ไป ManageBooking
      Navigator.pushReplacementNamed(context, '/manage');
      break;
    case 2:
      // หน้า Check (ยังไม่ใช้)
      break;
    case 3:
      // หน้า History (ยังไม่ใช้)
      break;
    case 4:
      // หน้า User (ยังไม่ใช้)
      break;
  }
}


  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade800;

    return Scaffold(
      backgroundColor: const Color(0xFFE7F7FF),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Manage Booking',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildActionButton(
                title: 'Add Room',
                color: Colors.lightGreen.shade400,
                icon: Icons.add,
                onTap: () => Navigator.pushNamed(context, '/addRoom'),
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                title: 'Edit Room',
                color: Colors.yellow.shade400,
                icon: Icons.edit,
                onTap: () => Navigator.pushNamed(context, '/editRoom'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Requested'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box_outlined), label: 'Check'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'User'),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required Color color,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: color,
        elevation: 3,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black54),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
