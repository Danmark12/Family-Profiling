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
  String? filterZone;
  String? filterBarangay;

  @override
  void initState() {
    super.initState();
    _loadHouseholds();
  }

  Future<void> _loadHouseholds() async {
    final data = await DBHelper.instance.getAllHouseholds();
    setState(() {
      households = data.map((e) => Household.fromMap(e)).toList();
    });
  }

  // Filter households by Zone and Barangay
  List<Household> get filteredHouseholds {
    return households.where((h) {
      final zoneMatch = filterZone == null || filterZone!.isEmpty || h.zone?.toLowerCase().contains(filterZone!.toLowerCase()) == true;
      final barangayMatch = filterBarangay == null || filterBarangay!.isEmpty || h.barangay?.toLowerCase().contains(filterBarangay!.toLowerCase()) == true;
      return zoneMatch && barangayMatch;
    }).toList();
  }

  Map<String, int> calculateTotals() {
    final list = filteredHouseholds;
    return {
      "Total Households": list.length,
      "Total Male": list.fold(0, (sum, h) => sum + (h.male ?? 0)),
      "Total Female": list.fold(0, (sum, h) => sum + (h.female ?? 0)),
      "Total Population": list.fold(0, (sum, h) => sum + (h.total ?? 0)),
      "4Ps Beneficiaries": list.fold(0, (sum, h) => sum + (h.fourPs)),
      "Indigenous People": list.fold(0, (sum, h) => sum + (h.indigenousPeople)),
      "Uses Iodized Salt": list.fold(0, (sum, h) => sum + (h.iodizedSalt)),
      "Fully Immunized Children": list.fold(0, (sum, h) => sum + (h.fullyImmunized ?? 0)),
      "PWD": list.fold(0, (sum, h) => sum + (h.pwd ?? 0)),
    };
  }

  @override
  Widget build(BuildContext context) {
    final totals = calculateTotals();

    return Scaffold(
      appBar: AppBar(title: const Text("Consolidated Report")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              "Family Profile",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Purok / Zone",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => filterZone = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Barangay",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => filterBarangay = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Document-like table
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Table(
                border: TableBorder.symmetric(
                  inside: const BorderSide(color: Colors.black),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                },
                children: [
                  // Header row
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
                  // Data rows
                  ...totals.entries.map(
                    (e) => TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(e.key),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(e.value.toString()),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text("Total Records Shown: ${filteredHouseholds.length}"),
          ],
        ),
      ),
    );
  }
}