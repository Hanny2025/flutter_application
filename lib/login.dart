import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <<< 1. เพิ่ม import นี้
import 'package:flutter_application/browse.dart';
import 'package:flutter_application/register.dart';

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

  // <<< 2. สร้าง RegExp สำหรับตรวจจับอักษรไทย (ก-ฮ, สระ, วรรณยุกต์, เลขไทย)
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
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _loading = false);

    // ✅ นำทางไปหน้า BrowseRoom
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Browse()),
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
                    'assets/imgs/room.jpg',
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
