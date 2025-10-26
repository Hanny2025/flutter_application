import 'package:flutter/material.dart';

class BakingApp extends StatelessWidget {
  const BakingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscure = true;

  static const bg = Color(0xFF1A1A1A);
  static const accent = Color(0xFFFFB74D);        // สีส้ม
  static const underline = Color(0xFF5C5C5C);     // สีเส้นใต้

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // รูปด้านบน
            SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: const [
                  Image(
                    image: AssetImage('assets/images/baking.jpg'),
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC1A1A1A)],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // เนื้อหา
            Expanded(
              child: Container(
                color: bg,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // หัวข้อ
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'SIGN IN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'SIGN UP',
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(color: Color(0xFF2B2B2B), height: 1),

                            const SizedBox(height: 24),

                            // Email
                            TextField(
                              controller: emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Email Address',
                                hintStyle: TextStyle(color: Colors.white54),
                                prefixIcon: Icon(Icons.alternate_email,
                                    color: accent),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: underline),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: underline, width: 2),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Password
                            TextField(
                              controller: passCtrl,
                              obscureText: obscure,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle:
                                    const TextStyle(color: Colors.white54),
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: accent,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => obscure = !obscure),
                                  icon: Icon(
                                    obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white60,
                                  ),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: underline),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: underline, width: 2),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ปุ่มล่าง
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
                        children: [
                          _circleBtn(Icons.android),
                          const SizedBox(width: 14),
                          _circleBtn(Icons.chat_bubble_outline),
                          const Spacer(),
                          _arrowBtn(() {
                            final email = emailCtrl.text.trim();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Signing in as $email')),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _circleBtn(IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white12,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(icon, color: Colors.white70, size: 22),
    );
  }

  static Widget _arrowBtn(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: accent,
          boxShadow: [
            BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: const Icon(Icons.arrow_forward_rounded,
            color: Colors.black, size: 26),
      ),
    );
  }
}
