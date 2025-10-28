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
        backgroundColor: const Color(0xFF0D47A1), // Blue header bar
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      // ──────────────── Body ────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───── Room Summary ─────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard('25', 'Total\nRooms', Colors.blue),
                _buildSummaryCard('12', 'Free\nRooms', Colors.green),
                _buildSummaryCard('9', 'Reserved', const Color(0xFFFFC107)), // ✅ เหลืองเข้มขึ้น
              ],
            ),
            const SizedBox(height: 12),

            // ───── Disable Room ─────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Disable Rooms',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '4',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ───── Quick Action Title ─────
            const Text(
              'Quick Action',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // ───── Quick Action Buttons ─────
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildActionButton(context, Icons.meeting_room, 'Browse\nRooms', Colors.blue.shade100, routeName: '/browse'),
                _buildActionButton(context, Icons.add_box, 'Request\nRooms', Colors.green.shade100, routeName: '/request'),
                _buildActionButton(context, Icons.search, 'Check\nStatus', Colors.blue.shade100, routeName: '/check'),
                _buildActionButton(context, Icons.history, 'History', Colors.purple.shade100, routeName: '/history'),
                _buildActionButton(context, Icons.logout, 'Logout', Colors.grey.shade300, routeName: '/logout'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────── Summary Card ────────────────
  Widget _buildSummaryCard(String number, String title, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.08)), // ✅ เพิ่มขอบให้เท่ากันทุกการ์ด
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────── Quick Action Buttons ────────────────
  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color bgColor, {String? routeName}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (routeName == null) return;
          // Use named routes configured in main.dart
          try {
            Navigator.pushNamed(context, routeName);
          } catch (_) {
            // fallback: do nothing if route not found
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.black87),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}