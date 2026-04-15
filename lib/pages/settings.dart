// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'archive.dart';
import 'logout.dart';
import 'profile.dart';

class SettingsPage extends StatelessWidget {
  final int currentUserId;

  const SettingsPage({super.key, required this.currentUserId});

  final Color avocado = const Color.fromARGB(255, 6, 9, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ FULL WHITE BG

      // HEADER
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

      body: ListView(
        children: [

          const SizedBox(height: 10),

          // ================= ACCOUNT =================
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

          // ================= DATA =================
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
                    currentUserId: currentUserId,
                  ),
                ),
              );
            },
          ),

          const Divider(height: 1),

          // ================= SYSTEM =================
          const SizedBox(height: 10),
          _sectionTitle("System"),
          _item(
            context,
            icon: Icons.logout,
            title: "Logout",
            isDestructive: true, // 🔴 logout style
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LogoutPage(),
                ),
              );
            },
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
          vertical: 12, // ✅ NOT TOO BIG
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive ? Colors.black : avocado,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isDestructive ? Colors.black : Colors.black,
                  fontWeight: FontWeight.w500,
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

  // ================= SECTION TITLE =================
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