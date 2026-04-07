// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/config.dart';
import 'settings.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalHouseholds = 0;
  int totalResidents = 0;
  int male = 0;
  int female = 0;

  int? userId; // ✅ STORE USER ID HERE

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ✅ FIXED KEY
    userId = prefs.getInt('userId');

    if (userId == null) return;

    final households = await DBHelper.instance.getAllHouseholds(userId!);

    int totalRes = 0;
    int totalMale = 0;
    int totalFemale = 0;

    for (var h in households) {
      int m = h['male'] ?? 0;
      int f = h['female'] ?? 0;
      totalRes += m + f;
      totalMale += m;
      totalFemale += f;
    }

    setState(() {
      totalHouseholds = households.length;
      totalResidents = totalRes;
      male = totalMale;
      female = totalFemale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Census Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),

          // ✅ FIXED SETTINGS BUTTON
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User not loaded yet")),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SettingsPage(currentUserId: userId!),
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ListTile(
                leading: Icon(Icons.person, size: 40, color: Colors.blue),
                title: Text(
                  "Welcome",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Census Management System"),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                _buildCard("Total Households", totalHouseholds, Icons.home, Colors.orange),
                _buildCard("Total Residents", totalResidents, Icons.people, Colors.green),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                _buildCard("Male", male, Icons.male, Colors.blue),
                _buildCard("Female", female, Icons.female, Colors.pink),
              ],
            ),

            const SizedBox(height: 30),

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

  Widget _buildCard(String title, int value, IconData icon, Color color) {
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
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              Text(
                value.toString(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}