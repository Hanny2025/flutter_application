import 'package:flutter/material.dart';
import 'package:flutter_application/staff/dashboard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io'; 
import 'package:http_parser/http_parser.dart';

// ⭐️ [เพิ่ม] Imports สำหรับการนำทาง
import 'browse_room.dart';
import 'editroom.dart';
import 'history.dart';

class AddRoomPage extends StatefulWidget {
  final String userID;
  final String userRole;

  const AddRoomPage({
    super.key,
    required this.userID,
    required this.userRole,
  });

  @override
  State<AddRoomPage> createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String selectedStatus = "Free";
  bool _isLoading = false;
  
  // ⭐️ [เพิ่ม] ตัวแปรสำหรับเก็บรูปภาพ
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
  int _currentIndex = 2; // 2 คือ 'Add'
  Future<String?> _uploadImageToServer() async {
  if (_selectedImage == null) return null;

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://26.122.43.191:3000/staff/upload_image'), // สร้าง API สำหรับอัพโหลดภาพเฉพาะ
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'room_image',
        _selectedImage!.path,
      ),
    );

    var response = await request.send();
    
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      return jsonResponse['image_url'];
    } else {
      print('Image upload failed with status: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error uploading image: $e');
    return null;
  }
}

  // ⭐️ [เพิ่ม] ฟังก์ชันเลือกรูปภาพจาก Gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  
  Future<void> _takePhotoFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  // ⭐️ [เพิ่ม] ฟังก์ชันแสดง Dialog เลือกแหล่งที่มาของรูปภาพ
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose Image Source"),
          content: const Text("Select where to get the image from"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library),
                  SizedBox(width: 8),
                  Text("Gallery"),
                ],
              ),
            ),
            
          ],
        );
      },
    );
  }

  // ⭐️ [แก้ไข] ฟังก์ชันอัพโหลดรูปภาพไปยัง Server
  Future<void> _addRoom() async {
  if (_roomNameController.text.isEmpty || _priceController.text.isEmpty) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill room name and price')),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://26.122.43.191:3000/staff/add_room'),
    );

    // ⭐️ เพิ่มไฟล์ภาพด้วยการตรวจสอบประเภทที่ถูกต้อง
    if (_selectedImage != null) {
      final file = File(_selectedImage!.path);
      final bytes = await file.readAsBytes();
      
      // ตรวจสอบประเภทไฟล์จาก signature
      String contentType = _detectImageType(bytes);
      String extension = _selectedImage!.path.split('.').last.toLowerCase();
      
      print('🖼️ Detected: type=$contentType, extension=$extension');

      request.files.add(
        http.MultipartFile.fromBytes(
          'room_image',
          bytes,
          filename: 'room_image_${DateTime.now().millisecondsSinceEpoch}.$extension',
          contentType: MediaType('image', contentType.split('/').last),
        )
      );
    }

    // เพิ่มข้อมูลอื่นๆ
    request.fields.addAll({
      'Room_name': _roomNameController.text,
      'price_per_day': _priceController.text,
      'status': selectedStatus,
      'description': _descriptionController.text,
    });

    print('📤 Sending request...');
    
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    
    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: $responseData');

    // ⭐️ ตรวจสอบว่าเป็น HTML error หรือไม่
    if (responseData.trim().startsWith('<!DOCTYPE html>') || 
        responseData.trim().startsWith('<html>')) {
      // แยก error message จาก HTML
      final errorMatch = RegExp(r'Error: ([^<]+)').firstMatch(responseData);
      final errorMessage = errorMatch?.group(1)?.replaceAll('<br>', '\n') ?? 'Server error';
      throw Exception('Server Error: $errorMessage');
    }

    var result = json.decode(responseData);

    if (!mounted) return;

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );

     
      
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? result['error'] ?? 'Unknown error')),
      );
    }
  } on FormatException catch (e) {
    print('❌ JSON Format Error: $e');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Server returned invalid response')),
    );
  } catch (error) {
    print('❌ Error adding room: $error');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// ⭐️ ฟังก์ชันตรวจสอบประเภทภาพจาก bytes
String _detectImageType(List<int> bytes) {
  if (bytes.length < 8) return 'jpeg'; // default
  
  // JPEG
  if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return 'jpeg';
  
  // PNG
  if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return 'png';
  
  // GIF
  if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x38) return 'gif';
  
  // WEBP
  if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) return 'webp';
  
  // BMP
  if (bytes[0] == 0x42 && bytes[1] == 0x4D) return 'bmp';
  
  return 'jpeg'; // default
}

  // ⭐️ [เพิ่ม] ฟังก์ชันลบรูปภาพที่เลือก
  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
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
      case 1: // Edit
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EditRoomListPage(
              userID: widget.userID,
              userRole: widget.userRole,
            ),
          ),
        );
        break;
      case 2: // Add (หน้าปัจจุบัน)
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
      // case 5: // User
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => Profile(
      //         userId: widget.userID,
      //         userRole: widget.userRole,
      //       ),
      //     ),
      //   );
      //   break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Add Room",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E63F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E63F3)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // 🖼 Room Pictures - ⭐️ [แก้ไข] ส่วนแสดงรูปภาพ
                  const Text(
                    "Room Pictures",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // ⭐️ [แก้ไข] แสดงรูปภาพที่เลือก หรือปุ่มอัพโหลด
                  _selectedImage != null
                      ? Stack(
                          children: [
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.error, color: Colors.red),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 16,
                                child: IconButton(
                                  icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                  onPressed: _removeSelectedImage,
                                ),
                              ),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black54, width: 1),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[50],
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      size: 50, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text(
                                    "Tap to upload room picture",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "From Gallery",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
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
                      fillColor: const Color(0xFFF0F0F0),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
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
                      fillColor: const Color(0xFFF0F0F0),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
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

                  // 📝 Room Description
                  const Text(
                    "Room Description",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
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

                  // ⚙️ Room Status
                  const Text(
                    "Room Status",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 30),

                  // ⭐️ [เพิ่ม] ปุ่ม Add Room
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addRoom,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E63F3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                              "Add Room",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
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
}