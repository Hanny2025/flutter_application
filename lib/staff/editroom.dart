import 'package:flutter/material.dart';
import 'package:flutter_application/staff/dashboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ⭐️ [เพิ่ม] Imports สำหรับการนำทาง (Navigation)
import 'addroom.dart';
import 'browse_room.dart';
import 'history.dart';

class EditRoomListPage extends StatefulWidget {
  final String userID;
  final String userRole;

  const EditRoomListPage({
    super.key,
    required this.userID,
    required this.userRole,
  });

  @override
  State<EditRoomListPage> createState() => _EditRoomListPageState();
}

class _EditRoomListPageState extends State<EditRoomListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> rooms = [];
  String searchText = "";
  int _currentIndex = 1;

  // ⭐️ [แก้ไข] ฟังก์ชันแปลง URL ที่ถูกต้อง
  String _getFullImageUrl(String imageUrl) {
    if (imageUrl.isEmpty || imageUrl == 'null') return '';
    
    // ถ้า URL เริ่มต้นด้วย http อยู่แล้ว
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }
    
    // ถ้าเป็น relative path
    const serverIp = '26.122.43.191:3000';
    String cleanUrl = imageUrl.replaceAll(' ', '');
    
    if (cleanUrl.startsWith('/')) {
      return 'http://$serverIp$cleanUrl';
    } else {
      return 'http://$serverIp/$cleanUrl';
    }
  }

  // ⭐️ [เพิ่ม] ฟังก์ชันแปลงข้อมูลห้อง
// ⭐️ [แก้ไข] ฟังก์ชันแปลงข้อมูลห้อง
  Map<String, dynamic> _parseRoomData(dynamic roomData) {
    if (roomData is Map<String, dynamic>) {
      
      // 1. ดึงค่า status จาก API
      String? apiStatus = roomData['status']?.toString();
      String finalStatus;

      // 2. ตรวจสอบค่า
      if (apiStatus == "Free") {
        finalStatus = "Free";
      } 
      // ⭐️ [แก้ไข] เพิ่มการตรวจสอบ "Disabled" โดยตรง
      else if (apiStatus == "Disabled") {
        finalStatus = "Disabled";
      }
      // 3. ถ้าค่าเป็น null, "" (ว่าง), หรือค่าอื่นๆ ที่ไม่รู้จัก
      //    (เช่น "Pending" หรือ "Reserved" ที่หน้านี้ไม่รองรับ)
      //    ให้แปลงเป็น "Disabled" ตามที่คุณต้องการ
      else {
        // 👈 ถ้า API ส่ง null หรือ "" มา มันจะเข้าเงื่อนไขนี้
        finalStatus = "Disabled"; 
      }
      
      return {
        'Room_id': roomData['Room_id'] ?? roomData['room_id'] ?? 0,
        'Room_name': roomData['Room_name'] ?? roomData['room_name'] ?? 'Unknown Room',
        'image_url': roomData['image_url'] ?? roomData['imageUrl'] ?? '',
        'price_per_day': roomData['price_per_day'] ?? roomData['price'] ?? 0,
        'status': finalStatus, // 👈 4. ใช้ค่า status ที่ตรวจสอบแล้ว
        'description': roomData['description'] ?? '',
      };
    }
    
    // Fallback
    return {
      'Room_id': 0,
      'Room_name': 'Unknown Room',
      'image_url': '',
      'price_per_day': 0,
      'status': 'Disabled', // 👈 ค่าเริ่มต้นควรเป็น Disabled
      'description': '',
    };
  }

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      final response = await http.get(Uri.parse('http://26.122.43.191:3000/staff/rooms'));
      print('📡 Response Status: ${response.statusCode}');
      print('📡 Raw Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print('📡 Parsed JSON: $data');
          
          if (data is List) {
            setState(() {
              rooms = List<Map<String, dynamic>>.from(data);
            });
            print('✅ Loaded ${rooms.length} rooms from List');
          } 
          else if (data is Map && data.containsKey('rooms')) {
            setState(() {
              rooms = List<Map<String, dynamic>>.from(data['rooms']);
            });
            print('✅ Loaded ${rooms.length} rooms from "rooms" key');
          }
          else if (data is Map && data.containsKey('data')) {
            setState(() {
              rooms = List<Map<String, dynamic>>.from(data['data']);
            });
            print('✅ Loaded ${rooms.length} rooms from "data" key');
          }
          else {
            print('⚠️ Unexpected response structure: $data');
            setState(() {
              rooms = [];
            });
          }
        } catch (e) {
          print('❌ JSON Parse Error: $e');
          throw Exception('Invalid JSON format: $e');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (error) {
      print('❌ Error fetching rooms: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Browse_Lecturer(
              userId: widget.userID,
              userRole: widget.userRole,
            ),
          ),
        );
        break;
      case 1: // Edit (หน้าปัจจุบัน)
        break;
      case 2: // Add
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddRoomPage(
              userID: widget.userID,
              userRole: widget.userRole,
            ),
          ),
        );
        break;
      case 3: // Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage_Staff(
              userID: widget.userID,
              userRole: widget.userRole,
            ),
          ),
        );
        break;
      case 4: // History
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryPage(
              userID: widget.userID,
              userRole: widget.userRole,
            ),
          ),
        );
        break;
  //       case 5: // User
  // Navigator.pushReplacement(
  //   context,
  //   MaterialPageRoute(
  //     builder: (context) => Profile(
  //       userId: widget.userID,
  //     ),
  //   ),
  // );
  // break;
    }
  }

  Widget _buildRoomImage(Map<String, dynamic> room) {
    final imageUrl = room["image_url"]?.toString() ?? "";
    final fullImageUrl = _getFullImageUrl(imageUrl);

    print('🖼️ Building image for room ${room['Room_id']}');
    print('🖼️ Image URL: $imageUrl');
    print('🖼️ Full Image URL: $fullImageUrl');

    if (imageUrl.isEmpty || imageUrl == 'null') {
      return Container(
        width: 100,
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFFEAEAEA),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported_outlined, color: Colors.black45, size: 30),
              SizedBox(height: 4),
              Text("No Image", style: TextStyle(fontSize: 10, color: Colors.black45)),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 100,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFEAEAEA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        child: Image.network(
          fullImageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[300],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('❌ Image load error: $error');
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 25),
                    SizedBox(height: 4),
                    Text("Load Failed", style: TextStyle(fontSize: 10, color: Colors.red)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredRooms = rooms
        .where((room) =>
            room["Room_name"]?.toString().toLowerCase().contains(searchText.toLowerCase()) ?? false)
        .toList();

    // Debug information
    print('=== ROOMS DEBUG INFO ===');
    print('Total rooms: ${rooms.length}');
    print('Filtered rooms: ${filteredRooms.length}');

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
          // Debug banner
          if (rooms.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange[100],
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[800]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'No rooms loaded. Check API response.',
                      
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.green[100],
              child: Text(
                'Loaded ${rooms.length} rooms',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
              ),
            ),

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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: rooms.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.meeting_room, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No rooms available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredRooms.length,
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      final rawRoom = filteredRooms[index];
                      final room = _parseRoomData(rawRoom);
                      final status = room["status"]?.toString() ?? "Unknown";
                      Color statusColor;

                      switch (status) {
                        case "Free":
                          statusColor = Colors.green;
                          break;
                        case "Disabled":
                          statusColor = Colors.red;
                          break;
                        default:
                          statusColor = Colors.grey;
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
                            // Room Image
                            _buildRoomImage(room),
                            
                            // Room Details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                                          "Status: ",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          status,
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
                            
                            // Edit Button
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  print('🔄 Navigating to edit room: ${room['Room_id']}');
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
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
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
  final TextEditingController _descriptionController = TextEditingController();
  String selectedStatus = "Free";
  bool _isLoading = false;

  // ⭐️ [เพิ่ม] ฟังก์ชันแปลง URL ใน EditRoomPage
  String _getFullImageUrl(String imageUrl) {
    if (imageUrl.isEmpty || imageUrl == 'null') return '';
    
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }
    
    const serverIp = '26.122.43.191:3000';
    String cleanUrl = imageUrl.replaceAll(' ', '');
    
    if (cleanUrl.startsWith('/')) {
      return 'http://$serverIp$cleanUrl';
    } else {
      return 'http://$serverIp/$cleanUrl';
    }
  }

  @override
  void initState() {
    super.initState();
    _roomNameController.text = widget.roomData["Room_name"]?.toString() ?? "";
    _priceController.text = widget.roomData["price_per_day"]?.toString() ?? "0";
    _descriptionController.text = widget.roomData["description"]?.toString() ?? "";
    
    final statusFromData = widget.roomData["status"]?.toString();
    if (statusFromData != null && ["Free","Disabled"].contains(statusFromData)) {
      selectedStatus = statusFromData;
    } else {
      selectedStatus = "Free";
    }
  }

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
        Uri.parse('http://26.122.43.191:3000/staff/edit_room'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "Room_id": widget.roomData["Room_id"],
          "Room_name": _roomNameController.text,
          "image_url": widget.roomData["image_url"] ?? "",
          "price_per_day": int.tryParse(_priceController.text) ?? 0,
          "status": selectedStatus,
          "description": _descriptionController.text,
        }),
      );
      

      print('📤 Update Response: ${response.statusCode}');
      print('📤 Update Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Room updated successfully')),
        );
        widget.onRoomUpdated();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (error) {
      print('❌ Error updating room: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteRoom() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Room"),
          content: const Text("Are you sure you want to delete this room? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.delete(
          Uri.parse('http://26.122.43.191:3000/staff/delete_room'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "Room_id": widget.roomData["Room_id"],
          }),
        );

        if (response.statusCode == 200) { // 👈 [ปัญหา]
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room deleted successfully')),
        );
        widget.onRoomUpdated();
        Navigator.pop(context);
      } else {
        // ❌ ถ้าเซิร์ฟเวอร์ตอบ 404, 500, หรือ 204 มันจะมาเข้า else นี้
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = widget.roomData["image_url"]?.toString() ?? '';
    final String fullImageUrl = _getFullImageUrl(imageUrl);

    print('🖼️ EditPage - Image URL: $imageUrl');
    print('🖼️ EditPage - Full Image URL: $fullImageUrl');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Room",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E63F3),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _isLoading ? null : _deleteRoom,
            tooltip: 'Delete Room',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    
                  ),
                  const SizedBox(height: 20),

                  // Room Pictures Section
                  const Text(
                    "Room Pictures",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: imageUrl.isNotEmpty && imageUrl != "null"
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              fullImageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ EditPage Image error: $error');
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.black54),
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
                                Icon(Icons.image_outlined, size: 40, color: Colors.black54),
                                SizedBox(height: 5),
                                Text(
                                  "No room picture",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Room Name
                  const Text(
                    "Room name *",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _roomNameController,
                    decoration: InputDecoration(
                      hintText: "Enter room name",
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF1E63F3)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price per day
                  const Text(
                    "Price per day *",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter price",
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF1E63F3)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Enter room description",
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF1E63F3)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Room Status
                  const Text(
                    "Room Status *",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF1E63F3)),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
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
                      onChanged: _isLoading ? null : (value) {
                        setState(() => selectedStatus = value!);
                        print('🔄 Status changed to: $value');
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _deleteRoom,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Delete Room",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateRoom,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E63F3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
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

            
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                     
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}