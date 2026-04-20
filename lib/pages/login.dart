// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/config.dart';
import 'nav_page.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final Color avocado = const Color(0xFF568203);

  bool isLoading = false;

  // ✅ ADDED: password visibility toggle
  bool _obscurePassword = true;

  // ---------------- LOGIN FUNCTION ----------------
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final user = await DBHelper.instance.loginUser(
        nameController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        // Save user session
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setInt('userId', user['id']);
        await prefs.setString('userName', user['name']);
        await prefs.setString('userBarangay', user['barangay']);

        // Success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login successful'),
            backgroundColor: avocado,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 800));

        // Go to home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeNavPage()),
          (route) => false,
        );
      } else {
        // Invalid login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid name or password'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      // Unexpected error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  // ---------------- INPUT STYLE ----------------
  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12),
      prefixIcon: Icon(icon, size: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: avocado, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avocado,
                  ),
                  child: const Icon(Icons.people, size: 30, color: Colors.white),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // NAME
                      TextFormField(
                        controller: nameController,
                        decoration: inputStyle('Name', Icons.person),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Enter name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 8),

                      // PASSWORD (✅ UPDATED WITH EYE ICON)
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: inputStyle('Password', Icons.lock).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter password';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: isLoading ? null : login,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: avocado,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // REGISTER LINK
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "No account? Register",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}