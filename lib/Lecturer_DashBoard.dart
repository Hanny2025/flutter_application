import 'package:flutter/material.dart';
import 'BottomNav.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ──────────────── AppBar ────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // ──────────────── Body ────────────────
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───── Room Summary ─────
            Row(
              children: const [
                Expanded(
                  child: SummaryCard(
                    number: '25',
                    title: 'Total\nRooms',
                    color: Color(0xFF2196F3),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SummaryCard(
                    number: '12',
                    title: 'Free\nRooms',
                    color: Color(0xFF4CAF50),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SummaryCard(
                    number: '9',
                    title: 'Reserved',
                    color: Color(0xFFFFC107),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ───── Disable Room ─────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(
                vertical: 10,
              ), // 🔹 เพิ่มระยะห่างด้านบน/ล่าง
              padding: const EdgeInsets.symmetric(
                vertical: 26,
                horizontal: 16,
              ), // 🔹 เพิ่ม padding ด้านใน
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(
                  16,
                ), // 🔹 เพิ่มความโค้งเล็กน้อยให้สมดุล
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Disable Rooms',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '4',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ──────────────── Bottom Navigation ────────────────
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }
}

// ──────────────── Summary Card ────────────────
class SummaryCard extends StatelessWidget {
  final String number;
  final String title;
  final Color color;

  const SummaryCard({
    super.key,
    required this.number,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // 🔼 เพิ่มความสูงขึ้นเล็กน้อย
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13, // 🔽 ลดขนาดเล็กน้อย
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
