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
  final _passwordFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  String? selectedBarangay;

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool isLoading = true;

  // ✅ ADDED: password visibility toggles
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> barangays = [
    'Amoros','Bolisong','Cogon','Himaya','Hinigdaan','Kalabaylabay','Molugan',
    'Pedro S. Baculio','Poblacion','Quibonbon','Sambulawan',
    'San Francisco de Asis','Sinaloc','Taytay','Ulaliman'
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ---------------- LOAD USER ----------------
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');

    if (userId != null) {
      final fetchedUser = await db.getUserById(userId!);

      if (fetchedUser != null) {
        setState(() {
          user = fetchedUser;
          _nameController.text = user!['name'] ?? '';
          selectedBarangay = user!['barangay'];
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
      'barangay': selectedBarangay,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );
  }

  // ---------------- CHANGE PASSWORD ----------------
  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate() || userId == null) return;

    await db.updateUser(userId!, {
      'password': _newPasswordController.text.trim(),
    });

    _newPasswordController.clear();
    _confirmPasswordController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password updated")),
    );
  }

  // ---------------- MINIMAL INPUT STYLE ----------------
  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      border: const UnderlineInputBorder(),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // HEADER
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [

                const SizedBox(height: 30),

                // ================= CENTERED NAME =================
                Center(
                  child: Column(
                    children: [
                      Text(
                        user?['name'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedBarangay ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ================= EDIT PROFILE =================
                const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      TextFormField(
                        controller: _nameController,
                        decoration: inputStyle('Name'),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter name' : null,
                      ),

                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: selectedBarangay,
                        decoration: inputStyle('Barangay'),
                        items: barangays.map((b) {
                          return DropdownMenuItem(
                            value: b,
                            child: Text(b),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => selectedBarangay = val),
                        validator: (val) =>
                            val == null ? 'Select barangay' : null,
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _updateProfile,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.black12),
                            ),
                          ),
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 20),

                // ================= PASSWORD =================
                const Text(
                  "Change Password",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                Form(
                  key: _passwordFormKey,
                  child: Column(
                    children: [

                      // NEW PASSWORD
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        decoration: inputStyle('New Password').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter password';
                          if (val.length < 4) return 'Minimum 4 characters';
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // CONFIRM PASSWORD
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: inputStyle('Confirm Password').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (val) {
                          if (val != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _changePassword,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.black12),
                            ),
                          ),
                          child: const Text(
                            "Update Password",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
    );
  }
}