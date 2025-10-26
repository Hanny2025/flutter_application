import 'package:flutter/material.dart';

void main() {
  runApp(const Assignment1App());
}

class Assignment1App extends StatelessWidget {
  const Assignment1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assignment 1',
      debugShowCheckedModeBanner: false,
      home: const Assignment1UI(),
    );
  }
}

class Assignment1UI extends StatelessWidget {
  const Assignment1UI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              'Sevillana Demo',
              style: const TextStyle(
                fontFamily: 'Sevillana', // เชื่อมกับ pubspec.yaml
                fontSize: 48,
                fontWeight: FontWeight.w600,
                color: Colors.pink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Elegant, simple layout with Row, Column, Container',
              style: TextStyle(
                fontFamily: 'Sevillana',
                fontSize: 24,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  Container(color: Colors.red, width: 72),
                  Expanded(
                    child: Container(
                      color: Colors.teal,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 120, height: 120, color: Colors.yellow),
                          const SizedBox(height: 12),
                          Container(width: 120, height: 120, color: Colors.green),
                        ],
                      ),
                    ),
                  ),
                  Container(color: Colors.blue, width: 72),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {},
                      child: const Text('Primary'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Secondary'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
