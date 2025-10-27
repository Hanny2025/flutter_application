import 'package:flutter/material.dart';
class CheckPage extends StatelessWidget {
  final Map<String, dynamic> requestData;
  
  const CheckPage({super.key, required this.requestData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Request'),
        backgroundColor: Color.fromARGB(255, 0, 62, 195),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              requestData["image"]!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(
              requestData["roomName"]!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              requestData["price"]!,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text("Reserved by: ${requestData["username"]!}"),
            Text("Date: ${requestData["date"]!}"),
            Text("Time: ${requestData["time"]!}"),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle approve
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Approve'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle reject
                    Navigator.pop(context);
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
    );
  }
}