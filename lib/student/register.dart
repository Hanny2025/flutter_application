import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <<< 1. เพิ่ม import นี้ (สำหรับกันภาษาไทย)
import 'package:http/http.dart' as http;
import 'dart:convert';

// --- Constants (กำหนดสีหลัก) ---
const Color primaryBlue = Color(0xFF1976D2);

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // <<< 2. เพิ่ม FormKey (เหมือนหน้า Login)
  final _formKey = GlobalKey<FormState>();

  // ตัวควบคุม TextField
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // <<< 3. เพิ่ม state สำหรับซ่อน/แสดงรหัสผ่าน (เหมือนหน้า Login)
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // <<< 4. เพิ่ม RegExp สำหรับกันภาษาไทย (เหมือนหน้า Login)
  final RegExp _thaiPattern = RegExp(r'[ก-๙]');

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // ✅ ส่งข้อมูลไปที่ Express server
      final url = Uri.parse(
        'http://10.2.21.252:3000/register',
      ); // เปลี่ยน IP ถ้าใช้มือถือ
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      // ✅ ตรวจผลลัพธ์จาก backend
      if (response.statusCode == 201) {
        _showMessage('Registration successful! Please login.');
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        _showMessage('Error: ${data['message']}');
      }
    } catch (e) {
      _showMessage('Cannot connect to server: $e');
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  OutlineInputBorder _rounded([Color? color]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color ?? Colors.black26, width: 1),
  );

  @override
  Widget build(BuildContext context) {
    const blue = primaryBlue;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        // <<< 6. หุ้ม Column ด้วย Form
        child: Form(
          key: _formKey, // <<< 7. ใส่ Key ให้ Form
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.asset(
                  'assets/imgs/room.jpg',
                  height: 250,
                  width: 380,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Create New Account',
                      style: TextStyle(
                        color: blue,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Register below to start booking.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 1. Username
              // <<< 8. เปลี่ยน TextField เป็น TextFormField
              TextFormField(
                controller: _usernameController,
                style: const TextStyle(fontSize: 16),
                // <<< 9. เพิ่ม Validator (เหมือนหน้า Login)
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please fill in all fields';
                  }
                  if (_thaiPattern.hasMatch(v)) {
                    return 'Username must be in English only';
                  }
                  return null;
                },
                // <<< 10. เพิ่ม Input Formatter (เหมือนหน้า Login)
                inputFormatters: [
                  FilteringTextInputFormatter.deny(_thaiPattern),
                ],
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person, color: blue),
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
              const SizedBox(height: 10),

              // 2. Password
              // <<< 8. เปลี่ยน TextField เป็น TextFormField
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePass, // <<< 11. ใช้ state ที่สร้างใหม่
                style: const TextStyle(fontSize: 16),
                // <<< 9. เพิ่ม Validator (ย้าย Logic มาจาก _onSubmit)
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please fill in all fields';
                  }
                  if (_thaiPattern.hasMatch(v)) {
                    return 'Password must be in English only';
                  }
                  // (เปลี่ยนจาก <= 3 เป็น < 4 เพื่อให้ 4 ตัวผ่าน)
                  if (v.length < 4) {
                    return 'Password must be at least 4 characters long';
                  }
                  return null;
                },
                // <<< 10. เพิ่ม Input Formatter
                inputFormatters: [
                  FilteringTextInputFormatter.deny(_thaiPattern),
                ],
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock, color: blue),
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
              const SizedBox(height: 10),

              // 3. Confirm Password
              // <<< 8. เปลี่ยน TextField เป็น TextFormField
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm, // <<< 11. ใช้ state ที่สร้างใหม่
                style: const TextStyle(fontSize: 16),
                // <<< 9. เพิ่ม Validator (ย้าย Logic มาจาก _onSubmit)
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please fill in all fields';
                  }
                  if (v != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                // <<< 10. เพิ่ม Input Formatter
                inputFormatters: [
                  FilteringTextInputFormatter.deny(_thaiPattern),
                ],
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_reset, color: blue),
                  // <<< 12. เพิ่มปุ่มซ่อน/แสดง (เหมือนหน้า Login)
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: Colors.blueAccent,
                    ),
                  ),
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
              const SizedBox(height: 30),

              // ปุ่ม Register
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onSubmit, // <<< 13. _onSubmit ถูกแก้ไขแล้ว
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'REGISTER',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // กลับไป Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
