import 'package:flutter/material.dart';
import 'Lecturer_Check.dart'; // ตรวจสอบว่าไฟล์นี้มีอยู่จริง
import 'BottomNav.dart'; // ตรวจสอบว่าไฟล์นี้มีอยู่จริง

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// ------------------------------------
// คลาส Widget (กรอบรูป)
// ------------------------------------
class Lecturer_req extends StatefulWidget {
  const Lecturer_req({super.key});

  @override
  State<Lecturer_req> createState() => _Lecturer_reqState();
}

// ------------------------------------
// คลาส State (สิ่งที่อยู่ในกรอบ)
// ------------------------------------
class _Lecturer_reqState extends State<Lecturer_req> {
  // --- 1. ตัวแปรที่ใช้ใน State นี้ ---
  static const Color Background_head = Color.fromARGB(255, 0, 62, 195);

  // ตัวแปรสำหรับเก็บข้อมูลที่ดึงจาก API
  List<Map<String, dynamic>> _requests = [];

  // ตัวแปรเช็กสถานะการโหลด
  bool _isLoading = true;

  // --- 2. ฟังก์ชันที่ทำงานตอนเริ่มต้น (initState) ---
  @override
  void initState() {
    super.initState();
    // เรียกฟังก์ชันดึงข้อมูลทันทีที่เปิดหน้านี้
    _fetchRequests();
  }

  // --- 3. ฟังก์ชันสำหรับดึงข้อมูลจาก API ---
  Future<void> _fetchRequests() async {
    // !! ใส่ URL ของ API ที่คุณสร้างไว้ตรงนี้ !!
    final url = Uri.parse(
      'http://10.2.21.252:3000/bookings/pending',
    ); // <--- ⚠️ แก้ไขตรงนี้

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // ถ้าสำเร็จ (OK 200)
        final List<dynamic> data = json.decode(response.body);

        // อัปเดต state ของแอปด้วยข้อมูลใหม่
        setState(() {
          _requests = List<Map<String, dynamic>>.from(data);
          _isLoading = false; // โหลดเสร็จแล้ว
        });
      } else {
        // ถ้า Server ตอบกลับมาไม่สำเร็จ (เช่น 404, 500)
        print('Failed to load requests. Status code: ${response.statusCode}');
        setState(() {
          _isLoading = false; // โหลดไม่สำเร็จ
        });
      }
    } catch (e) {
      // ถ้าเกิด Error ตอนเชื่อมต่อ (เช่น ไม่มีเน็ต, server ปิด)
      print('Error fetching requests: $e');
      setState(() {
        _isLoading = false; // โหลดไม่สำเร็จ
      });
    }
  }

  // --- 4. ส่วนแสดงผล (build) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Request customer',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Background_head,
      ),

      // เช็กสถานะการโหลดก่อนแสดงผล
      body: _isLoading
          ? const Center(
              // 1. ถ้ากำลังโหลด: แสดงวงกลมหมุนๆ
              child: CircularProgressIndicator(),
            )
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
                        builder: (context) => CheckPage(requestData: request),
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
                          // รูปห้อง
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

                          // รายละเอียดห้อง
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🔹 ชื่อห้อง + ราคา
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
                                    Text(
                                      // 1. เช็กก่อนว่า "price" ไม่ใช่ null ใช่ไหม
                                      (request["price"] != null)
                                          // 2. ถ้าไม่ null, ให้แปลงเป็น String ก่อนแสดงผล
                                          ? ' ${request["price"]} THB/HOUR'
                                          // 3. ถ้าเป็น null, ให้แสดง 'No Price'
                                          : 'No Price',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(
                                          0xFF003EC3,
                                        ), // ใช้สี Background_head
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // 🔹 User
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

                                // 🔹 Date + Time
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

                          // 🔹 ลูกศร
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
            ),

      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
    );
  }
}
