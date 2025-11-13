import 'package:flutter/material.dart';
import 'package:flutter_application/login.dart';
import 'package:flutter_application/browse_room.dart';
import 'package:flutter_application/manage.dart';
import 'package:flutter_application/addroom.dart';
import 'package:flutter_application/editroom.dart';
import 'package:flutter_application/history.dart';
import 'package:flutter_application/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Booking System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFE7F7FF),
        fontFamily: 'Arial',
      ),

      // 🏠 หน้าเริ่มต้น
      initialRoute: '/login',

      // 🗺️ เส้นทางทั้งหมดในแอป
      routes: {
        '/login': (context) => const UserPage(),
        '/browse': (context) => const RoomsPage(),
        '/manage': (context) => const ManageBooking(),
        '/addRoom': (context) => const AddRoomPage(),
        '/editRoom': (context) => const EditRoomListPage(),
        '/history': (context) => const BookingHistoryPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}
