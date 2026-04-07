// lib/pages/barangay_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/config.dart';
import 'barangay_household.dart'; // page to show households per barangay

class BarangayPage extends StatefulWidget {
  const BarangayPage({super.key});

  @override
  State<BarangayPage> createState() => _BarangayPageState();
}

class _BarangayPageState extends State<BarangayPage> {
  List<String> barangays = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBarangays();
  }

  Future<void> _loadBarangays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userID');
    if (userId == null) return;

    // Fetch all households for this user
    final households = await DBHelper.instance.getAllHouseholds(userId);

    // Extract unique barangays that have households
    final barangaySet = <String>{};
    for (var h in households) {
      if (h['barangay'] != null && h['barangay'].toString().isNotEmpty) {
        barangaySet.add(h['barangay']);
      }
    }

    setState(() {
      barangays = barangaySet.toList()..sort();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Barangay List"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : barangays.isEmpty
              ? const Center(child: Text("No Barangay Data"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: barangays.length,
                  itemBuilder: (context, index) {
                    final barangay = barangays[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_city),
                        title: Text(barangay),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          // Go to households in this barangay
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BarangayHouseholdPage(
                                barangay: barangay,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}