// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import '../db/config.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  String? selectedBarangay;

  final List<String> barangays = [
    'Amoros','Bolisong','Cogon','Himaya','Hinigdaan','Kalabaylabay','Molugan',
    'Pedro S. Baculio','Poblacion','Quibonbon','Sambulawan',
    'San Francisco de Asis','Sinaloc','Taytay','Ulaliman'
  ];

  final Color avocado = const Color(0xFF568203);

  // ✅ ADDED: visibility toggles
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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

  // ---------------- REGISTER FUNCTION ----------------
  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await DBHelper.instance.registerUser(
          nameController.text.trim(),
          selectedBarangay!,
          passwordController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account registered successfully'),
            backgroundColor: avocado,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        nameController.clear();
        passwordController.clear();
        confirmController.clear();
        setState(() => selectedBarangay = null);

        await Future.delayed(const Duration(seconds: 2));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Username already exists'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
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
                  child: const Icon(Icons.people, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Register',
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

                      // BARANGAY
                      DropdownButtonFormField<String>(
                        value: selectedBarangay,
                        hint: const Text(
                          'Select Barangay',
                          style: TextStyle(fontSize: 12),
                        ),
                        items: barangays.map((b) {
                          return DropdownMenuItem(
                            value: b,
                            child: Text(
                              b,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedBarangay = val),
                        decoration: inputStyle('Barangay', Icons.location_city),
                        validator: (val) =>
                            val == null ? 'Select barangay' : null,
                      ),

                      const SizedBox(height: 8),

                      // PASSWORD
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
                          if (val.length < 4) {
                            return 'Minimum 4 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 8),

                      // CONFIRM PASSWORD
                      TextFormField(
                        controller: confirmController,
                        obscureText: _obscureConfirm,
                        decoration: inputStyle(
                          'Confirm Password',
                          Icons.lock_outline,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              });
                            },
                          ),
                        ),
                        validator: (val) {
                          if (val != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // REGISTER BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: registerUser,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: avocado,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // GO TO LOGIN
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                          );
                        },
                        child: const Text(
                          'Already have an account? Login',
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