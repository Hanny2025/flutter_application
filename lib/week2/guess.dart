// lib/week2/guess.dart
import 'dart:math';
import 'package:flutter/material.dart';

class GuessPage extends StatefulWidget {
  const GuessPage({super.key});
  @override
  State<GuessPage> createState() => _GuessPageState();
}

class _GuessPageState extends State<GuessPage> {
  final _input = TextEditingController();
  late int _answer;
  int _left = 3;
  String _msg = '';
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _answer = Random().nextInt(10); // 0..9
    _left = 3;
    _msg = '';
    _finished = false;
    _input.clear();
    setState(() {});
  }

  void _guess() {
    if (_finished) return;

    final n = int.tryParse(_input.text.trim());
    if (n == null || n < 0 || n > 9) {
      setState(() => _msg = 'Please enter an integer 0–9');
      return;
    }

    if (n == _answer) {
      setState(() {
        _msg = 'Correct, you win!';
        _finished = true;
      });
      return;
    }

    _left -= 1;
    if (_left == 0) {
      setState(() {
        _msg = 'Sorry, you lose. The answer is $_answer';
        _finished = true;
      });
    } else {
      setState(() {
        _msg = n < _answer
            ? '$n is too small, $_left chance(s) left!'
            : '$n is too large, $_left chance(s) left!';
      });
    }
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Guess a number game',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _input,
                    keyboardType: TextInputType.number,
                    enabled: !_finished,
                    decoration: const InputDecoration(
                      hintText: 'Guess a number 0–9',
                    ),
                    onSubmitted: (_) => _guess(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _finished ? null : _guess,
                    child: const Text('Guess'),
                  ),
                  const SizedBox(height: 12),
                  if (_msg.isNotEmpty)
                    Text(
                      _msg,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 12),
                  // ปุ่ม Replay จะแสดงเสมอเพื่อให้รีเซ็ตเกมได้
                  OutlinedButton(
                    onPressed: _reset,
                    child: const Text('Replay'),
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
