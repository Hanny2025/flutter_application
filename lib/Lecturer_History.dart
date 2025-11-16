import 'package:flutter/material.dart';
import 'BottomNav.dart';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedFilter = 'All';
  String currentUserName = 'Loading...';
  int? currentUserId;

  final String _baseUrl = 'http://10.0.2.2:3000';

  bool _loading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _allBookings = [];

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  // โหลด User → โหลดประวัติ
  Future<void> _loadPageData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final userName = prefs.getString('username');

    if (userId == null) {
      setState(() {
        currentUserName = 'Not logged in';
        _loading = false;
        _errorMessage = "User not logged in.";
      });
      return;
    }

    setState(() {
      currentUserId = userId;
      currentUserName = userName ?? 'User';
    });

    await _fetchBookings(userId);
  }

  // โหลดข้อมูล booking จาก backend
  Future<void> _fetchBookings(int userId) async {
    final url = Uri.parse("$_baseUrl/history?user_id=$userId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          _allBookings =
              data.map((item) => item as Map<String, dynamic>).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _errorMessage =
              "Failed to load history (Code: ${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = "Error: $e";
      });
    }
  }

  // แปลงวันที่
  String _formatDate(String? d) {
    if (d == null) return "N/A";
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  Color _getStatusColor(String? action) {
    if (action == 'Approved') return Colors.greenAccent.shade100;
    if (action == 'Rejected') return Colors.redAccent.shade100;
    return Colors.orangeAccent.shade100;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = _allBookings.where((b) {
      if (selectedFilter == "All") return true;
      return b["action"] == selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text('Booking History',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          if (currentUserId != null) {
            await _fetchBookings(currentUserId!);
          }
        },
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ชื่อ user
                        Row(
                          children: [
                            const Icon(Icons.person_outline,
                                color: Colors.grey, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              currentUserName,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Filter buttons
                        Row(
                          children: [
                            Expanded(child: _buildFilter("All")),
                            const SizedBox(width: 8),
                            Expanded(child: _buildFilter("Approved")),
                            const SizedBox(width: 8),
                            Expanded(child: _buildFilter("Rejected")),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // รายการประวัติ
                        Expanded(
                          child: filtered.isEmpty
                              ? const Center(
                                  child: Text("No booking history found."),
                                )
                              : ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (_, i) {
                                    final item = filtered[i];

                                    final name =
                                        item["Room_name"] ?? "Unknown Room";
                                    final slot =
                                        item["Slot_label"] ?? "Unknown Slot";
                                    final date = _formatDate(
                                        item["booking_date"]);
                                    final action =
                                        item["action"] ?? "Pending";

                                    return Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(name,
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.bold)),
                                          const SizedBox(height: 8),
                                          Text("$date   $slot"),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(action),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                action,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                        ),
                      ],
                    ),
                  ),
      ),

      bottomNavigationBar:
          const AppBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildFilter(String label) {
    final bool selected = selectedFilter == label;

    return ElevatedButton(
      onPressed: () {
        setState(() => selectedFilter = label);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selected ? Colors.grey.shade400 : Colors.grey.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: Colors.black,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }
}
