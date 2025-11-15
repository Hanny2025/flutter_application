import 'package:flutter/material.dart';
import 'package:flutter_application/shared/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const Color primaryBlue = Color(0xFF1976D2);
const Color lightBlueBackground = Color(0xFFE8F6FF);
const Color darkGrey = Color(0xFF333333);

class Profile extends StatefulWidget {
  final String userId;

  const Profile({super.key, required this.userId});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse("http://172.27.9.232:3000/get_user?user_id=${widget.userId}"),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userData = data;
          isLoading = false;
          errorMessage = '';
        });
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? "Failed to load user data");
      }
    } catch (e) {
      print("Error fetching user: $e");
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

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
                Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: primaryBlue,
        centerTitle: true,
        title: const Text(
          'User',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Error: $errorMessage",
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: fetchUserData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : userData == null
          ? const Center(child: Text("No user data found"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UserProfileCard(
                    userId: userData!['User_id'].toString(),
                    username: userData!['username'],
                    position: userData!['role'],
                  ),
                  const SizedBox(height: 30),
                  LogoutTile(onTap: _handleLogout),
                ],
              ),
            ),
    );
  }
}

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID: $userId',
                style: const TextStyle(fontSize: 16, color: darkGrey),
              ),
              const SizedBox(height: 4),
              Text(
                'Username: $username',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkGrey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Position: $position',
                style: const TextStyle(fontSize: 16, color: darkGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LogoutTile extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
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
