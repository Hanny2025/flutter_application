import 'package:flutter/material.dart';
import 'package:flutter_application/login.dart';
import 'package:flutter_application/register.dart';
import 'package:flutter_application/browse.dart';
import 'package:flutter_application/bookrequest.dart';
import 'package:flutter_application/check.dart';
import 'package:flutter_application/history.dart';
import 'package:flutter_application/profile.dart';
import 'package:flutter_application/app_routes.dart'; 

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
        '/register': (context) => const Register(),

        // ✅ ใช้ชื่อจาก AppRoutes (ป้องกันพิมพ์ผิด)
        AppRoutes.home: (context) => const Browse(),
        AppRoutes.requested: (context) => const Bookrequest(),
        AppRoutes.check: (context) => const Check(),
        AppRoutes.history: (context) => const History(),
        AppRoutes.profile: (context) => const Profile(),
      },
    );
  }
}
