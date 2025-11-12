import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
        // map index -> named route
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/request');
            break;
          case 2:
            // push check page without data (CheckPage handles null)
            Navigator.pushReplacementNamed(context, '/check');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/history');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/user');
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