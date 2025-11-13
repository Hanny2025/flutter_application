import 'package:flutter/material.dart';
// import '../Bottom_Nav.dart'; // (ลบออกได้ เพราะเราจะจัดการ Nav ในหน้านี้)
import 'package:http/http.dart' as http;
import 'dart:convert';

// ------------------------------------
// 1. หน้า Dashboard (StatefulWidget)
// ------------------------------------
class DashboardPage extends StatefulWidget {
  // ⭐️ 1. เพิ่มตัวแปรสำหรับรับค่า
  final String userId;
  final String userRole;

  const DashboardPage({
    super.key,
    required this.userId, // ⭐️ 2. เพิ่ม required
    required this.userRole, // ⭐️ 3. เพิ่ม required
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

// ------------------------------------
// 2. State ของ Dashboard
// ------------------------------------
class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? _summaryData;
  bool _isLoading = true;
  String? _errorMessage;

  // ⭐️ 4. กำหนดสี (ที่ BottomNav ต้องใช้)
  static const Color primaryBlue = Color(0xFF0D47A1);

  // ⭐️ 5. Index ของหน้านี้ (Home = 0)
  final int _selectedIndex = 0; // หน้านี้คือ index 0

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    // (ส่วนนี้เหมือนเดิม ... )
    const String apiUrl = 'http://10.2.21.252:3000/api/dashboard/summary';

    setStateIfMounted(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setStateIfMounted(() {
          _summaryData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setStateIfMounted(() {
          _errorMessage =
              'Failed to load summary (Code: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setStateIfMounted(() {
        _errorMessage = 'Error connecting to server: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  // ⭐️ 6. ฟังก์ชันสำหรับจัดการการกด BottomNav
  void _onItemTapped(int index) {
    // ถ้ากดแท็บเดิม (Home) ก็ไม่ต้องทำอะไร
    if (index == _selectedIndex) return;

    // เตรียมข้อมูลที่จะส่งไปหน้าใหม่
    // (เราจะใช้ 'widget.userId' และ 'widget.userRole' ที่รับมาจาก constructor)
    final arguments = {'userId': widget.userId, 'userRole': widget.userRole};

    // เปลี่ยนหน้าตาม index ที่กด
    switch (index) {
      case 0:
        // (นี่คือหน้า Home อยู่แล้ว)
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/check', arguments: arguments);
        break;
      case 2:
        Navigator.pushReplacementNamed(
          context,
          '/history',
          arguments: arguments,
        );
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/user', arguments: arguments);
        break;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // ใช้ Navigator.pop(context) เพื่อกลับไปยังหน้าก่อนหน้า
            // หากไม่มีหน้าก่อนหน้า (หน้า Dashboard เป็นหน้าแรก) จะเป็นการออกจากแอป
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSummary,
        child: _buildBodyContent(), // (ส่วนนี้เหมือนเดิม)
      ),
    );
  }

  // (ส่วน _buildBodyContent() เหมือนเดิมทุกประการ)
  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
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
      return const Center(child: Text('No data found.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SummaryCard(
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

// (Class SummaryCard เหมือนเดิม)
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
