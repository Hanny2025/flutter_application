import 'package:flutter/material.dart';
// ต้องแน่ใจว่าได้เปลี่ยน 'package:flutter_application/screens/' เป็น path ที่ถูกต้องของคุณ
import 'package:flutter_application/login.dart';
import 'package:flutter_application/register.dart';
import 'package:flutter_application/browse.dart';
import 'package:flutter_application/bookrequest.dart';
import 'package:flutter_application/check.dart';
import 'package:flutter_application/history.dart';
import 'package:flutter_application/profile.dart';

// -----------------------------------------------------------------

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Booking App',
      debugShowCheckedModeBanner: false,

      initialRoute: '/login',

      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => const Register(), // หากมีหน้าสมัครสมาชิก
        // --- 2. หน้าจอที่มี Bottom Navigation Bar (Home/Main Pages) ---
        // '/home' ใช้เป็นชื่อ route สำหรับการนำทางหลัง Login สำเร็จ
        '/home': (context) => const Browse(),
        '/requested': (context) => const Bookrequest(),
        '/check': (context) => const Check(),
        '/history': (context) => const History(),
        '/profile': (context) => const Profile(),
      },

      // หากคุณต้องการจัดการหน้า Home เป็นหน้าจอหลักที่มี Bottom Nav Bar
      // (แนะนำให้ใช้การนำทางด้วย Index ภายใน Browse, ไม่ใช่การนำทางด้วย Named Route)
    );
  }
}
