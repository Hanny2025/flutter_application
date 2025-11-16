import 'package:flutter/material.dart';
import 'Lecturer_Check.dart';
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

  // --- 2. ฟังก์ชันที่ทำงานตอนเริ่มต้น (initState) ---
  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  // --- 3. ฟังก์ชันสำหรับดึงข้อมูลจาก API ---
  Future<void> _fetchRequests() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final url = Uri.parse('http://192.168.1.111:3000/bookings/pending');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _requests = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        }
      } else {
        print('Failed to load requests. Status code: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching requests: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- 4. ส่วนแสดงผล (build) ---
  @override
  Widget build(BuildContext context) {
    // คืนค่า body (ListView) โดยตรง
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _requests.length,
            itemBuilder: (context, index) {
              final request = _requests[index];

              // ✅ Format date
              DateTime? dateTime;
              try {
                if (request["date"] != null) {
                  dateTime = DateTime.parse(request["date"]);
                }
              } catch (_) {}
              final formattedDate = (dateTime != null)
                  ? DateFormat('dd/MM/yyyy').format(dateTime.toLocal())
                  : (request["date"] ?? 'No Date');

              return GestureDetector(
                // ⭐️ แก้ไข: ใช้ async/await เพื่อรอผลลัพธ์จาก CheckPage
                onTap: () async {
                  final shouldRefresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckPage(
                        userId: widget.userId,
                        requestData: request,
                      ),
                    ),
                  );

                  if (shouldRefresh == true) {
                    await _fetchRequests();
                  }
                },
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  shadowColor: Colors.black26,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ... (โค้ดแสดงรูปภาพ) ...
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child:
                              (request["image"] != null &&
                                  request["image"].toString().isNotEmpty)
                              ? Image.network(
                                  request["image"]!,
                                  width: 85,
                                  height: 85,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // ถ้ารูปโหลดไม่ได้ → ใช้รูปใน assets แทน
                                    return Image.asset(
                                      'assets/imgs/room.jpg',
                                      width: 85,
                                      height: 85,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/imgs/room.jpg', // 👈 แสดงรูปจาก assets ถ้าไม่มี URL
                                  width: 85,
                                  height: 85,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(width: 14),

                        // ... (โค้ดแสดงรายละเอียด) ...
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      request["roomName"] ?? 'No Name',
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
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      request["username"] ?? 'No User',
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
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    request["time"] ?? 'No Time',
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
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
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
