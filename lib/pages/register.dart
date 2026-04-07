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

        // Success snackbar
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

        // Delay before redirect to login
        await Future.delayed(const Duration(seconds: 2));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } catch (e) {
        // Error snackbar (e.g., duplicate name)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6)),
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
                      // Name
                      TextFormField(
                        controller: nameController,
                        decoration: inputStyle('Name', Icons.person),
                        validator: (val) => val!.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 8),
                      // Barangay
                      DropdownButtonFormField<String>(
                        value: selectedBarangay,
                        hint: const Text('Select Barangay', style: TextStyle(fontSize: 12)),
                        items: barangays.map((b) {
                          return DropdownMenuItem(
                            value: b,
                            child: Text(b, style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedBarangay = val),
                        decoration: inputStyle('Barangay', Icons.location_city),
                        validator: (val) => val == null ? 'Select barangay' : null,
                      ),
                      const SizedBox(height: 8),
                      // Password
                      TextFormField(
                        controller: passwordController,
                        decoration: inputStyle('Password', Icons.lock),
                        obscureText: true,
                        validator: (val) => val!.isEmpty ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 8),
                      // Confirm Password
                      TextFormField(
                        controller: confirmController,
                        decoration: inputStyle('Confirm Password', Icons.lock_outline),
                        obscureText: true,
                        validator: (val) => val != passwordController.text ? 'Passwords do not match' : null,
                      ),
                      const SizedBox(height: 12),
                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: registerUser,
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                          child: Text(
                            'Register',
                            style: TextStyle(color: avocado, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Navigate to Login
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
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