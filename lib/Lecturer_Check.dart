import 'package:flutter/material.dart';
import 'BottomNav.dart';

class CheckPage extends StatelessWidget {
  final Map<String, dynamic>? requestData;
  const CheckPage({super.key, this.requestData});

  // sample data shown when requestData is null (from Dashboard /check)
  static final List<Map<String, String>> _sampleRequests = [
    {
      "roomName": "Family Deluxe Room",
      "image": "assets/images/room.jpg",
      "price": "1,250 bahts/day",
      "username": "Username 1",
      "date": "Apr 1, 2025",
      "time": "08:00 - 10:00",
    },
    {
      "roomName": "King Deluxe Room",
      "image": "assets/images/room.jpg",
      "price": "650 bahts/day",
      "username": "Username 2",
      "date": "Apr 1, 2025",
      "time": "15:00 - 17:00",
    },
    {
      "roomName": "Deluxe Twin Room",
      "image": "assets/images/room.jpg",
      "price": "800 bahts/day",
      "username": "Username 3",
      "date": "Apr 1, 2025",
      "time": "10:00 - 12:00",
    },
  ];

  void _sendToHistory(BuildContext context, Map<String, dynamic> entry) {
    final historyEntry = {
      ...entry,
      'actionAt': DateTime.now().toIso8601String(),
    };
    Navigator.pushReplacementNamed(
      context,
      '/history',
      arguments: historyEntry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = requestData;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Check status',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 62, 195),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: data == null
            ? ListView.separated(
                itemCount: _sampleRequests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _sampleRequests[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  item['image']!,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['roomName']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['price']!,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    item['date']!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['username']!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['time']!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _sendToHistory(context, {
                                    ...item,
                                    'status': 'approved',
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent.shade200,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('Approve'),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  _sendToHistory(context, {
                                    ...item,
                                    'status': 'rejected',
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent.shade200,
                                  foregroundColor: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('rejected'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        data["image"] ?? 'assets/images/login.jpg',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data["roomName"] ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data["price"] ?? '',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Text("Reserved by: ${data["username"] ?? ''}"),
                    Text("Date: ${data["date"] ?? ''}"),
                    Text("Time: ${data["time"] ?? ''}"),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _sendToHistory(context, {
                              ...data,
                              'status': 'approved',
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Approve'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _sendToHistory(context, {
                              ...data,
                              'status': 'rejected',
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Reject'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    );
  }
}
