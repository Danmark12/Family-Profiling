// lib/pages/barangay_page.dart
import 'package:flutter/material.dart';
import '../db/config.dart';
import 'consolidated.dart';
import 'barangay_household.dart';

class BarangayPage extends StatefulWidget {
  const BarangayPage({super.key});

  @override
  State<BarangayPage> createState() => _BarangayPageState();
}

class _BarangayPageState extends State<BarangayPage> {
  final TextEditingController searchController = TextEditingController();
  List<String> allBarangays = [];
  List<String> filteredBarangays = [];

  @override
  void initState() {
    super.initState();
    _loadBarangays();
  }

  // Load barangays that have at least one household
  Future<void> _loadBarangays() async {
    final households = await DBHelper.instance.getAllHouseholds();
    final barangaySet = households
        .map((h) => h['barangay'] as String?)
        .whereType<String>()
        .toSet();
    setState(() {
      allBarangays = barangaySet.toList();
      filteredBarangays = allBarangays;
    });
  }

  void _searchBarangay(String query) {
    final filtered = allBarangays
        .where((b) => b.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() => filteredBarangays = filtered);
  }

  void _openBarangayOptions(String barangay) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                barangay,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // close modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConsolidatedPage(barangay: barangay),
                    ),
                  );
                },
                icon: const Icon(Icons.list_alt),
                label: const Text("Consolidated"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BarangayHouseholdPage(barangay: barangay),
                    ),
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text("Households"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Barangays with Data"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Search Barangay",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _searchBarangay,
            ),
            const SizedBox(height: 20),

            // List of Barangays
            Expanded(
              child: filteredBarangays.isEmpty
                  ? const Center(child: Text("No barangay found"))
                  : ListView.builder(
                      itemCount: filteredBarangays.length,
                      itemBuilder: (context, index) {
                        final barangay = filteredBarangays[index];
                        return Card(
                          child: ListTile(
                            title: Text(barangay),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () => _openBarangayOptions(barangay),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}