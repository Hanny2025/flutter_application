import 'package:flutter/material.dart';
import 'Lecturer_Check.dart'; // 👈 (จำเป็น) สำหรับการ Navigate

// 🗑️ ลบ import Bottom_Nav.dart (ซ้ำซ้อน และหน้านี้ไม่ควรมี Nav)
// import 'package:flutter_application/Bottom_Nav.dart';
// import '../Bottom_Nav.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// ------------------------------------
// คลาส Widget (กรอบรูป)
// ------------------------------------
class Lecturer_req extends StatefulWidget {
  // ⭐️ 1. เพิ่มตัวรับ userId
  final String userId;

  const Lecturer_req({
    super.key,
    required this.userId, // 👈 เพิ่ม required this.userId ตรงนี้
  });

  @override
  State<Lecturer_req> createState() => _Lecturer_reqState();
}

// ------------------------------------
// คลาส State (สิ่งที่อยู่ในกรอบ)
// ------------------------------------
class _Lecturer_reqState extends State<Lecturer_req> {
  // --- 1. ตัวแปรที่ใช้ใน State นี้ ---
  // 🗑️ ลบ Background_head (ตอนนี้ AppBar อยู่ที่ Browse_Lecturer)
  // static const Color Background_head = Color.fromARGB(255, 0, 62, 195);

  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  // 🗑️ 2. ลบ _selectedIndex (หน้านี้ไม่ต้องมี Nav ของตัวเอง)
  // int _selectedIndex = 0;

  // --- 2. ฟังก์ชันที่ทำงานตอนเริ่มต้น (initState) ---
  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  // --- 3. ฟังก์ชันสำหรับดึงข้อมูลจาก API ---
  Future<void> _fetchRequests() async {
    // ⭐️ 3. (แนะนำ) เราสามารถใช้ userId ที่รับมาเพื่อกรองข้อมูลได้
    //    (ถ้า API ของคุณรองรับการกรอง)
    //    ตัวอย่าง: '.../bookings/pending?lecturer_id=${widget.userId}'
    //    ถ้า API ไม่รองรับ ก็ใช้ URL เดิมได้ครับ
    final url = Uri.parse(
      'http://10.2.21.252:3000/bookings/pending',
    ); // <--- ⚠️ ตรวจสอบ URL ของคุณ

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _requests = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        print('Failed to load requests. Status code: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching requests: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- 4. ส่วนแสดงผล (build) ---
  @override
  Widget build(BuildContext context) {
    // ⭐️ 4. ลบ Scaffold, AppBar, และ BottomNavigationBar ออก
    // เพราะหน้านี้จะถูกแสดงใน 'body' ของ Browse_Lecturer
    // ซึ่งมี Scaffold ของตัวเองอยู่แล้ว

    // return Scaffold( 👈 ลบ
    //   appBar: AppBar( 👈 ลบ
    //     ...
    //   ), 👈 ลบ

    // ⭐️ 5. คืนค่า body (ListView) โดยตรง
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // ⭐️ (ยังคงเดิม) ส่งข้อมูลไปหน้า CheckPage
                      builder: (context) => CheckPage(
                        userId: widget.userId, // 👈 เพิ่มบรรทัดนี้
                        requestData: request,
                      ),
                    ),
                  );
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
                          child: (request["image"] != null)
                              ? Image.network(
                                  request["image"]!,
                                  width: 85,
                                  height: 85,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 85,
                                      height: 85,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[400],
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: 85,
                                  height: 85,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[400],
                                  ),
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

    // 🗑️ 6. ลบ BottomNavigationBar
    //   bottomNavigationBar: BottomNavigationBar( 👈 ลบ
    //     ...
    //   ), 👈 ลบ
    // ); 👈 ลบ
  }
}
