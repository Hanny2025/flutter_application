import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class LecturerHistory extends StatefulWidget {
  final String userId;

  const LecturerHistory({super.key, required this.userId});

  @override
  State<LecturerHistory> createState() => _LecturerHistoryState();
}

class _LecturerHistoryState extends State<LecturerHistory> {
  // --- State Variables ---
  List<Map<String, dynamic>> _allHistoryList = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'approved', 'rejected'
  String? _username;

  // --- Lifecycle ---
  @override
  void initState() {
    super.initState();
    _fetchData(); // 1. ดึงข้อมูลประวัติ
    _fetchUsername(); // 2. ดึงชื่อผู้ใช้
  }

  // --- Data Fetching ---
  Future<void> _fetchData() {
    return _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final url = Uri.parse(
        'http://192.168.1.111:3000/history/all?user_id=${widget.userId}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _allHistoryList = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      print('Error fetching history: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchUsername() async {
    final url = Uri.parse(
        'http://192.168.1.111:3000/get_user?user_id=${widget.userId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _username = data['username'] ?? 'Manager'; // 
          });
        }
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  // --- Filtering Logic ---
  List<Map<String, dynamic>> _getFilteredHistory() {
    if (_selectedFilter == 'all') {
      return _allHistoryList;
    }
    return _allHistoryList
        .where((item) =>
            item['action']?.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredHistory();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // 
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Info (เหมือนในรูป)
            _buildUserInfo(),

            // 2. Filter Chips (เหมือนในรูป)
            _buildFilterChips(),

            // 3. History List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredList.isEmpty
                      ? const Center(
                          child: Text(
                            'No booking history found.',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            // 4. สร้าง Card (เหมือนในรูป)
                            return _buildHistoryCard(filteredList[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Icon(Icons.account_circle, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 8),
          Text(
            _username ?? 'Loading...', // 
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // 🔽🔽🔽 [แก้ไข] Widget นี้ 🔽🔽🔽
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // 👈 เพิ่มบรรทัดนี้
        children: [
          _buildFilterChip('all', 'All'),
          const SizedBox(width: 10),
          _buildFilterChip('approved', 'Approved'),
          const SizedBox(width: 10),
          _buildFilterChip('rejected', 'Rejected'),
        ],
      ),
    );
  }
  // 🔼🔼🔼 ----------------------- 🔼🔼🔼

  Widget _buildFilterChip(String filterName, String label) {
    final bool isSelected = _selectedFilter == filterName;
    return ActionChip(
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: isSelected ? Colors.blue.shade700 : Colors.grey.shade200,
      onPressed: () {
        setState(() {
          _selectedFilter = filterName;
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final String action = item['action'] ?? 'N/A';
    final String roomName = item['Room_name'] ?? 'Unknown Room';
    final String studentName = item['username'] ?? 'N/A';
    
    // Format Date (Oct 19, 2025)
    String date = 'N/A';
    try {
      if (item['booking_date'] != null) {
        final dateTime = DateTime.parse(item['booking_date']);
        date = DateFormat('MMM d, yyyy').format(dateTime.toLocal());
      }
    } catch (e) {
      date = item['booking_date'] ?? 'N/A';
    }
    
    // Format Time (8:00 AM - 10:00 AM)
    String time = item['Slot_label'] ?? 'N/A';
    // (ถ้า Slot_label เป็น '08:00 - 10:00' อยู่แล้ว ก็ใช้ได้เลย)
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              roomName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$date   $time',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Booked by $studentName',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: _buildStatusChip(action), // 
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String action) {
    Color chipColor;
    Color textColor;

    switch (action.toLowerCase()) {
      case 'approved':
        chipColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'rejected':
        chipColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      default:
        chipColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        action,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}