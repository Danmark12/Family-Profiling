import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'archive.dart';
import 'profile.dart';
import 'login.dart';
import '../db/config.dart';

class SettingsPage extends StatefulWidget {
  final int currentUserId;

  const SettingsPage({super.key, required this.currentUserId});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Color avocado = const Color.fromARGB(255, 86, 130, 3);

  bool _showLogoutCard = false;
  bool _showDeleteAccountCard = false;
  bool _showPasswordConfirmCard = false;
  
  // Password confirmation
  final TextEditingController _passwordController = TextEditingController();
  bool _isDeleting = false;
  String _passwordError = '';

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userBarangay');

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> _verifyPasswordAndDelete() async {
    // Check if password is entered
    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _passwordError = 'Please enter your password';
      });
      return;
    }

    setState(() {
      _isDeleting = true;
      _passwordError = '';
    });

    try {
      // First, verify the password
      final user = await DBHelper.instance.loginUserById(widget.currentUserId);
      
      if (user != null && user['password'] == _passwordController.text.trim()) {
        // Password is correct, proceed with deletion
        await _deleteAccount();
      } else {
        // Password is incorrect
        setState(() {
          _passwordError = 'Incorrect password';
          _isDeleting = false;
        });
      }
    } catch (e) {
      setState(() {
        _passwordError = 'Error verifying password';
        _isDeleting = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    try {
      // Delete user from database
      await DBHelper.instance.deleteUser(widget.currentUserId);
      
      // Clear shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account permanently deleted'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Stack(
        children: [
          ListView(
            children: [
              const SizedBox(height: 10),

              _sectionTitle("Account"),
              _item(
                context,
                icon: Icons.person,
                title: "Profile",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfilePage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),

              const SizedBox(height: 10),
              _sectionTitle("Data"),
              _item(
                context,
                icon: Icons.archive,
                title: "Archive",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArchivedHouseholdPage(
                        currentUserId: widget.currentUserId,
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1),

              const SizedBox(height: 10),
              _sectionTitle("Danger Zone"),
              
              // DELETE ACCOUNT BUTTON
              _item(
                context,
                icon: Icons.delete_forever,
                title: "Delete Account",
                isDestructive: true,
                onTap: () {
                  setState(() {
                    _showDeleteAccountCard = true;
                  });
                },
              ),
              const Divider(height: 1),

              const SizedBox(height: 10),
              _sectionTitle("System"),
              
              // LOGOUT BUTTON
              _item(
                context,
                icon: Icons.logout,
                title: "Logout",
                isDestructive: true,
                onTap: () {
                  setState(() {
                    _showLogoutCard = true;
                  });
                },
              ),
            ],
          ),

          // ================= LOGOUT CONFIRMATION CARD =================
          if (_showLogoutCard)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() => _showLogoutCard = false);
                },
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 260,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Confirm Logout",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Are you sure you want to logout?",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showLogoutCard = false;
                                    });
                                  },
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _logout,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Logout"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ================= DELETE ACCOUNT CONFIRMATION CARD =================
          if (_showDeleteAccountCard)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showDeleteAccountCard = false;
                    _passwordController.clear();
                    _passwordError = '';
                  });
                },
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color.fromARGB(255, 24, 130, 5), 
                              size: 40,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Delete Account",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "This action is PERMANENT and cannot be undone. "
                              "All your data will be lost forever.",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showDeleteAccountCard = false;
                                      });
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _showDeleteAccountCard = false;
                                        _showPasswordConfirmCard = true;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 31, 2, 0),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text("Continue"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ================= PASSWORD CONFIRMATION CARD =================
          if (_showPasswordConfirmCard)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showPasswordConfirmCard = false;
                    _passwordController.clear();
                    _passwordError = '';
                  });
                },
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Verify Password",
                              style: TextStyle(
                                color: Color.fromARGB(255, 29, 2, 1),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Please enter your password to confirm account deletion.",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Password",
                                hintText: "Enter your password",
                                errorText: _passwordError.isNotEmpty ? _passwordError : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: avocado, width: 1.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showPasswordConfirmCard = false;
                                        _passwordController.clear();
                                        _passwordError = '';
                                      });
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isDeleting ? null : _verifyPasswordAndDelete,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 30, 2, 0),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: _isDeleting
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text("Delete"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ================= ITEM =================
  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive ? const Color.fromARGB(255, 10, 126, 4) : avocado,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors. black : Colors.black,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}