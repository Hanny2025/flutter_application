import 'package:flutter/material.dart';
import 'package:flutter_application/shared/login.dart';

import 'Lecturer_Check.dart';
import 'Lecturer_History.dart'; // 👈 Import ไฟล์นี้
import 'Lecturer_request.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// ----------------------------------------
// ## 🎨 Theme Constants
// ----------------------------------------
const Color primaryBlue = Color(0xFF1976D2);
const Color lightPageBg = Color(0xFFE7F7FF);
const Color lightCardBg = Color(0xFFE0F7FF);

const Color lightBlueBackground = Color(0xFFE8F6FF);
const Color darkGrey = Color(0xFF333333);

// ----------------------------------------
// ## 📊 Model
// (สำหรับแสดงข้อมูลห้องในหน้า Browse)
// ----------------------------------------
class Room {
 final String imagePath;
 final String title;
 final String subtitle;
 final String maxText;
 final String price;
 final List<({String time, String status, Color color})> slots;

 Room({
  required this.imagePath,
  required this.title,
  required this.subtitle,
  required this.maxText,
  required this.price,
  required this.slots,
 });
}

// ----------------------------------------
// ## 🏠 Browse_Lecturer (Main Screen)
// (หน้าจอหลักที่มี Bottom Navigation Bar)
// ----------------------------------------
class Browse_Lecturer extends StatefulWidget {
 final String userId;
 final String userRole;
 const Browse_Lecturer({
  super.key,
  required this.userId,
  required this.userRole,
 });

 @override
 State<Browse_Lecturer> createState() => _Browse_LecturerState();
}

class _Browse_LecturerState extends State<Browse_Lecturer> {
 // --- State Variables ---
 int _selectedIndex = 0;
 late Future<List<Room>> _roomsFuture;
 final String serverIp = '192.168.1.111'; // 📍 **ใส่ IP ของคุณ**

 // 📍 **GlobalKey สำหรับ Profile** เพื่อเรียกฟังก์ชัน `fetchUserData()`

 final GlobalKey<_ProfileState> _profileKey = GlobalKey<_ProfileState>();

 // List ของ Title สำหรับ AppBar
 final List<String> _pageTitles = [
  'Rooms', // Index 0
  'Request', // Index 1
  'Check', // Index 2
  'History', // Index 3
  'User', // Index 4
 ];

 @override
 void initState() {
  super.initState();
  _roomsFuture = fetchRooms();
 }

 void _refreshRooms() {
  setState(() {
   _roomsFuture = fetchRooms();
  });
 }

 // 📍 **ฟังก์ชันรวมสำหรับปุ่ม Refresh** ในทุกหน้า
 void _handleRefresh() {
  setState(() {
   switch (_selectedIndex) {
    case 0: // Rooms
     _refreshRooms();
     break;
    case 1: // Request
     // TODO: Refresh Logic
     debugPrint('Refreshing Request page (Index 1)...');
     break;
    case 2: // Check
     // TODO: Refresh Logic
     debugPrint('Refreshing Check page (Index 2)...');
     break;
    case 3: // History
     // TODO: Refresh Logic
     debugPrint('Refreshing History page (Index 3)...');
     break;
    case 4: // User (Profile)
     // 🚀 เรียกใช้ฟังก์ชัน fetchUserData ผ่าน GlobalKey
     _profileKey.currentState?.fetchUserData();
     debugPrint('Refreshing Profile page (Index 4)...');
     break;
   }
  });
 }

 // --- Utility Methods ---
 Color _mapStatusToColor(String? status) {
  switch (status?.toLowerCase()) {
   case 'free':
    return Colors.green;
   case 'reserved':
    return Colors.red;
   case 'disabled':
    return Colors.black;
   case 'pending':
    return Colors.orange;
   case 'not available':
    return Colors.grey;
   default:
    return Colors.grey[400]!;
  }
 }

 // --- API Call ---
 Future<List<Room>> fetchRooms() async {
  final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final url = Uri.parse(
   'http://$serverIp:3000/rooms-with-status?date=$today',
  );

  try {
   final response = await http.get(url).timeout(const Duration(seconds: 10));
   debugPrint('GET rooms -> url:$url status:${response.statusCode}');

   if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data.map((roomData) {
     final List<dynamic> slotsData = roomData['slots'] ?? [];
     final List<({String time, String status, Color color})> slots =
       slotsData.map((slot) {
        String status = slot['Slot_status'] as String? ?? 'Disabled';
        return (
         time: slot['Slot_label'] as String? ?? 'N/A',
         status: status,
         color: _mapStatusToColor(status),
        );
       }).toList();

     return Room(
      title: roomData['Room_name'] ?? 'No Name',
      slots: slots,
      imagePath: 'assets/imgs/room.jpg',
      subtitle: '',
      maxText: '',
      price: '',
     );
    }).toList();
   } else {
    throw Exception(
     'Failed to load rooms (Status: ${response.statusCode})',
    );
   }
  } catch (e) {
   throw Exception('Failed to fetch rooms: $e');
  }
 }

 @override
 Widget build(BuildContext context) {
  // 1. สร้างหน้า List ห้อง
  final Widget roomListPage = FutureBuilder<List<Room>>(
   future: _roomsFuture,
   builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
     return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
     return Center(
      child: Padding(
       padding: const EdgeInsets.all(20.0),
       child: Text(
        'Error loading rooms:\n${snapshot.error}',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.red),
       ),
      ),
     );
    }
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
     return const Center(child: Text('No rooms found.'));
    }
    final List<Room> rooms = snapshot.data!;
    return ListView.builder(
     padding: const EdgeInsets.all(12),
     itemCount: rooms.length,
     itemBuilder: (context, i) => _roomCard(rooms[i], lightCardBg),
    );
   },
  );

  // 2. List ของหน้าจอทั้งหมด
  final List<Widget> pages = [
   roomListPage, // Index 0 (Rooms)
   Lecturer_req(userId: widget.userId), // Index 1 (Request)
   CheckPage(userId: widget.userId), // Index 2 (Check)
   
   // 🔽🔽🔽 [แก้ไข] เปลี่ยน 'HistoryPage' เป็น 'LecturerHistory' 🔽🔽🔽
   LecturerHistory(userId: widget.userId), // Index 3 (History)
   // 🔼🔼🔼 -------------------------------------------------- 🔼🔼🔼

   // 🔑 ส่ง key ไปยัง Profile เพื่อให้ GlobalKey ใช้งานได้
   Profile(userId: widget.userId, key: _profileKey), // Index 4 (User)
  ];

  return Scaffold(
   backgroundColor: lightPageBg,
   appBar: AppBar(
    backgroundColor: Colors.blue.shade800,

    leading: IconButton(
     icon: const Icon(Icons.dashboard, color: Colors.white),
     onPressed: () {
      // 🔄 Navigates back or to the main dashboard
      Navigator.pushReplacementNamed(
       context,
       '/Lecturer_Browse',
       arguments: {'userId': widget.userId, 'userRole': widget.userRole},
      );
      },
     tooltip: 'Dashboard / Back',
    ),
    // 💬 Title จะเปลี่ยนตาม Tab ที่เลือก
    title: Text(
     _pageTitles[_selectedIndex],
     style: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
     ),
    ),
    centerTitle: true,
    automaticallyImplyLeading: false,
    actions: [
     // 🔄 ปุ่ม Refresh สำหรับทุกหน้า
     IconButton(
      icon: const Icon(Icons.refresh, color: Colors.white),
      onPressed: _handleRefresh,
      tooltip: 'Refresh',
     ),
    ],
   ),

   // 💻 body จะแสดงหน้าจอที่เลือกจาก Bottom Nav Bar
   body: pages[_selectedIndex],

   // 🧭 BottomNavigationBar
   bottomNavigationBar: BottomNavigationBar(
    items: const <BottomNavigationBarItem>[
     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
     BottomNavigationBarItem(
      icon: Icon(Icons.description),
      label: 'Request',
     ),
     BottomNavigationBarItem(
      icon: Icon(Icons.check_circle_outline),
      label: 'Check',
     ),
     BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
     BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
    ],
    currentIndex: _selectedIndex,
    selectedItemColor: primaryBlue,
    unselectedItemColor: Colors.grey,
    type: BottomNavigationBarType.fixed,
    onTap: (index) => setState(() => _selectedIndex = index),
    showUnselectedLabels: true,
   ),
  );
 }

 // --- 🖼️ Widgets ย่อยของ Browse (Room Card) ---
 Widget _roomCard(Room r, Color lightCardBg) {
  return Card(
   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
   margin: const EdgeInsets.symmetric(vertical: 10),
   elevation: 3,
   child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () {
     // TODO: Add navigation to Room Details page
    },
    child: Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
      ClipRRect(
       borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
      	  topRight: Radius.circular(12),
       ),
       child: Image.asset(
        r.imagePath,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
         height: 150,
         color: Colors.grey[300],
         child: Icon(
          Icons.business,
          color: Colors.grey[600],
          size: 50,
         ),
        ),
       ),
      ),
      Container(
       color: lightCardBg,
       padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Expanded(
            child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
              Text(
              	r.title,
               style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
               ),
            	   ),
              const SizedBox(height: 4),
              Text(
              	r.subtitle,
               style: const TextStyle(fontSize: 13),
             	),
             ],
            ),
           ),
           Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
             Text(r.maxText, style: const TextStyle(fontSize: 13)),
             const SizedBox(height: 2),
             Text(
              r.price,
              style: const TextStyle(
            	   fontWeight: FontWeight.bold,
               fontSize: 13,
           	   ),
             ),
            ],
           ),
      	    ],
         ),
         const SizedBox(height: 12),
         // แสดง Time Slots
         for (final s in r.slots)
          _buildTimeSlot(s.time, s.status, s.color),
        ],
       ),
     	),
     ],
    ),
   ),
  );
 }

 Widget _buildTimeSlot(String time, String status, Color statusColor) {
  return Padding(
   padding: const EdgeInsets.symmetric(vertical: 2.0),
   child: Row(
    children: [
     SizedBox(
      width: 90,
      child: Text(time, style: const TextStyle(fontSize: 12)),
    	),
     const SizedBox(width: 8),
     Text(
 	     status,
      style: TextStyle(
       fontSize: 12,
       fontWeight: FontWeight.w600,
       color: statusColor,
     	),
     ),
    ],
   ),
  );
 }
}

// ===================================================================
// ## 👤 Profile Screen (มาจาก Profile.dart)
// =M=================================================================

class Profile extends StatefulWidget {
 final String userId;

 const Profile({super.key, required this.userId});

 @override
 // 🔑 Key Point: ต้องเป็น `_ProfileState` เพื่อให้ GlobalKey เข้าถึงได้
 State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
 Map<String, dynamic>? userData;
 bool isLoading = true;
 String errorMessage = '';
 final String serverIp = '192.168.1.111';

 @override
 void initState() {
  super.initState();
  fetchUserData();
 }

 // 🔑 **Method สำคัญ**: ต้องเป็น public (`Future<void>`) เพื่อให้ GlobalKey เรียกใช้ได้
 Future<void> fetchUserData() async {
  // 🔄 ตั้งค่า isLoading ตอนเริ่ม fetch
  setState(() {
   isLoading = true;
   errorMessage = '';
  });

  try {
   final response = await http.get(
    Uri.parse("http://$serverIp:3000/get_user?user_id=${widget.userId}"),
   );

   debugPrint("Response status: ${response.statusCode}");
   debugPrint("Response body: ${response.body}");

   if (response.statusCode == 200) {
    final data = json.decode(response.body);
    setState(() {
     userData = data;
     isLoading = false;
    });
   } else {
    final errorData = json.decode(response.body);
    throw Exception(errorData['message'] ?? "Failed to load user data");
  	}
  } catch (e) {
   debugPrint("Error fetching user: $e");
   setState(() {
    isLoading = false;
    errorMessage = e.toString();
   });
  }
 }

 // --- Logout Logic ---
 void _handleLogout() {
  _showLogoutDialog(context);
 }

 void _showLogoutDialog(BuildContext context) {
  showDialog(
   context: context,
   builder: (BuildContext context) {
    return AlertDialog(
     shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
     ),
     title: const Text(
      'Confirm Logout',
      style: TextStyle(fontWeight: FontWeight.bold),
 	   ),
     content: const Text('Are you sure you want to log out?'),
     actions: [
      TextButton(
       onPressed: () => Navigator.pop(context),
       child: const Text('Cancel'),
     	),
      ElevatedButton(
       onPressed: () {
        Navigator.pop(context); // ปิด Dialog
        // 🚪 ไปหน้า Login และลบทุกหน้าจอใน Stack
        Navigator.pushAndRemoveUntil(
         context,
        	MaterialPageRoute(builder: (context) => const Login()),
         (route) => false,
        );
       },
       style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
       child: const Text(
  	      'Log Out',
        style: TextStyle(color: Colors.white),
       ),
      ),
     ],
    );
  	},
  );
 }

 @override
 Widget build(BuildContext context) {
  if (isLoading) {
   return const Center(child: CircularProgressIndicator());
  }

  if (errorMessage.isNotEmpty) {
   return Center(
    child: Column(
     mainAxisAlignment: MainAxisAlignment.center,
     children: [
      Text(
       "Error: $errorMessage",
     	  style: const TextStyle(color: Colors.red),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
      	onPressed: fetchUserData, // 👈 Retry
       child: const Text('Retry'),
 	     ),
     ],
    ),
  	);
  }

  if (userData == null) {
   return const Center(child: Text("No user data found"));
  }

  return SingleChildScrollView(
   padding: const EdgeInsets.all(16.0),
   child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
     // 💳 แสดงข้อมูลโปรไฟล์
     UserProfileCard(
     	userId: userData!['User_id'].toString(),
     	username: userData!['username'],
      	position: userData!['role'],
     ),
     const SizedBox(height: 30),
     // 🚪 ปุ่ม Log Out
     LogoutTile(onTap: _handleLogout),
 	   ],
   ),
  );
 }
}

// ----------------------------------------
// ## 💳 UserProfileCard Widget
// ----------------------------------------
class UserProfileCard extends StatelessWidget {
 final String userId;
 final String username;
 final String position;

 const UserProfileCard({
  super.key,
  required this.userId,
  required this.username,
 	required this.position,
 });

 @override
 Widget build(BuildContext context) {
  return Container(
   padding: const EdgeInsets.all(24.0),
   decoration: BoxDecoration(
    color: lightBlueBackground,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
     BoxShadow(
     	color: Colors.grey.withOpacity(0.2),
      spreadRadius: 2,
      blurRadius: 5,
      offset: const Offset(0, 3),
     ),
  	  ],
  	),
   child: Row(
 	   crossAxisAlignment: CrossAxisAlignment.start,
    children: [
     const Icon(Icons.person_pin, size: 60, color: primaryBlue),
   	  const SizedBox(width: 20),
     // 📝 ใช้ Expanded เพื่อกันข้อความล้น
     Expanded(
      child: Column(
      	crossAxisAlignment: CrossAxisAlignment.start,
       children: [
        Text(
         'ID: $userId',
         style: const TextStyle(fontSize: 16, color: darkGrey),
        	overflow: TextOverflow.ellipsis,
      	  ),
 	       const SizedBox(height: 4),
        Text(
         'Username: $username',
         style: const TextStyle(
   	       fontSize: 16,
          fontWeight: FontWeight.bold,
        	  color: darkGrey,
 	       ),
      	   overflow: TextOverflow.ellipsis,
      	  ),
      	  const SizedBox(height: 4),
       	Text(
     	    'Position: $position',
      	   style: const TextStyle(fontSize: 16, color: darkGrey),
      	   overflow: TextOverflow.ellipsis,
    	    ),
     	  ],
      ),
     ),
   	],
   ),
  );
 }
}

// ----------------------------------------
// ## 🚪 LogoutTile Widget
// ----------------------------------------
class LogoutTile extends StatelessWidget {
 final VoidCallback onTap;

 const LogoutTile({super.key, required this.onTap});

 @override
 Widget build(BuildContext context) {
  return InkWell(
   onTap: onTap,
   borderRadius: BorderRadius.circular(8),
   child: Container(
    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
    decoration: BoxDecoration(
     color: Colors.white,
     borderRadius: BorderRadius.circular(8),
  	   border: Border.all(color: Colors.red.shade100, width: 1),
   	),
    child: Row(
  	   mainAxisAlignment: MainAxisAlignment.spaceBetween,
     children: [
      Row(
      	children: const [
       	Icon(Icons.logout, color: Colors.red, size: 28),
       	SizedBox(width: 15),
       	Text(
     	    'Log Out',
   	      style: TextStyle(
  	        fontSize: 18,
    	      color: Colors.red,
 	         fontWeight: FontWeight.w500,
     	  	 ),
  	     	),
     	 	],
     	),
      const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 20),
  	   ],
   	),
   ),
  );
 }
}