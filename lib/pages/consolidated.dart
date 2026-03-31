// lib/pages/consolidated.dart
import 'package:flutter/material.dart';
import '../db/config.dart';
import '../models/household.dart';

class ConsolidatedPage extends StatefulWidget {
  const ConsolidatedPage({super.key});

  @override
  State<ConsolidatedPage> createState() => _ConsolidatedPageState();
}

class _ConsolidatedPageState extends State<ConsolidatedPage> {
  List<Household> households = [];

  // Totals
  int totalMembers = 0;
  int totalMales = 0;
  int totalFemales = 0;
  int totalFamilies = 0;
  int totalInfantsComplementary = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchHouseholds();
  }

  Future<void> fetchHouseholds() async {
    setState(() => loading = true);

    households = await DBHelper.instance.getAllHouseholds();

    // Calculate totals
    totalMembers = households.fold(0, (sum, h) => sum + (h.total ?? 0));
    totalMales = households.fold(0, (sum, h) => sum + (h.male ?? 0));
    totalFemales = households.fold(0, (sum, h) => sum + (h.female ?? 0));
    totalFamilies = households.fold(0, (sum, h) => sum + (h.families ?? 0));
    totalInfantsComplementary =
        households.fold(0, (sum, h) => sum + (h.infantsComplementary ?? 0));

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    const avocado = Color(0xFF568203);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Consolidated Data",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchHouseholds,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildStatCard("Total Members", totalMembers, avocado),
                  _buildStatCard("Total Males", totalMales, avocado),
                  _buildStatCard("Total Females", totalFemales, avocado),
                  _buildStatCard("Total Families", totalFamilies, avocado),
                  _buildStatCard(
                      "Infants Given Complementary Foods",
                      totalInfantsComplementary,
                      avocado),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}