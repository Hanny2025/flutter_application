import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';



class RoomOverviewPage extends StatefulWidget {
  const RoomOverviewPage({super.key});


  @override
  State<RoomOverviewPage> createState() => _RoomOverviewPageState();
}


class _RoomOverviewPageState extends State<RoomOverviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;


  // Fake sample data
  final List<Map<String, dynamic>> rooms = [
    {"room": "Room 101", "status": "Free", "price": 1200},
    {"room": "Room 102", "status": "Reserved", "price": 1500},
    {"room": "Room 201", "status": "Disabled", "price": 2000},
    {"room": "Room 202", "status": "Free", "price": 1000},
  ];


  String selectedFilter = "All";


  final List<Map<String, dynamic>> bookings = [
    {
      "room": "Room 101",
      "date": "Oct 19, 2025",
      "time": "8:00 AM - 10:00 AM",
      "bookedBy": "Jayden Smith",
      "approvedBy": "Manager Sam",
      "status": "Approved"
    },
    {
      "room": "Room 201",
      "date": "Oct 20, 2025",
      "time": "8:00 AM - 10:00 AM",
      "bookedBy": "Arthur Wilson",
      "approvedBy": "Manager Sam",
      "status": "Approved"
    },
  ];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }


  Color _statusColor(String status) {
    switch (status) {
      case "Free":
        return Colors.green;
      case "Reserved":
        return Colors.orange;
      case "Disabled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredBookings = bookings.where((b) {
      if (selectedFilter == "All") return true;
      return b["status"] == selectedFilter;
    }).toList();


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Room Overview",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E63F3),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Status"),
            Tab(text: "History"),
          ],
        ),
      ),


      body: TabBarView(
        controller: _tabController,
        children: [
          // ---------------------------------------
          //               STATUS TAB
          // ---------------------------------------
          ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];


              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room["room"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text("Status: "),
                        Text(
                          room["status"],
                          style: TextStyle(
                              color: _statusColor(room["status"]),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text("Price: ${room["price"]} ฿"),
                  ],
                ),
              );
            },
          ),


          // ---------------------------------------
          //               HISTORY TAB
          // ---------------------------------------
          Column(
            children: [
              const SizedBox(height: 10),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _filterButton("All"),
                  _filterButton("Approved"),
                ],
              ),


              const SizedBox(height: 10),


              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];


                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking["room"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text("${booking["date"]}   ${booking["time"]}"),
                          Text("Booked by: ${booking["bookedBy"]}"),
                          Text("Approved by: ${booking["approvedBy"]}"),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Approved",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          )
        ],
      ),


      // ---------------------------------------
      //       BOTTOM NAV 6 ICONS (ตามแบบคุณ)
      // ---------------------------------------
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E63F3),
        unselectedItemColor: Colors.grey,
        currentIndex: 4,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Edit'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined), label: 'Add'),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
      ),
    );
  }


  // Filter Button UI
  Widget _filterButton(String label) {
    bool isSelected = selectedFilter == label;
    return ElevatedButton(
      onPressed: () => setState(() => selectedFilter = label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF1E63F3) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        elevation: isSelected ? 2 : 0,
        side: const BorderSide(color: Colors.black12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}



