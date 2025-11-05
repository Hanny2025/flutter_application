import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <<< 1. เพิ่ม import นี้
import 'package:flutter_application/browse.dart';
import 'package:flutter_application/register.dart';
import 'package:http/http.dart' as http; // <<< 1. เพิ่มตัวนี้
import 'dart:convert'; // <<< 2. เพิ่มตัวนี้

const Color primaryBlue = Color(0xFF1976D2);

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final url = '10.2.21.252:3000';
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  // <<< 2. สร้าง RegExp สำหรับตรวจจับอักษรไทย (ก-ฮ, สระ, วรรณยุกต์, เลขไทย)
  final RegExp _thaiPattern = RegExp(r'[ก-๙]');

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // <<< 2. อัปเดตฟังก์ชัน _onLogin ทั้งหมด
  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      // 1. ดึงข้อมูลจาก text fields
      final username = _usernameController.text;
      final password = _passwordController.text;

      // 2. สร้าง URL และ Body สำหรับส่ง request
      // (สมมติว่า backend ของคุณมี endpoint /login)
      final fullUrl = 'http://10.2.21.252:3000/login';
      final body = jsonEncode({'username': username, 'password': password});

      // 3. ส่ง HTTP POST Request
      final response = await http
          .post(
            Uri.parse(fullUrl),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: body,
          )
          .timeout(const Duration(seconds: 10)); // <<< เพิ่ม timeout กันค้าง

      // 4. ตรวจสอบสถานะการเชื่อมต่อ (สำคัญมาก)
      if (!mounted) return;

      // 5. จัดการผลลัพธ์ (Response)
      if (response.statusCode == 200) {
        // ✅ Login สำเร็จ (Server ตอบ 200 OK)
        // คุณอาจจะได้รับ token กลับมา ให้บันทึกไว้ที่นี่
        // final data = json.decode(response.body);
        // final token = data['token'];
        // ... (โค้ดบันทึก token) ...

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Browse()),
        );
      } else {
        // ❌ Login ไม่สำเร็จ (เช่น 401: Unauthorized)
        // พยายามดึงข้อความ error จาก server
        String errorMessage = 'Invalid username or password';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Server ไม่ได้ส่ง JSON error กลับมา
        }

        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      // ❌ เกิด Error (เช่น Server ปิด, ไม่มีเน็ต, Timeout)
      if (!mounted) return;
      _showErrorSnackBar('Could not connect to server. Please try again.');
    } finally {
      // 6. หยุดการโหลดเสมอ ไม่ว่าจะสำเร็จหรือล้มเหลว
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // <<< 3. เพิ่มฟังก์ชันสำหรับแสดง SnackBar (Error)
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
                  // <<< 3. เพิ่ม Input Formatter เพื่อ "กัน" ไม่ให้พิมพ์ไทย
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
                  // <<< 3. อัปเดต Validator
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Enter password';
                    }
                    if (_thaiPattern.hasMatch(v)) {
                      return 'Password cannot contain Thai characters';
                    }
                    return null;
                  },
                  // <<< 3. เพิ่ม Input Formatter เพื่อ "กัน" ไม่ให้พิมพ์ไทย
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
                        // <<< 2. แก้ไขตรงนี้
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // สมมติว่าคลาสของคุณชื่อ Register()
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
