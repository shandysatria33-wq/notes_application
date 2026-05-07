import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  // ✅ static dipindah ke sini
  static bool isLoggedIn = false;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  String? errorMessage;

  final String validEmail = 'shandysatria33@gmail.com';
  final String validPassword = '123';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email == validEmail && password == validPassword) {
      setState(() {
        AccountPage.isLoggedIn = true;
        errorMessage = null;
      });
    } else {
      setState(() {
        errorMessage = 'Email atau password salah.';
      });
    }
  }

  void logout() {
    setState(() {
      AccountPage.isLoggedIn = false;
      emailController.clear();
      passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDAD9D4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF293B42),
        elevation: 0,
        leading: const BackButton(color: Color(0xFFDAD9D4)),
        title: const Text(
          'Akun',
          style: TextStyle(
            color: Color(0xFFDAD9D4),
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AccountPage.isLoggedIn ? _buildProfile() : _buildLoginForm(),
    );
  }

  Widget _buildProfile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // AVATAR
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0x665D6E75),
                width: 3,
              ),
            ),
            child: const CircleAvatar(
              radius: 52,
              backgroundColor: Color(0x335D6E75),
              child: Icon(
                Icons.person,
                size: 52,
                color: Color(0xFF293B42),
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Shandy Satria',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF293B42),
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'shandysatria33@gmail.com',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xCC5D6E75),
            ),
          ),

          const SizedBox(height: 32),

          // INFO CARD
          Container(
            decoration: BoxDecoration(
              color: const Color(0x265D6E75),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0x405D6E75),
              ),
            ),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(
                    Icons.email_outlined,
                    color: Color(0xCC5D6E75),
                  ),
                  title: Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5D6E75),
                    ),
                  ),
                  subtitle: Text(
                    'shandysatria33@gmail.com',
                    style: TextStyle(
                      color: Color(0xFF293B42),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                  color: Color(0x335D6E75),
                  indent: 16,
                  endIndent: 16,
                ),
                const ListTile(
                  leading: Icon(
                    Icons.person_outline,
                    color: Color(0xCC5D6E75),
                  ),
                  title: Text(
                    'Nama',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5D6E75),
                    ),
                  ),
                  subtitle: Text(
                    'Shandy Satria',
                    style: TextStyle(
                      color: Color(0xFF293B42),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // SIGN OUT
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: logout,
              icon: const Icon(Icons.logout, size: 18),
              label: const Text(
                'Sign Out',
                style: TextStyle(fontSize: 15, letterSpacing: 1),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF293B42),
                foregroundColor: const Color(0xFFDAD9D4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),

          // ICON ATAS
          Center(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0x265D6E75),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0x4D5D6E75),
                ),
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 36,
                color: Color(0xFF293B42),
              ),
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Masuk ke Akun',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF293B42),
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Gunakan email dan password yang terdaftar.',
            style: TextStyle(
              color: Color(0xCC5D6E75),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 30),

          // EMAIL
          Container(
            decoration: BoxDecoration(
              color: const Color(0x1F5D6E75),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0x4D5D6E75),
              ),
            ),
            child: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Color(0xFF293B42)),
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: Color(0xB35D6E75),
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: Color(0xB35D6E75),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // PASSWORD
          Container(
            decoration: BoxDecoration(
              color: const Color(0x1F5D6E75),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0x4D5D6E75),
              ),
            ),
            child: TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: const TextStyle(color: Color(0xFF293B42)),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(
                  color: Color(0xB35D6E75),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xB35D6E75),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: const Color(0xB35D6E75),
                  ),
                  onPressed: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ERROR
          if (errorMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0x14FF0000),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x4DFF0000)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // TOMBOL LOGIN
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF293B42),
                foregroundColor: const Color(0xFFDAD9D4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 15, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}