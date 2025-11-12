import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'Lecturer_Browse.dart'; // (ไม่จำเป็นต้อง import ถ้าใช้ named route)
import 'Lecturer_DashBoard.dart'; // (ไม่จำเป็นต้อง import ถ้าใช้ named route)

import 'dart:convert';
import 'package:http/http.dart' as http;

const Color primaryBlue = Color(0xFF1976D2);

class LoginLecturer extends StatefulWidget {
  const LoginLecturer({super.key});

  @override
  State<LoginLecturer> createState() => _LoginLecturerState();
}

class _LoginLecturerState extends State<LoginLecturer> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  final RegExp _thaiPattern = RegExp(r'[ก-๙]');

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final username = _usernameController.text;
      final password = _passwordController.text;

      final fullUrl = 'http://10.2.21.252:3000/login';
      final body = jsonEncode({'username': username, 'password': password});

      final response = await http
          .post(
            Uri.parse(fullUrl),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      // ✅ ตรวจสอบ response อย่างถูกต้อง
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Login successful: $data');

        // ✅ ตรวจสอบว่ามี user object และ User_id
        if (data['user'] != null && data['user']['User_id'] != null) {
          // --- 🌟 (1) ดึงข้อมูลผู้ใช้ ---
          // ⚠️ (สำคัญ) ดึง ID เป็น int เพราะ UserPage คาดหวัง int
          final int userId = data['user']['User_id'];
          final String username = data['user']['username'] ?? 'No Username';
          final String userRole =
              data['user']['role']?.toString() ?? 'Lecturer';

          // --- 🌟 (2) บันทึกข้อมูลลง SharedPreferences ---
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', userId);
          await prefs.setString('username', username);
          await prefs.setString('role', userRole);

          print('✅ User ID $userId ($username) SAVED. Navigating to Home...');

          if (!mounted) return; // 🌟 (เพิ่ม) ตรวจสอบ mounted ก่อนนำทาง

          // --- 🌟 (3) นำทางไปหน้าแรก (Home/Dashboard) ---
          // (ใช้ named route '/' เพื่อให้ BottomNav ทำงานถูกต้อง)
          Navigator.pushReplacementNamed(context, '/');
        } else {
          print(' User data missing in response');
          _showErrorSnackBar('Login successful but user data is missing');
        }
      } else {
        String errorMessage = 'Invalid username or password';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {}

        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      print(' Login error: $e');
      _showErrorSnackBar('Could not connect to server. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  OutlineInputBorder _rounded([Color? color]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color ?? Colors.black26, width: 1),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.asset(
                    'Assets/images/room.jpg',
                    height: 250,
                    width: 380,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a237e),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please login to continue',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Username
                TextFormField(
                  controller: _usernameController,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter username' : null,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline),
                    labelText: 'Username',
                    labelStyle: const TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 14,
                    ),
                    border: _rounded(),
                    enabledBorder: _rounded(),
                    focusedBorder: _rounded(
                      const Color(0xFF4A78F6),
                    ), // โทนน้ำเงินปุ่ม
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter password' : null,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    labelText: 'Password',
                    labelStyle: const TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 14,
                    ),
                    border: _rounded(),
                    enabledBorder: _rounded(),
                    focusedBorder: _rounded(const Color(0xFF4A78F6)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 10), // 👈 เพิ่มระยะห่างเล็กน้อย
                    GestureDetector(
                      onTap: () {
                        // TODO: ไปหน้า Sign up
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Color(0xFF4A78F6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
