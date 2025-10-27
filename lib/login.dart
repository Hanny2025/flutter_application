import 'package:flutter/material.dart';

const Color primaryBlue = Color(0xFF1976D2);

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // ตัวควบคุม TextField
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ฟังก์ชันจำลองการล็อกอิน / สมัคร
  void _onSubmit() {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showMessage('กรุณากรอกข้อมูลให้ครบ');
      return;
    }

    // *** 1. ตรวจสอบข้อมูลจำลอง ***
    // ในแอปจริง ต้องตรวจสอบกับ API หรือฐานข้อมูล
    if (username == 'student' && password == '1234') {
      _showMessage('เข้าสู่ระบบสำเร็จ! ยินดีต้อนรับ $username');

      // *** 2. นำทางไปหน้า Home และล้าง Stack ***
      // ต้องกำหนด '/home' ใน routes ของ MaterialApp ก่อน
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home', // นำทางไปหน้าหลัก (Home/Rooms)
        (Route<dynamic> route) => false, // ล้างหน้า Login ออกจาก Stack ทั้งหมด
      );
    } else {
      _showMessage('Username หรือ Password ไม่ถูกต้อง');
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const blue = Colors.blue;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            Center(
              // ใช้ Center เพื่อจัดให้รูปภาพอยู่ตรงกลาง
              child: Image.asset(
                'assets/my_image.png',
                width: 1, // ปรับขนาดให้พอดีขึ้น
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Column(
                // ใช้ Column เพื่อจัดเรียงข้อความหลักและข้อความย่อยให้อยู่ด้วยกัน
                mainAxisSize:
                    MainAxisSize.min, // ทำให้ Column กินพื้นที่เท่าที่จำเป็น
                children: const [
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: blue,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please login to your account',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Username
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: const Icon(Icons.person, color: blue),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: blue, width: 2),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: blue),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Password
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock, color: blue),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: blue, width: 2),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: blue),
                ),
              ),
            ),
            const SizedBox(height: 100),

            // ปุ่ม Login
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onSubmit,
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
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      color: Colors.blue,
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
