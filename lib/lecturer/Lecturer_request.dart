import 'package:flutter/material.dart';
// import 'Lecturer_Check.dart'; // ❌ ไม่ใช้ CheckPage แล้ว
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// ------------------------------------
// คลาส Widget (กรอบรูป)
// ------------------------------------
class Lecturer_req extends StatefulWidget {
  final String userId;

  const Lecturer_req({super.key, required this.userId});

  @override
  State<Lecturer_req> createState() => _Lecturer_reqState();
}

// ------------------------------------
// คลาส State (สิ่งที่อยู่ในกรอบ)
// ------------------------------------
class _Lecturer_reqState extends State<Lecturer_req> {
  // --- 1. ตัวแปรที่ใช้ใน State นี้ ---
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String? _errorMessage; 
  final String _baseUrl = 'http://172.27.9.232:3000'; 

  // --- 2. ฟังก์ชันที่ทำงานตอนเริ่มต้น (initState) ---
  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  // --- 3. ฟังก์ชันสำหรับดึงข้อมูลจาก API ---
  Future<void> _fetchRequests() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null; 
    });

    final url = Uri.parse('$_baseUrl/bookings/pending');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10)); 

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _requests = List<Map<String, dynamic>>.from(data.where((item) => item is Map<String, dynamic>));
            _isLoading = false;
          });
        }
      } else {
        String errorMsg = 'Failed to load requests (Code: ${response.statusCode})';
        try {
            final errorData = json.decode(response.body);
            errorMsg = errorData['message'] ?? errorMsg;
        } catch (_) {}

        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = errorMsg;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Connection Error: $e';
        });
      }
    }
  }

  // ⭐️ ฟังก์ชันใหม่: จัดการการปฏิเสธคำขอ (Reject)
  // 📍 แก้ไขปัญหา Reject แล้วไม่ขึ้น History โดยการลบรายการออกจาก Pending List ทันที
  Future<void> _handleReject(int bookingId, int index) async {
    // 1. เก็บและลบรายการออกจาก UI ทันที
    final removedRequest = _requests[index];
    setState(() {
      _requests.removeAt(index);
    });

    // 2. ส่ง API Request เพื่อ Reject
    final url = Uri.parse('$_baseUrl/bookings/action'); 
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'booking_id': bookingId,
          'action': 'rejected', // สถานะ Reject
          'action_by_user_id': widget.userId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking rejected successfully. 🚫')),
        );
      } else {
        // ❌ Fail: นำรายการกลับเข้าสู่ UI และแจ้ง Error
        setState(() {
          _requests.insert(index, removedRequest);
        });
        String errorMsg = 'Failed to reject booking (Code: ${response.statusCode})';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMsg')),
        );
      }
    } catch (e) {
      // ❌ Fail: Connection Error
      setState(() {
        _requests.insert(index, removedRequest);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection Error: Cannot reject.')),
      );
    }
  }
  
  // --- Helper Function สำหรับ Format วันที่ ---
  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';
    String dateString = dateValue.toString();
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(dateTime.toLocal());
    } catch (_) {
      return dateString;
    }
  }

  // --- 4. ส่วนแสดงผล (build) ---
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator( 
      onRefresh: _fetchRequests,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), 
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                Text(
                  'Error loading requests: $_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _fetchRequests,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_requests.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Column(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
                const SizedBox(height: 10),
                const Text(
                  'No Pending Requests.',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Text(
                  'Requests for approval will appear here.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // 4. Data List
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        final formattedDate = _formatDate(request["date"]);
        final String roomName = request["roomName"] ?? 'No Name';
        final String username = request["username"] ?? 'No User';
        final String time = request["time"] ?? 'No Time';
        
        // 💡 ตรวจสอบว่ามี Booking_id หรือไม่
        final int? bookingId = request['Booking_id'];
        if (bookingId == null) {
            return Container(); // ไม่แสดงรายการที่ไม่มี ID
        }

        return Dismissible( // 🌟 ใช้ Dismissible สำหรับ Reject Action (ปัดขวาไปซ้าย)
          key: ValueKey(bookingId), 
          direction: DismissDirection.endToStart, 
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.cancel, color: Colors.white, size: 30),
          ),
          confirmDismiss: (direction) async {
            // 💡 สามารถใส่ AlertDialog ยืนยันการ Reject ได้ตรงนี้
            return true;
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              _handleReject(bookingId, index);
            }
          },
          
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // --- Image (โค้ดเดิม) ---
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: (request["image"] != null &&
                                request["image"].toString().isNotEmpty)
                            ? Image.network(
                                request["image"]!,
                                width: 85,
                                height: 85,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/imgs/room.jpg',
                                    width: 85,
                                    height: 85,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/imgs/room.jpg', 
                                width: 85,
                                height: 85,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 14),

                      // --- Details (โค้ดเดิม) ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    roomName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // User
                            Row(
                              children: [
                                const Icon(Icons.person, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    username,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Date & Time
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  time,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6),
                      // 💡 เปลี่ยน Icon เป็น Reject (ถ้าไม่ใช้ Dismissible)
                      const Icon(
                        Icons.swipe_left, 
                        size: 16,
                        color: Colors.red,
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}