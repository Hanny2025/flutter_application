import 'package:flutter/material.dart';
import 'package:flutter_application/app_routes.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  const AppBottomNavigationBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    const primary = Color.fromARGB(255, 0, 62, 195);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, AppRoutes.home);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, AppRoutes.requested);
            break;
          case 2:
            Navigator.pushReplacementNamed(context, AppRoutes.check);
            break;
          case 3:
            Navigator.pushReplacementNamed(context, AppRoutes.history);
            break;
          case 4:
            Navigator.pushReplacementNamed(context, AppRoutes.profile);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.event_available), label: 'Requested'),
        BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Check'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
      ],
    );
  }
}
