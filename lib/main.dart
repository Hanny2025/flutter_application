import 'package:flutter/material.dart';
import 'package:flutter_application/lecturer/Lecturer_Browse.dart';
import 'package:flutter_application/shared/login.dart';
import 'package:flutter_application/student/register.dart';

// 📍 import สำหรับ Lecturer pages
import 'package:flutter_application/lecturer/Lecturer_DashBoard.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Booking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 62, 195),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),

        // ⭐ Route แรก: /Lecturer_Browse → ไปหน้า DashboardPage
        '/Lecturer_Browse': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;

          if (args == null) {
            return const Scaffold(
              body: Center(
                child: Text(
                  'Error: Missing user arguments for /Lecturer_Browse.',
                ),
              ),
            );
          }

          return DashboardPage(
            userId: args['userId']?.toString() ?? '0',
            userRole: args['userRole']?.toString() ?? 'Unknown',
          );
        },

        // ⭐ Route ที่สอง: /Browse_Lecturer → ไปหน้า Lecturer_DashBoard
        '/Browse_Lecturer': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;

          return Browse_Lecturer(
            userId: args?['userId']?.toString() ?? '0',
            userRole: args?['userRole']?.toString() ?? 'Unknown',
          );
        },
      },
    );
  }
}
