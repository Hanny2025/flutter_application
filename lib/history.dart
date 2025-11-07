import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

const Color primaryBlue = Color(0xFF1976D2);
const Color darkGrey = Color(0xFF333333);

class History extends StatefulWidget {
  final String userId; // ✅ รับ userId
  const History({super.key, required this.userId});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  late Future<List<dynamic>> _historyFuture;
  final String serverIp = '172.27.8.71';

  String _selectedFilter = 'All';
  final List<String> filters = const ['All', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _historyFuture = fetchHistory();
  }

  Future<List<dynamic>> fetchHistory() async {
    final url = Uri.parse(
      'http://$serverIp:3000/check?user_id=${widget.userId}',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;

        return data;
      } else {
        throw Exception(
          'Failed to load history (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch history: $e');
    }
  }

  // ✅ เพิ่มฟังก์ชันรีเฟรชข้อมูล
  Future<void> _refreshData() async {
    setState(() {
      _historyFuture = fetchHistory();
    });
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  Color _mapStatusToColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return const Color(0xFF00B909); // เขียว
      case 'rejected':
        return const Color(0xFFD32F2F); // แดง
      case 'pending':
        return const Color(0xFFC7B102); // เหลือง
      default:
        return Colors.grey;
    }
  }

  Color _mapStatusToBgColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return const Color(0xFFD4FFD6); // เขียวอ่อน
      case 'rejected':
        return const Color(0xFFFFD4D4); // แดงอ่อน
      case 'pending':
        return const Color(0xFFF9F7A2); // เหลืองอ่อน
      default:
        return Colors.grey.shade200;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'No Date';
    try {
      // 1. แปลงสตริงให้เป็น DateTime
      final DateTime date = DateTime.parse(dateStr);

      // 2. แปลงเป็นเวลาท้องถิ่นของอุปกรณ์ (สำคัญ!)
      // ถ้า dateStr เป็น UTC, .toLocal() จะปรับวันที่/เวลา ให้ตรงกับ Timezone ของอุปกรณ์
      final DateTime localDate = date.toLocal();

      // 3. จัดรูปแบบเฉพาะวันที่
      // DateFormat.yMMMd().format(localDate) จะดีกว่าเพราะรองรับ Locale
      return DateFormat('MMM d, yyyy').format(localDate);
    } catch (e) {
      // ในกรณีที่สตริงเป็นแค่ "YYYY-MM-DD" ที่ไม่มีเวลา
      if (dateStr!.length <= 10) {
        // ให้ใช้ DateFormat.yMMMd() เพื่อจัดการกับสตริงวันที่เท่านั้น
        try {
          final DateTime dateOnly = DateFormat('yyyy-MM-dd').parse(dateStr);
          return DateFormat('MMM d, yyyy').format(dateOnly);
        } catch (_) {
          return dateStr;
        }
      }
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: primaryBlue,
        centerTitle: true,
        title: const Text(
          'Booking History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            // แถบตัวเลือก
            FilterChipRow(
              filters: filters,
              selectedFilter: _selectedFilter,
              onSelected: _onFilterSelected,
            ),

            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  // กำลังโหลด
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Error
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading history:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _refreshData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // ไม่มีข้อมูล
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.history_toggle_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No booking history found.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _refreshData,
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    );
                  }

                  // มีข้อมูล
                  final List<dynamic> allHistory = snapshot.data!;

                  // ✅ แสดงเฉพาะ approved และ rejected (ไม่แสดง pending)
                  final completedHistory = allHistory.where((item) {
                    final status =
                        item['status']?.toString().toLowerCase() ?? '';
                    return status == 'approved' || status == 'rejected';
                  }).toList();

                  // กรองตาม Chip ที่เลือก
                  final List<dynamic> filteredList;
                  if (_selectedFilter == 'All') {
                    filteredList = completedHistory;
                  } else {
                    filteredList = completedHistory.where((item) {
                      final status =
                          item['status']?.toString().toLowerCase() ?? '';
                      return status == _selectedFilter.toLowerCase();
                    }).toList();
                  }

                  // ตรวจว่าหลังกรองแล้วว่างหรือไม่
                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.filter_alt_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ${_selectedFilter == 'All' ? 'completed bookings' : '$_selectedFilter bookings'} found.',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // เรียงลำดับตามวันที่ (ใหม่สุดอยู่บน)
                  filteredList.sort((a, b) {
                    final dateA = DateTime.tryParse(a['booking_date'] ?? '');
                    final dateB = DateTime.tryParse(b['booking_date'] ?? '');
                    if (dateA == null || dateB == null) return 0;
                    return dateB.compareTo(dateA); // ใหม่ -> เก่า
                  });

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final String status =
                          item['status']?.toString().toLowerCase() ?? 'unknown';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: HistoryCard(
                          roomNumber:
                              item['Room_name']?.toString() ?? 'No Name',
                          date: _formatDate(item['booking_date']?.toString()),
                          time: item['Slot_label']?.toString() ?? 'N/A',
                          status: status,
                          statusColor: _mapStatusToColor(status),
                          backgroundColor: _mapStatusToBgColor(status),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// WIDGETS ย่อย: Filter Chip Row
// ------------------------------------------------------------------
class FilterChipRow extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const FilterChipRow({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = filter == selectedFilter;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                selectedColor: primaryBlue,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                backgroundColor: Colors.grey[200],
                onSelected: (selected) {
                  if (selected) {
                    onSelected(filter);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// WIDGETS ย่อย: History Card
// ------------------------------------------------------------------
class HistoryCard extends StatelessWidget {
  final String roomNumber;
  final String date;
  final String time;
  final String status;
  final Color statusColor;
  final Color backgroundColor;

  const HistoryCard({
    super.key,
    required this.roomNumber,
    required this.date,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roomNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}
