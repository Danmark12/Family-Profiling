// lib/pages/profile.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/config.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DBHelper db = DBHelper.instance;

  int? userId;
  Map<String, dynamic>? user;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _barangayController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final Color avocado = const Color(0xFF568203);

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ---------------- LOAD USER ----------------
  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId'); // ✅ FIXED

    if (userId != null) {
      final fetchedUser = await db.getUserById(userId!);

      if (fetchedUser != null) {
        setState(() {
          user = fetchedUser;
          _nameController.text = user!['name'] ?? '';
          _barangayController.text = user!['barangay'] ?? '';
          _passwordController.text = user!['password'] ?? '';
          isLoading = false;
        });
      }
    }
  }

  // ---------------- UPDATE PROFILE ----------------
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || userId == null) return;

    await db.updateUser(userId!, {
      'name': _nameController.text.trim(),
      'barangay': _barangayController.text.trim(),
      'password': _passwordController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Profile updated successfully"),
        backgroundColor: avocado,
      ),
    );

    _loadUser();
  }

  // ---------------- INPUT STYLE ----------------
  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: avocado, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: avocado,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 320,
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: avocado,
                          child: const Icon(Icons.person, color: Colors.white, size: 30),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          user?['name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // NAME
                        TextFormField(
                          controller: _nameController,
                          decoration: inputStyle('Name', Icons.person),
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Enter name' : null,
                        ),

                        const SizedBox(height: 10),

                        // BARANGAY
                        TextFormField(
                          controller: _barangayController,
                          decoration: inputStyle('Barangay', Icons.location_city),
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Enter barangay' : null,
                        ),

                        const SizedBox(height: 10),

                        // PASSWORD
                        TextFormField(
                          controller: _passwordController,
                          decoration: inputStyle('Password', Icons.lock),
                          obscureText: true,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Enter password';
                            if (val.length < 4) return 'Minimum 4 characters';
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // UPDATE BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: avocado,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Update Profile",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}