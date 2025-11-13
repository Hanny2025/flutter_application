import 'package:flutter/material.dart';


// --------------------------------------------------------
// PAGE 1: Edit Room List Page
// --------------------------------------------------------
class EditRoomListPage extends StatefulWidget {
  const EditRoomListPage({super.key});


  @override
  State<EditRoomListPage> createState() => _EditRoomListPageState();
}


class _EditRoomListPageState extends State<EditRoomListPage> {
  final TextEditingController _searchController = TextEditingController();


  final List<Map<String, dynamic>> rooms = [
    {
      "roomName": "Room 111 Family Deluxe",
      "status": "Free",
      "image": ""
    },
    {
      "roomName": "Room 222 King Deluxe",
      "status": "Reserved",
      "image": ""
    },
    {
      "roomName": "Room 333 Deluxe Twin",
      "status": "Disabled",
      "image": ""
    },
  ];


  String searchText = "";


  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredRooms = rooms
        .where((room) =>
            room["roomName"].toLowerCase().contains(searchText.toLowerCase()))
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
                        child: room["image"] == ""
                            ? const Icon(Icons.image_not_supported_outlined,
                                color: Colors.black45, size: 40)
                            : ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                child: Image.network(
                                  room["image"],
                                  fit: BoxFit.cover,
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
                                room["roomName"],
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
                                    status,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),


                      // ✏️ ⭐ ปุ่ม Edit
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditRoomPage(),
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
  const EditRoomPage({super.key});


  @override
  State<EditRoomPage> createState() => _EditRoomPageState();
}


class _EditRoomPageState extends State<EditRoomPage> {
  String selectedStatus = "Free";


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


      body: SingleChildScrollView(
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
              onTap: () {},
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
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),


            const SizedBox(height: 16),


            // 📝 Description
            const Text(
              "Room Description",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            TextField(
              maxLines: 2,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E63F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 90, vertical: 14),
                ),
                child: const Text(
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
