import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddRoomPage extends StatefulWidget {
  const AddRoomPage({super.key});

  @override
  State<AddRoomPage> createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String selectedStatus = "Free";
  bool _isLoading = false;

  // API: เพิ่มห้องใหม่
  Future<void> _addRoom() async {
    if (_roomNameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill room name and price')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://26.122.43.191:3000/staff/add_room'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "Room_name": _roomNameController.text,
          "image_url": "", // สามารถเพิ่มฟังก์ชันอัพโหลดรูปได้ภายหลัง
          "price_per_day": int.tryParse(_priceController.text) ?? 0,
          "status": selectedStatus,
        }),
      );

      if (response.statusCode == 201) {
        final result = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        
        // เคลียร์ฟอร์มหลังจากเพิ่มสำเร็จ
        _roomNameController.clear();
        _priceController.clear();
        _descriptionController.clear();
        setState(() {
          selectedStatus = "Free";
        });

        // แสดงผลลัพธ์
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Success"),
            content: Text("Room added successfully with ID: ${result['room_id']}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );

      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['message'])),
        );
      }
    } catch (error) {
      print('Error adding room: $error');
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
          "Add rooms",
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
                  // 🟩 Add Room Button
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, color: Colors.black),
                        label: const Text(
                          "Add Room",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
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
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined, size: 40, color: Colors.black54),
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 📝 Room Description
                  const Text(
                    "Room Description",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ⚙️ Room Status
                  const Text(
                    "Room Status",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        )
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(border: InputBorder.none),
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
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 💾 Save Room Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addRoom,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E63F3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 90, vertical: 14),
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
                              "Save Room",
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

      // ⚙️ Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E63F3),
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
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