import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class EditRoomListPage extends StatefulWidget {
  const EditRoomListPage({super.key});

  @override
  State<EditRoomListPage> createState() => _EditRoomListPageState();
}

class _EditRoomListPageState extends State<EditRoomListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> rooms = [];
  String searchText = "";

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      final response = await http.get(Uri.parse('http://26.122.43.191/staff/rooms'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          rooms = List<Map<String, dynamic>>.from(data['data']);
        });
      } else {
        throw Exception('Failed to load rooms');
      }
    } catch (error) {
      print('Error fetching rooms: $error');
      // แสดง error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredRooms = rooms
        .where((room) =>
            room["Room_name"].toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Room List",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E63F3),
      ),

      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: "search room...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filteredRooms.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final room = filteredRooms[index];
                final status = room["status"];
                Color statusColor;

                switch (status) {
                  case "Free":
                    statusColor = Colors.green;
                    break;
                  case "Reserved":
                    statusColor = Colors.orange;
                    break;
                  default:
                    statusColor = Colors.red;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      // 📷 Placeholder รูป
                      Container(
                        width: 100,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAEAEA),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        child: room["image_url"] == null || room["image_url"] == ""
                            ? const Icon(Icons.image_not_supported_outlined,
                                color: Colors.black45, size: 40)
                            : ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                child: Image.network(
                                  room["image_url"],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image_not_supported_outlined,
                                        color: Colors.black45, size: 40);
                                  },
                                ),
                              ),
                      ),

                      // 📝 ข้อมูลห้อง
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room["Room_name"] ?? "No Name",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text(
                                    "status : ",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    status ?? "Unknown",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Price: ${room["price_per_day"] ?? "N/A"}฿",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ✏️ ปุ่ม Edit
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditRoomPage(
                                  roomData: room,
                                  onRoomUpdated: _fetchRooms,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text("Edit"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[600],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E63F3),
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Edit'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
      ),
    );
  }
}

// --------------------------------------------------------
// PAGE 2: Edit Room Page
// --------------------------------------------------------
class EditRoomPage extends StatefulWidget {
  final Map<String, dynamic> roomData;
  final VoidCallback onRoomUpdated;

  const EditRoomPage({
    super.key,
    required this.roomData,
    required this.onRoomUpdated,
  });

  @override
  State<EditRoomPage> createState() => _EditRoomPageState();
}

class _EditRoomPageState extends State<EditRoomPage> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String selectedStatus = "Free";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ตั้งค่าเริ่มต้นจากข้อมูลห้อง
    _roomNameController.text = widget.roomData["Room_name"] ?? "";
    _priceController.text = widget.roomData["price_per_day"]?.toString() ?? "";
    selectedStatus = widget.roomData["status"] ?? "Free";
  }

  // API: อัพเดทข้อมูลห้อง
  Future<void> _updateRoom() async {
    if (_roomNameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://26.122.43.191/staff/edit_room'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "Room_id": widget.roomData["Room_id"],
          "Room_name": _roomNameController.text,
          "image_url": widget.roomData["image_url"], // ยังใช้รูปเดิม
          "price_per_day": int.tryParse(_priceController.text) ?? 0,
          "status": selectedStatus,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        
        // callback เพื่อ refresh ข้อมูลในหน้าแรก
        widget.onRoomUpdated();
        
        // กลับไปหน้าก่อนหน้า
        Navigator.pop(context);
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['message'])),
        );
      }
    } catch (error) {
      print('Error updating room: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Room",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E63F3),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔶 Edit Room Button
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, color: Colors.black),
                        label: const Text(
                          "Edit Room",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🖼 Room Pictures
                  const Text(
                    "Room Pictures",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement image upload
                    },
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: widget.roomData["image_url"] != null && 
                             widget.roomData["image_url"] != ""
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.roomData["image_url"],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.image_not_supported_outlined,
                                            size: 40, color: Colors.black54),
                                        SizedBox(height: 5),
                                        Text(
                                          "Image not available",
                                          style: TextStyle(color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined,
                                      size: 40, color: Colors.black54),
                                  SizedBox(height: 5),
                                  Text(
                                    "Tap to upload room picture",
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🏷 Room Name
                  const Text(
                    "Room name",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _roomNameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 💰 Price per day
                  const Text(
                    "Price per day",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ⚙️ Room Status
                  const Text(
                    "Room Status",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Free",
                        child: Row(
                          children: [
                            Icon(Icons.circle, color: Colors.green, size: 15),
                            SizedBox(width: 8),
                            Text("Free"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Reserved",
                        child: Row(
                          children: [
                            Icon(Icons.circle, color: Colors.orange, size: 15),
                            SizedBox(width: 8),
                            Text("Reserved"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Disabled",
                        child: Row(
                          children: [
                            Icon(Icons.circle, color: Colors.red, size: 15),
                            SizedBox(width: 8),
                            Text("Disabled"),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedStatus = value!);
                    },
                  ),

                  const SizedBox(height: 30),

                  // 💾 Save Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateRoom,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E63F3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 90, vertical: 14),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "Save Changes",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}