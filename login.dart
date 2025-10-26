import 'dart:math' as math;
import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _n1 = TextEditingController();
  final _n2 = TextEditingController();

  String _message = "";

  void _showMessage(String msg) => setState(() => _message = msg);

  bool _validateNotEmpty() {
    if (_n1.text.trim().isEmpty || _n2.text.trim().isEmpty) {
      _showMessage("Please input both numbers");
      return false;
    }
    return true;
  }

  List<double>? _parseBoth() {
    final a = double.tryParse(_n1.text.trim());
    final b = double.tryParse(_n2.text.trim());
    if (a == null || b == null) {
      _showMessage("Please input only numbers");
      return null;
    }
    return [a, b];
  }

  void _onSum() {
    if (!_validateNotEmpty()) return;
    final nums = _parseBoth();
    if (nums == null) return;
    final res = nums[0] + nums[1];
    _showMessage("Result = ${_trimZero(res)}");
  }

  void _onPower() {
    if (!_validateNotEmpty()) return;
    final nums = _parseBoth();
    if (nums == null) return;
    final res = math.pow(nums[0], nums[1]);
    _showMessage("Result = ${_trimZero(res.toDouble())}");
  }

  void _onClear() {
    _n1.clear();
    _n2.clear();
    _showMessage("");
  }

  String _trimZero(double v) {
    final s = v.toStringAsFixed(12);
    return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: _n1,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Number 1",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _n2,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Number 2",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                ),
                onPressed: _onSum,
                child: const Text("Sum"),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: _onPower,
                child: const Text("Power"),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: _onClear,
                child: const Text("Clear"),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _message,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
