import 'package:flutter/material.dart';
import 'browse_room.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
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
    MaterialPageRoute(builder: (context) => const BrowseRoom()),
  );
}


  OutlineInputBorder _rounded([Color? color]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color ?? Colors.black26, width: 1),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // รูปมุมโค้ง
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/room.jpg', // เปลี่ยนเป็นพาธรูปของคุณ
                      height: 250,
                      width: 400,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // หัวเรื่อง
                  const Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2F2B85), // น้ำเงินเข้มแบบในภาพ
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please log in to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Username
                  TextFormField(
                    controller: _userCtrl,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter username' : null,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      labelText: 'Username',
                      labelStyle:
                          const TextStyle(color: Colors.black54, fontSize: 16),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                      border: _rounded(),
                      enabledBorder: _rounded(),
                      focusedBorder:
                          _rounded(const Color(0xFF4A78F6)), // โทนน้ำเงินปุ่ม
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Password
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter password' : null,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      labelText: 'Password',
                      labelStyle:
                          const TextStyle(color: Colors.black54, fontSize: 16),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                      border: _rounded(),
                      enabledBorder: _rounded(),
                      focusedBorder: _rounded(const Color(0xFF4A78F6)),
                    ),
                  ),

                  const SizedBox(height: 100),

                  // ปุ่ม login สีน้ำเงิน เต็มความกว้าง มุมโค้งใหญ่
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A78F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'login',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // แถวข้อความ Sign up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
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
      ),
    );
    }
}
