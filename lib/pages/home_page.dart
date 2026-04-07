// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'settings.dart';   // Make sure this page exists
import 'profile.dart';    // Profile page

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Census Dashboard"),
        centerTitle: true,
        actions: [
          // Profile Icon
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          // Settings Icon
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Welcome Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.person, size: 40, color: Colors.blue),
                title: const Text(
                  "Welcome",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Census Management System"),
              ),
            ),

            const SizedBox(height: 20),

            // Stats Section (First Row)
            Row(
              children: [
                _buildCard("Total Households", "0", Icons.home, Colors.orange),
                _buildCard("Total Residents", "0", Icons.people, Colors.green),
              ],
            ),

            const SizedBox(height: 15),

            // Stats Section (Second Row)
            Row(
              children: [
                _buildCard("Male", "0", Icons.male, Colors.blue),
                _buildCard("Female", "0", Icons.female, Colors.pink),
              ],
            ),

            const SizedBox(height: 30),

            // Info Section
            const Text(
              "Use the navigation below to manage households and barangay data.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HELPER FUNCTION TO BUILD CARDS ----------------
  Widget _buildCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}