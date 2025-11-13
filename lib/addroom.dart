import 'package:flutter/material.dart';


class AddRoomPage extends StatefulWidget {
  const AddRoomPage({super.key});


  @override
  State<AddRoomPage> createState() => _AddRoomPageState();
}


class _AddRoomPageState extends State<AddRoomPage> {
  String selectedStatus = "Free";


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


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟩 Add Room Button
Center(
  child: SizedBox(
    width: double.infinity, // ✅ ให้ปุ่มกว้างเต็มจอ
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
          vertical: 14, // ✅ ความสูงเท่าเดิม
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




            // 💾 Save Room Button
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
        currentIndex: 2, // “Add”
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
