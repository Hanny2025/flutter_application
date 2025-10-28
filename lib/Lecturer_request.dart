import 'package:flutter/material.dart';
import 'Lecturer_Check.dart';
import 'BottomNav.dart';


class Lecturer_req extends StatefulWidget {
  const Lecturer_req({super.key});

  @override
  State<Lecturer_req> createState() => _Lecturer_reqState();
}

class _Lecturer_reqState extends State<Lecturer_req> {
  static const Color Background_head = Color.fromARGB(255, 0, 62, 195);

  final List<Map<String, dynamic>> requests = [
    {
      "roomName": "Family Deluxe Room",
      "image": "assets/images/room.jpg",
      "price": "1,250 bahts/day",
      "username": "Username 1",
      "time": "08:00 - 10:00",
      "date": "Apr 1, 2025",
    },
    {
      "roomName": "King Deluxe Room",
      "image": "assets/images/room.jpg",
      "price": "650 bahts/day",
      "username": "Username 2",
      "time": "15:00 - 17:00",
      "date": "Apr 1, 2025",
    },
    {
      "roomName": "Deluxe Twin Room",
      "image": "assets/images/room.jpg",
      "price": "800 bahts/day",
      "username": "Username 3",
      "time": "10:00 - 12:00",
      "date": "Apr 1, 2025",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Request customer',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Background_head,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckPage(requestData: request),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Room image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        request["image"]!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Room details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request["roomName"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            request["price"]!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                request["username"]!,
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                request["date"]!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            request["time"]!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    
                    // Arrow icon
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 0),
        child: AppBottomNavigationBar(currentIndex: 0),
      ),
    );
  }
}

// Add this class in a new file called check_page.dart
