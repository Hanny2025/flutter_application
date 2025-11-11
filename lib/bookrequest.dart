import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

const Color primaryBlue = Color(0xFF1976D2);

class Bookrequest extends StatefulWidget {
  final Map<String, dynamic> roomData;
  final String userId;
  final String userRole;

  const Bookrequest({
    super.key,
    required this.roomData,
    required this.userId,
    required this.userRole,
  });

  @override
  State<Bookrequest> createState() => _BookrequestState();
}

class _BookrequestState extends State<Bookrequest> {
  DateTime? _selectedDate;
  int? _selectedSlotId;
  bool _isLoading = false;
  final String serverIp = '172.25.57.119';

  @override
  void initState() {
    super.initState();
    // ✅ สำหรับ Student ตั้งค่าวันที่เป็นวันนี้โดยอัตโนมัติ
    if (widget.userRole == 'Users') {
      _selectedDate = DateTime.now();
    } else {
      _selectedDate = DateTime.now(); // Staff/Lecturer ยังใช้วันนี้เป็น default
    }
  }

  // ✅ ฟังก์ชันตรวจสอบ slot ที่จองได้สำหรับ Student
  bool _isSlotAvailableForBooking(dynamic slot) {
    if (widget.userRole != 'Users') return true;

    final slotStatus = _getSlotStatus(slot);
    final slotLabel = _formatSlotLabel(slot);
    final DateTime now = DateTime.now();

    // ต้องเป็น Free และยังไม่ผ่านเวลา
    if (slotStatus.toLowerCase() != 'free') return false;
    return _isFutureTimeSlot(slotLabel, now);
  }

  // ✅ ตรวจสอบว่า slot นี้ยังไม่ผ่านเวลา
  bool _isFutureTimeSlot(String slotLabel, DateTime now) {
    final timeMap = {
      '8:00-10:00': 8,
      '10:00-12:00': 10,
      '13:00-15:00': 13,
      '15:00-17:00': 15,
    };

    final startHour = timeMap[slotLabel];
    if (startHour == null) return true;
    return now.hour < startHour;
  }

  // ✅ ฟังก์ชันส่งการจองพร้อมตรวจสอบเงื่อนไข
  Future<void> _submitBooking() async {
    if (_selectedDate == null || _selectedSlotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time slot'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ ตรวจสอบเงื่อนไข Student: ต้องเป็นวันนี้
    if (widget.userRole == 'Users') {
      final today = DateTime.now();
      final selected = _selectedDate!;
      if (selected.year != today.year ||
          selected.month != today.month ||
          selected.day != today.day) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Students can only book for today'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Debug: log outgoing booking
      debugPrint(
        'Booking POST -> room:${widget.roomData['Room_id']} slot:$_selectedSlotId date:${DateFormat('yyyy-MM-dd').format(_selectedDate!)} user:${widget.userId}',
      );
      final response = await http.post(
        Uri.parse('http://$serverIp:3000/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'room_id': widget.roomData['Room_id'],
          'slot_id': _selectedSlotId,
          'user_id': int.parse(widget.userId),
          'booking_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        }),
      );

      // Debug: log response status and body
      debugPrint(
        'Booking POST response -> status:${response.statusCode} body:${response.body}',
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Try to fetch latest room statuses so parent can refresh with up-to-date data
        try {
          final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          final roomsUrl = Uri.parse('http://$serverIp:3000/rooms-with-status?date=$today');
          final roomsResp = await http.get(roomsUrl).timeout(const Duration(seconds: 10));
          debugPrint('Post-success: fetched rooms -> status:${roomsResp.statusCode}');
        } catch (e) {
          debugPrint('Post-success: error fetching rooms after booking -> $e');
        }

        Navigator.pop(context, true);
      } else {
        // Try to extract a helpful error message from the server response.
        String message;
        try {
          final parsed = json.decode(response.body);
          if (parsed is Map && parsed['message'] != null) {
            message = parsed['message'].toString();
          } else {
            // If the JSON doesn't have 'message', fall back to full body
            message = response.body.toString();
          }
        } catch (_) {
          // Non-JSON response (plain text). Show raw body.
          message = response.body.toString();
        }

        debugPrint('Booking failed -> status:${response.statusCode} body:${response.body}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.isNotEmpty ? message : 'Booking failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatSlotLabel(dynamic slot) {
    if (slot is Map<String, dynamic>) {
      return slot['Slot_label']?.toString() ?? 'N/A';
    }
    return 'N/A';
  }

  int _getSlotId(dynamic slot) {
    if (slot is Map<String, dynamic>) {
      return slot['Slot_id'] as int? ?? 0;
    }
    return 0;
  }

  String _getSlotStatus(dynamic slot) {
    if (slot is Map<String, dynamic>) {
      return slot['Slot_status']?.toString() ?? 'Free';
    }
    return 'Free';
  }

  @override
  Widget build(BuildContext context) {
    final roomName = widget.roomData['Room_name']?.toString() ?? 'Unknown Room';
    final slots = widget.roomData['slots'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Room'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roomName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Room ID: ${widget.roomData['Room_id']}'),
                    Text('User ID: ${widget.userId}'),
                    Text(
                      'Role: ${widget.userRole}',
                    ), // ✅ แสดง role สำหรับ debug
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Date Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // แสดงวันที่เป็นวันนี้เท่านั้น (ไม่มีปุ่มเลือกวันที่)
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat(
                            'MMM d, yyyy',
                          ).format(_selectedDate ?? DateTime.now()),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    // ✅ แสดงข้อความสำหรับ Student
                    if (widget.userRole == 'Users') ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Note: Students can only book for today',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Time Slots
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Time Slot',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: slots.length,
                          itemBuilder: (context, index) {
                            final slot = slots[index];
                            final slotLabel = _formatSlotLabel(slot);
                            final slotId = _getSlotId(slot);
                            final slotStatus = _getSlotStatus(slot);

                            // ✅ ใช้ฟังก์ชันตรวจสอบสำหรับ Student
                            final isAvailable = widget.userRole == 'Users'
                                ? _isSlotAvailableForBooking(slot)
                                : slotStatus.toLowerCase() == 'free';

                            final isSelected = _selectedSlotId == slotId;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: isSelected
                                  ? primaryBlue.withOpacity(0.1)
                                  : Colors.white,
                              child: ListTile(
                                leading: Icon(
                                  isAvailable ? Icons.access_time : Icons.block,
                                  color: isAvailable ? primaryBlue : Colors.red,
                                ),
                                title: Text(slotLabel),
                                subtitle: Text(
                                  isAvailable ? 'Available' : 'Not Available',
                                  style: TextStyle(
                                    color: isAvailable
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : null,
                                onTap: isAvailable
                                    ? () {
                                        setState(() {
                                          _selectedSlotId = slotId;
                                        });
                                      }
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Booking Request',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
