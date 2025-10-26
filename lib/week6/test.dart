import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ExamPrepApp());

/// แอปหลัก: รวมเดโมสำคัญสำหรับสอบไว้ใน 1 หน้า ด้วย Tab 6 แท็บ
class ExamPrepApp extends StatelessWidget {
  const ExamPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam Prep',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeTabs(),
    );
  }
}

class HomeTabs extends StatelessWidget {
  const HomeTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exam Prep — UI • List • Map • Images • Buttons • Random • Loops'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'UI'),
              Tab(text: 'List'),
              Tab(text: 'Map'),
              Tab(text: 'Images'),
              Tab(text: 'Buttons & Rand'),
              Tab(text: 'Loops'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UiDesignDemo(),
            ListDemo(),
            MapDemo(),
            ImagesDemo(),
            ButtonsRandomDemo(),
            LoopsDemo(),
          ],
        ),
      ),
    );
  }
}

/* ---------------------------------- UI ---------------------------------- */
/// UI เบื้องต้น: Card + Form + Layout (Row/Column), Icon, TextField, Decoration
class UiDesignDemo extends StatefulWidget {
  const UiDesignDemo({super.key});
  @override
  State<UiDesignDemo> createState() => _UiDesignDemoState();
}

class _UiDesignDemoState extends State<UiDesignDemo> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // รูป Header (network line, ใช้ได้ทันที)
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1514511547113-bff2ccb34c72?q=80&w=1600&auto=format&fit=crop',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 16, bottom: 12,
                        child: Text('SIGN IN', style: TextStyle(
                          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800
                        )),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email', prefixIcon: Icon(Icons.alternate_email),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passCtrl,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => obscure = !obscure),
                            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Login as ${emailCtrl.text.trim()}')),
                              );
                            },
                            icon: const Icon(Icons.login),
                            label: const Text('Sign In'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {
                              emailCtrl.clear();
                              passCtrl.clear();
                            },
                            child: const Text('Clear'),
                          ),
                          const Spacer(),
                          const Text('SIGN UP', style: TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.w700
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* --------------------------------- LIST --------------------------------- */
/// ตัวอย่าง List<String> + ListView + Filter/Sort
class ListDemo extends StatefulWidget {
  const ListDemo({super.key});

  @override
  State<ListDemo> createState() => _ListDemoState();
}

class _ListDemoState extends State<ListDemo> {
  final items = <String>[
    'Banana', 'Apple', 'Orange', 'Lemon', 'Grape', 'Mango', 'Strawberry', 'Kiwi'
  ];
  String query = '';
  bool ascending = true;

  @override
  Widget build(BuildContext context) {
    // Filter + Sort (ใช้งานกับ List)
    final filtered = items
        .where((e) => e.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..sort((a, b) => ascending ? a.compareTo(b) : b.compareTo(a));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Filter fruits...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => query = v),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () => setState(() => ascending = !ascending),
                icon: Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward),
                tooltip: 'Toggle sort',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (_, i) => ListTile(
              leading: CircleAvatar(child: Text(filtered[i][0])),
              title: Text(filtered[i]),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('You tapped ${filtered[i]}')),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/* ---------------------------------- MAP --------------------------------- */
/// ตัวอย่าง Map<String, int> + การวนลูปคำนวณค่าเฉลี่ย มากสุด/น้อยสุด
class MapDemo extends StatelessWidget {
  const MapDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> scores = {
      'Alice': 84, 'Bob': 72, 'Charlie': 91, 'Diane': 63, 'Eve': 77,
    };

    // ใช้ loops กับ Map
    int sum = 0;
    String maxName = scores.keys.first;
    String minName = scores.keys.first;
    for (final entry in scores.entries) {
      sum += entry.value;
      if (entry.value > scores[maxName]!) maxName = entry.key;
      if (entry.value < scores[minName]!) minName = entry.key;
    }
    final avg = sum / scores.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              title: const Text('Scores (Map<String,int>)'),
              subtitle: Text(scores.toString()),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _infoCard('Average', avg.toStringAsFixed(2))),
              Expanded(child: _infoCard('Max', '$maxName = ${scores[maxName]}')),
              Expanded(child: _infoCard('Min', '$minName = ${scores[minName]}')),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: scores.entries.map((e) {
                return ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(e.key),
                  trailing: Text('${e.value}'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------- IMAGES -------------------------------- */
/// รูปภาพจาก asset + network + ปุ่มสลับภาพ
class ImagesDemo extends StatefulWidget {
  const ImagesDemo({super.key});

  @override
  State<ImagesDemo> createState() => _ImagesDemoState();
}

class _ImagesDemoState extends State<ImagesDemo> {
  int index = 0;
  final urls = [
    'https://images.unsplash.com/photo-1520975884282-5f4a7f2b9fd2?q=80&w=1600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1521207418485-99c705420785?q=80&w=1600&auto=format&fit=crop',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Network Image', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(urls[index], fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton.tonal(
              onPressed: () => setState(() => index = (index + 1) % urls.length),
              child: const Text('Next Image'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => setState(() => index = 0),
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Asset Image', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // ถ้าประกาศ assets แล้ว (ดูหมายเหตุท้ายข้อความ) รูปนี้จะแสดงได้
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/sample.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.black12,
                child: const Center(
                  child: Text('Put assets/images/sample.jpg & declare in pubspec.yaml'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* -------------------------- BUTTONS + RANDOM ---------------------------- */
/// ปุ่มหลายแบบ + ตัวอย่าง Random numbers (ลูกเต๋า) + counter
class ButtonsRandomDemo extends StatefulWidget {
  const ButtonsRandomDemo({super.key});

  @override
  State<ButtonsRandomDemo> createState() => _ButtonsRandomDemoState();
}

class _ButtonsRandomDemoState extends State<ButtonsRandomDemo> {
  int counter = 0;
  int dice = 1;
  final rnd = Random();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () => setState(() => counter++),
              child: const Text('Elevated (+1)'),
            ),
            OutlinedButton(
              onPressed: () => setState(() => counter = 0),
              child: const Text('Outlined (reset)'),
            ),
            TextButton(
              onPressed: () => setState(() => counter--),
              child: const Text('Text (-1)'),
            ),
            IconButton(
              onPressed: () => setState(() => counter += 10),
              icon: const Icon(Icons.flash_on),
              tooltip: 'Add 10',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Counter'),
            trailing: Text('$counter', style: const TextStyle(fontSize: 24)),
          ),
        ),
        const Divider(),
        const Text('Random Number (1–6): ลูกเต๋า'),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton(
              onPressed: () => setState(() => dice = rnd.nextInt(6) + 1),
              child: const Text('Roll'),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => setState(() => dice = 1),
              child: const Text('Reset'),
            ),
            const Spacer(),
            Text('🎲 $dice', style: const TextStyle(fontSize: 28)),
          ],
        ),
      ],
    );
  }
}

/* -------------------------------- LOOPS --------------------------------- */
/// ตัวอย่าง loop: ตารางหมากรุก 8x8, ตารางสูตรคูณ, Fibonacci
class LoopsDemo extends StatelessWidget {
  const LoopsDemo({super.key});

  List<List<int>> _makeChessBoard(int n) {
    // ตัวอย่าง nested loop
    final board = List.generate(n, (_) => List.filled(n, 0));
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        board[r][c] = (r + c) % 2; // 0/1 สลับสี
      }
    }
    return board;
    // ใช้ใน GridView ด้านล่าง
  }

  List<String> _makeTimesTable(int n) {
    final lines = <String>[];
    for (int i = 1; i <= 12; i++) {
      lines.add('$n x $i = ${n * i}');
    }
    return lines;
  }

  List<int> _fibonacci(int count) {
    final fib = <int>[];
    for (int i = 0; i < count; i++) {
      if (i < 2) {
        fib.add(1);
      } else {
        fib.add(fib[i - 1] + fib[i - 2]);
      }
    }
    return fib;
  }

  @override
  Widget build(BuildContext context) {
    final chess = _makeChessBoard(8);
    final table7 = _makeTimesTable(7);
    final fib10 = _fibonacci(10);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Nested Loops: 8×8 Chessboard'),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 64,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
            ),
            itemBuilder: (_, i) {
              final r = i ~/ 8, c = i % 8;
              final v = chess[r][c];
              return Container(color: v == 0 ? Colors.brown[200] : Colors.brown[600]);
            },
          ),
        ),
        const SizedBox(height: 16),
        const Text('For Loop: 7 Times Table'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              children: table7.map((e) => Chip(label: Text(e))).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Fibonacci (first 10 numbers)'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: fib10
              .map((e) => Chip(
                    label: Text('$e'),
                    avatar: const Icon(Icons.numbers, size: 18),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
