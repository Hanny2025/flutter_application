import 'dart:math';
import 'package:flutter/material.dart';

/// แอปหลักที่รวมเดโมทุกเรื่อง (UI, List, Map, Images, Buttons/Random, Loops)
class ExamPrepApp extends StatelessWidget {
  const ExamPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam Prep',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo, // ใช้สีหลักเป็น indigo
        useMaterial3: true,
      ),
      home: const HomeTabs(), // หน้าแรกคือ HomeTabs
    );
  }
}

/// หน้าหลักที่มี TabBar 6 แท็บ (UI, List, Map, Images, Buttons, Loops)
class HomeTabs extends StatelessWidget {
  const HomeTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6, // จำนวนแท็บ
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
              'Exam Prep — UI • List • Map • Images • Buttons • Random • Loops'),
          bottom: const TabBar(
            isScrollable: true, // เลื่อนแท็บได้
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

/* --------------------------- DEMO 1: UI --------------------------- */
/// ตัวอย่าง UI Design (TextField, Button, Layout)
class UiDesignDemo extends StatefulWidget {
  const UiDesignDemo({super.key});
  @override
  State<UiDesignDemo> createState() => _UiDesignDemoState();
}

class _UiDesignDemoState extends State<UiDesignDemo> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscure = true; // สถานะซ่อน/แสดง password

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E), // พื้นหลังสีดำเข้ม
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420), // จำกัดความกว้างสูงสุด
          child: Card(
            elevation: 8, // เงาของการ์ด
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ส่วนหัวใส่รูปจาก internet
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://picsum.photos/800/300',
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
                        left: 16,
                        bottom: 12,
                        child: Text('SIGN IN',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                // ส่วนฟอร์มกรอก email/password
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.alternate_email),
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
                            onPressed: () =>
                                setState(() => obscure = !obscure),
                            icon: Icon(obscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Login as ${emailCtrl.text}')),
                              );
                            },
                            icon: const Icon(Icons.login),
                            label: const Text('Sign In'),
                          ),
                          const Spacer(),
                          const Text('SIGN UP',
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* --------------------------- DEMO 2: LIST --------------------------- */
/// ตัวอย่างการใช้ List + Filter
class ListDemo extends StatefulWidget {
  const ListDemo({super.key});
  @override
  State<ListDemo> createState() => _ListDemoState();
}

class _ListDemoState extends State<ListDemo> {
  final items = ['Banana', 'Apple', 'Orange', 'Mango', 'Kiwi'];
  String query = ''; // เก็บคำค้นหา

  @override
  Widget build(BuildContext context) {
    // filter list ตาม query
    final filtered =
        items.where((e) => e.toLowerCase().contains(query.toLowerCase())).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Filter fruits...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => query = v),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (_, i) => ListTile(
              leading: CircleAvatar(child: Text(filtered[i][0])),
              title: Text(filtered[i]),
            ),
          ),
        )
      ],
    );
  }
}

/* --------------------------- DEMO 3: MAP --------------------------- */
/// ตัวอย่างการใช้ Map + loop หาค่าเฉลี่ย
class MapDemo extends StatelessWidget {
  const MapDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final scores = {'Alice': 84, 'Bob': 72, 'Charlie': 91};
    int sum = 0;
    for (var v in scores.values) sum += v;
    final avg = sum / scores.length;

    return Column(
      children: [
        Text('Scores: $scores'),
        Text('Average: $avg'),
        Expanded(
          child: ListView(
            children: scores.entries
                .map((e) => ListTile(
                      title: Text(e.key),
                      trailing: Text('${e.value}'),
                    ))
                .toList(),
          ),
        )
      ],
    );
  }
}

/* --------------------------- DEMO 4: IMAGES --------------------------- */
/// ตัวอย่าง Image จาก network และ asset
class ImagesDemo extends StatelessWidget {
  const ImagesDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Network Image'),
        Image.network('https://picsum.photos/400/200'),
        const SizedBox(height: 12),
        const Text('Asset Image'),
        Image.asset('assets/images/sample.jpg',
            errorBuilder: (_, __, ___) =>
                const Text('Add assets/images/sample.jpg in pubspec.yaml')),
      ],
    );
  }
}

/* ------------------- DEMO 5: BUTTONS + RANDOM ------------------- */
/// ตัวอย่างปุ่มหลายแบบ + Random
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
    return Column(
      children: [
        Wrap(spacing: 8, children: [
          ElevatedButton(
              onPressed: () => setState(() => counter++),
              child: const Text('Elevated (+1)')),
          OutlinedButton(
              onPressed: () => setState(() => counter = 0),
              child: const Text('Reset')),
          TextButton(
              onPressed: () => setState(() => counter--),
              child: const Text('Text (-1)')),
        ]),
        Text('Counter: $counter'),
        const Divider(),
        ElevatedButton(
            onPressed: () => setState(() => dice = rnd.nextInt(6) + 1),
            child: const Text('Roll Dice')),
        Text('Dice: 🎲 $dice'),
      ],
    );
  }
}

/* --------------------------- DEMO 6: LOOPS --------------------------- */
/// ตัวอย่าง loop: ตารางสูตรคูณ + Fibonacci
class LoopsDemo extends StatelessWidget {
  const LoopsDemo({super.key});

  List<String> _timesTable(int n) {
    final out = <String>[];
    for (int i = 1; i <= 12; i++) {
      out.add('$n x $i = ${n * i}');
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    // สร้าง Fibonacci 10 ตัวแรก
    final fib = [1, 1];
    for (int i = 2; i < 10; i++) {
      fib.add(fib[i - 1] + fib[i - 2]);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Times Table of 7'),
        ..._timesTable(7).map((e) => Text(e)),
        const Divider(),
        const Text('Fibonacci (first 10)'),
        Text(fib.join(', ')),
      ],
    );
  }
}
