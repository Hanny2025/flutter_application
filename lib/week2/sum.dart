// lib/week2/sum.dart
import 'package:flutter/material.dart';

class SumPage extends StatefulWidget {
  const SumPage({super.key});
  @override
  State<SumPage> createState() => _SumPageState();
}

class _SumPageState extends State<SumPage> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  String _status = ''; // '', 'Incorrect input', or 'Result = ...'

  void _calculate() {
    final t1 = _a.text.trim();
    final t2 = _b.text.trim();

    // กรณี 1: มีช่องว่าง
    if (t1.isEmpty || t2.isEmpty) {
      setState(() => _status = 'Incorrect input');
      return;
    }

    // กรณี 2: ไม่ใช่ตัวเลข
    final n1 = double.tryParse(t1);
    final n2 = double.tryParse(t2);
    if (n1 == null || n2 == null) {
      setState(() => _status = 'Incorrect input');
      return;
    }

    // กรณี 3: ถูกต้อง แสดงผลลัพธ์
    final sum = n1 + n2;
    setState(() => _status = 'Result = ${sum.toStringAsFixed(0)}');
  }

  void _clear() {
    _a.clear();
    _b.clear();
    setState(() => _status = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3F7), // โทนอ่อนคล้ายรูปตัวอย่าง
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // แถวอินพุต 2 ช่อง + สัญลักษณ์ +
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _a,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'First number',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('+', style: TextStyle(fontSize: 18, color: Colors.black54)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _b,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Second number',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // ปุ่ม Calculate / Clear
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12)),
                        onPressed: _calculate,
                        child: const Text('Calculate'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE74C3C),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        ),
                        onPressed: _clear,
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // สถานะแสดงผล (สีแดงตามตัวอย่าง)
                  if (_status.isNotEmpty)
                    Text(
                      _status,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
