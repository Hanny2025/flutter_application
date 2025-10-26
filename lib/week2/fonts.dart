// lib/week2/fonts.dart
import 'package:flutter/material.dart';

class fontsPage extends StatelessWidget {
  const fontsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[300],
      body: SafeArea(
        child: Stack(
          children: [
            // เนื้อหากลางหน้า
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Wedding Organizer",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Sevillana',
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Pre-wedding, Photo, Party",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Sevillana',
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4511E), // โทนส้ม-แดง
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                      shape: const StadiumBorder(),
                      elevation: 4,
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Our services",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ข้อความที่อยู่ชิดล่างกลาง
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  "345 Moo 1 Tasud Chiang Rai, Thailand",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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
