import 'package:flutter/material.dart';
import 'BottomNav.dart'; // (ตรวจสอบว่าไฟล์นี้มีอยู่จริง)
import 'package:http/http.dart' as http; // 1. 👈 Import HTTP
import 'dart:convert'; // 2. 👈 Import 'dart:convert'

// ------------------------------------
// 1. หน้า Dashboard (เปลี่ยนเป็น StatefulWidget)
// ------------------------------------
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // 3. 👈 เพิ่มตัวแปรสำหรับ "จดจำ" สถานะ
  Map<String, dynamic>? _summaryData;
  bool _isLoading = true;
  String? _errorMessage;

  // 4. 👈 เรียกฟังก์ชันดึงข้อมูลตอนเปิดหน้า
  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  // 5. 👈 ฟังก์ชันสำหรับดึง API (เหมือนใน Lecturer_req)
  Future<void> _fetchSummary() async {
    // ⚠️ ถ้าทดสอบใน Android Emulator ให้ใช้ 10.0.2.2
    // ⚠️ ถ้าทดสอบใน iOS Simulator หรือ Web ให้ใช้ localhost
    const String apiUrl = 'http://10.2.21.252:3000/api/dashboard/summary';
    // const String apiUrl = 'http://localhost:3000/api/dashboard/summary';

    // (ตั้งค่า _isLoading = true เมื่อเริ่มดึง)
    setStateIfMounted(() {
      _isLoading = true;
      _errorMessage = null; // ล้าง error เก่า
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // ถ้าสำเร็จ: บันทึกข้อมูล
        setStateIfMounted(() {
          _summaryData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        // ถ้า Server มีปัญหา
        setStateIfMounted(() {
          _errorMessage =
              'Failed to load summary (Code: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      // ถ้าเชื่อมต่อไม่ได้ (เช่น ลืมเปิด Backend, ไม่มีเน็ต)
      setStateIfMounted(() {
        _errorMessage = 'Error connecting to server: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // (Helper function กัน error เวลาปิดหน้า)
  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 62, 195),
        centerTitle: true,
      ),
      // --- (6) 👈 body เปลี่ยนเป็น RefreshIndicator ---
      // (เพื่อให้ผู้ใช้ "ดึงเพื่อโหลดใหม่" ได้)
      body: RefreshIndicator(
        onRefresh: _fetchSummary, // 👈 สั่งให้ดึงข้อมูลใหม่
        child: _buildBodyContent(), // 👈 เรียก Widget ที่แสดงผลจริง
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }

  // --- (7) 👈 สร้าง Widget ที่แสดงผลจริง ---
  // (แยกออกมาเพื่อจัดการ Loading / Error)
  Widget _buildBodyContent() {
    if (_isLoading) {
      // 7.1 ถ้ากำลังโหลด
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      // 7.2 ถ้ามี Error
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error: $_errorMessage\n\nPlease check your Backend server and pull to refresh.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (_summaryData == null) {
      // 7.3 ถ้าไม่มีข้อมูล (ไม่ควรเกิด แต่กันไว้)
      return const Center(child: Text('No data found.'));
    }

    // 7.4 ถ้าสำเร็จ: แสดงผลการ์ด
    return ListView(
      // (RefreshIndicator ต้องใช้กับ Scrollable)
      padding: const EdgeInsets.all(16.0),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- (8) 👈 เชื่อมข้อมูลจริงเข้า SummaryCard ---
            SummaryCard(
              // ใช้ .toString() เพื่อกัน Error (เหมือนที่เราแก้ใน Lecturer_req)
              number: _summaryData!['totalSlots'].toString(),
              title: 'Total Slots',
              color: const Color(0xFF2196F3),
            ),
            const SizedBox(height: 10),

            SummaryCard(
              number: _summaryData!['freeSlots'].toString(),
              title: 'Free Slots (Today)',
              color: const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 10),

            SummaryCard(
              number: _summaryData!['pendingSlots'].toString(),
              title: 'Pending Slots',
              color: const Color(0xFFFFC107),
            ),
            const SizedBox(height: 10),

            SummaryCard(
              number: _summaryData!['disabledRooms'].toString(),
              title: 'Disable Rooms',
              color: Colors.redAccent,
            ),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------
// 2. Class SummaryCard (แม่แบบการ์ด)
// (ไม่ต้องแก้ไข - ใช้เหมือนเดิม)
// ------------------------------------
class SummaryCard extends StatelessWidget {
  final String number;
  final String title;
  final Color color;

  const SummaryCard({
    super.key,
    required this.number,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
