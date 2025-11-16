import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/shared/browse.dart';
import 'package:flutter_application/student/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application/lecturer/Lecturer_Browse.dart';

const Color primaryBlue = Color(0xFF1976D2);

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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

      final fullUrl = 'http://192.168.1.111:3000/login';
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
          final userId = data['user']['User_id'].toString();
          final username = data['user']['username'];
          final userRole =
              data['user']['role']?.toString() ?? 'Users'; // ✅ ดึง role

          // บันทึกข้อมูลลง SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_name', username);
          // (แนะนำ) บันทึก user_id (String) ไว้ด้วยเลยก็ได้ครับ
          await prefs.setString('user_id', userId);
          // 🔺 --- END: ส่วนที่ต้องเพิ่ม ---

          print(
            ' Navigating to Browse with userId: $userId, username: $username, role: $userRole',
          );

          // 2. ตรวจสอบค่า userRole
          if (userRole.toLowerCase() == 'lecturer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Browse_Lecturer(userId: userId, userRole: userRole),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Browse(userId: userId, userRole: userRole),
              ),
            );
          }
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
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/imgs/room.jpg',
                    height: 250,
                    width: 400,
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
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter username';
                    }
                    if (_thaiPattern.hasMatch(v)) {
                      return 'Username must be in English only';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(_thaiPattern),
                  ],
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.blueAccent,
                    ),
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
                    focusedBorder: _rounded(const Color(0xFF4A78F6)),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Enter password';
                    }
                    if (_thaiPattern.hasMatch(v)) {
                      return 'Password cannot contain Thai characters';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(_thaiPattern),
                  ],
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.blueAccent,
                    ),
                    labelText: 'Password',
                    labelStyle: const TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.blueAccent,
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

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'LOGIN',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Register(),
                          ),
                        );
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
