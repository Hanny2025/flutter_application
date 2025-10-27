import 'package:flutter/material.dart';
import 'Lecturer_request.dart';
class Browse_Lecturer extends StatefulWidget {
  const Browse_Lecturer({super.key});

  @override
  State<Browse_Lecturer> createState() => _Browse_LecturerState();
}

class _Browse_LecturerState extends State<Browse_Lecturer> {
  static const Color Background_head = Color.fromARGB(255, 0, 62, 195);

  final List<Map<String, String>> rooms = [
    {
      "name": "Deluxe Twin Room",
      "image":"assets/images/login.jpg",
      "desc": "2 single beds • breakfast",
      "max": "Max 2 adults",
      "price": "900 bahts/day"
    },
    {
      "name": "King Deluxe Room",
      "image":"assets/images/login.jpg",
      "desc": "1 king bed • breakfast • air",
      "max": "Max 1 adult",
      "price": "650 bahts/day"
    },
    {
      "name": "Family Deluxe Room",
      "image":"assets/images/login.jpg",
      "desc": "1 queen bed • 1 single bed • breakfast",
      "max": "Max 3 adults",
      "price": "1,250 bahts/day"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Rooms',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Background_head,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: rooms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final room = rooms[index];
          return Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.asset(
                      room["image"]!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12)),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      room["name"]!,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                room["desc"]!,
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 8),

                      
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  _StatusRow(
                                      time: '08:00 - 10:00',
                                      label: 'Free',
                                      color: Colors.green,
                                      enabled: true),
                                  SizedBox(height: 6),
                                  _StatusRow(
                                      time: '10:00 - 12:00',
                                      label: 'Pending',
                                      color: Colors.orange,
                                      enabled: true),
                                  SizedBox(height: 6),
                                  _StatusRow(
                                      time: '13:00 - 15:00',
                                      label: 'Reserved',
                                      color: Colors.red,
                                      enabled: true),
                                  SizedBox(height: 6),
                                  _StatusRow(
                                      time: '15:00 - 17:00',
                                      label: 'Disabled',
                                      color: Colors.grey,
                                      enabled: false),
                                ],
                              ),
                            ],
                          ),
                        ),

                        
                       Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              room["price"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              room["max"]!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: 0,
      //   onTap: (index) {
      //   switch (index) {
      //       case 0:
      //         Navigator.pushReplacement(
      //           context,
      //           MaterialPageRoute(builder: (context) => const Browse_Lecturer()),
      //         );
      //         break;
      //       case 1:
      //         Navigator.pushReplacement(
      //           context,
      //           MaterialPageRoute(builder: (context) => const Lecturer_req()),
      //         );
      //         break;
      //       //case 2:
      //         Navigator.pushReplacement(
      //           context,
      //           //MaterialPageRoute(builder: (context) => const Check_Page()),
      //         );
      //         break;
      //      // case 3:
      //         Navigator.pushReplacement(
      //           context,
      //           //MaterialPageRoute(builder: (context) => const History_Page()),
      //         );
      //         break;
      //      // case 4:
      //         Navigator.pushReplacement(
      //           context,
      //           //MaterialPageRoute(builder: (context) => const User_Page()),
      //         );
      //         break;
      //   }
      //   },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_available), label: 'Requested'),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Check'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
        selectedItemColor: Background_head,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}


class _StatusRow extends StatelessWidget {
  final String time;
  final String label;
  final Color color;
  final bool enabled;
  const _StatusRow({
    required this.time,
    required this.label,
    required this.color,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = enabled ? Colors.black87 : Colors.black38;
    final chipColor = enabled ? color.withOpacity(0.12) : Colors.grey.withOpacity(0.08);
    final borderColor = enabled ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.2);
    final labelColor = enabled ? color : Colors.grey;

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            time,
            style: TextStyle(fontSize: 12, color: textColor),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: labelColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
