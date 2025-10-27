import 'package:flutter/material.dart';

// --- Constants (กำหนดสีหลัก) ---
const Color primaryBlue = Color(0xFF1976D2);

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // ตัวควบคุม TextField
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // ฟังก์ชันจำลองการสมัครสมาชิก (Sign Up)
  void _onSubmit() {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage('กรุณากรอกข้อมูลให้ครบ');
      return;
    }
    if (password != confirm) {
      _showMessage('รหัสผ่านไม่ตรงกัน');
      return;
    }
    // เพิ่มการตรวจสอบความยาวรหัสผ่าน
    if (password.length < 6) {
      _showMessage('รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร');
      return;
    }

    // *** สมัครสมาชิกสำเร็จ (จำลอง) ***
    _showMessage('สมัครสมาชิกสำเร็จ! กรุณาเข้าสู่ระบบ');

    // *** นำทางกลับไปหน้า Login ***
    // ใช้ pop เพื่อปิดหน้า Register และกลับไปหน้าจอที่อยู่ข้างล่าง (ซึ่งคือหน้า Login)
    Navigator.pop(context);
  }

  void _showMessage(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const blue = primaryBlue;
    return Scaffold(
      // AppBar สำหรับหน้า Register (มีปุ่ม Back กลับไป Login)
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),

            // Image/Logo (ใช้ไอคอนแทนหากไม่พบไฟล์ asset)
            Center(
              child: Image.asset(
                'assets/my_image.png',
                width: 150,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.app_registration,
                  size: 120,
                  color: primaryBlue,
                ),
              ),
            ),

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
                  SizedBox(height: 8),
                  Text(
                    'Register below to start booking.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),

            // 1. Username
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: const Icon(Icons.person, color: blue),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Password
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock, color: blue),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Confirm Password
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_reset, color: blue),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 50),

            // ปุ่ม Register
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
            const SizedBox(height: 30),

            // กลับไป Login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                InkWell(
                  onTap: () {
                    // กลับไปหน้า Login ที่อยู่ข้างล่าง
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
    );
  }
}
