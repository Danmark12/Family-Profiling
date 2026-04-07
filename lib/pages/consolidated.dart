// lib/pages/consolidated_page.dart
import 'package:flutter/material.dart';
import '../db/config.dart';
import '../models/household.dart';

class ConsolidatedPage extends StatefulWidget {
  final int currentUserId; // Pass the logged-in user's id

  const ConsolidatedPage({super.key, required this.currentUserId});

  @override
  State<ConsolidatedPage> createState() => _ConsolidatedPageState();
}

class _ConsolidatedPageState extends State<ConsolidatedPage> {
  List<Household> households = [];
  String? selectedBarangay;
  String? zone;

  @override
  void initState() {
    super.initState();
    _loadHouseholds();
  }

  Future<void> _loadHouseholds() async {
    final data = await DBHelper.instance.getAllHouseholds(widget.currentUserId);
    setState(() {
      households = data.map((e) => Household.fromMap(e)).toList();
    });
  }

  // Calculate totals based on a given list of households
  Map<String, int> _calculateTotals(List<Household> data) {
    int totalHouseholds = data.length;
    int totalMale = data.fold(0, (sum, h) => sum + (h.male ?? 0));
    int totalFemale = data.fold(0, (sum, h) => sum + (h.female ?? 0));
    int totalPopulation = data.fold(0, (sum, h) => sum + (h.total ?? 0));
    int total4Ps = data.fold(0, (sum, h) => sum + (h.fourPs));
    int totalIndigenous = data.fold(0, (sum, h) => sum + (h.indigenousPeople));
    int totalIodizedSalt = data.fold(0, (sum, h) => sum + (h.iodizedSalt));

    return {
      "Total Households": totalHouseholds,
      "Total Male": totalMale,
      "Total Female": totalFemale,
      "Total Population": totalPopulation,
      "4Ps Beneficiaries": total4Ps,
      "Indigenous People": totalIndigenous,
      "Uses Iodized Salt": totalIodizedSalt,
    };
  }

  // Apply filters
  List<Household> get filteredHouseholds {
    return households.where((h) {
      final matchesZone = zone == null || zone!.isEmpty || (h.zone?.toLowerCase().contains(zone!.toLowerCase()) ?? false);
      final matchesBarangay = selectedBarangay == null || selectedBarangay!.isEmpty || (h.barangay?.toLowerCase().contains(selectedBarangay!.toLowerCase()) ?? false);
      return matchesZone && matchesBarangay;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals(filteredHouseholds);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Consolidated"),
        backgroundColor: const Color(0xFF568203),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Family Profile",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Filter Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Purok / Zone",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => zone = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Barangay",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => selectedBarangay = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Totals Table
            Table(
              border: TableBorder.all(color: Colors.black),
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Colors.grey),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Indicator", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Number", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...totals.entries.map(
                  (e) => TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(e.key)),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(e.value.toString())),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}