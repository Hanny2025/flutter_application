import 'package:flutter/material.dart';
import 'package:flutter_application/shared/login.dart';
import 'shared/browse.dart';
import 'shared/profile.dart';
import 'student/register.dart';
import 'shared/profile.dart';
import 'lecturer/Lecturer_Check.dart';
import 'lecturer/Lecturer_DashBoard.dart';

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
      },
    );
  }
}
