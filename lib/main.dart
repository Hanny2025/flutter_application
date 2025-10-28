import 'package:flutter/material.dart';
import 'Lecturer_Logout.dart';
import 'Lecturer_History.dart';
import 'Lecturer_Login.dart';
import 'Lecturer_Browse.dart';
import 'Lecturer_request.dart';
import 'Lecturer_Check.dart';
import 'Lecturer_DashBoard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lecturer App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 0, 62, 195),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.green),
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => const DashboardPage(),
        '/login': (context) => const LoginLecturer(),
        '/browse': (context) => const Browse_Lecturer(),
        '/request': (context) => const Lecturer_req(),
        '/history': (context) => const HistoryPage(),
        '/user': (context) => const UserPage(), 
        '/logout': (context) => const UserPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/check') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => CheckPage(requestData: args),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}