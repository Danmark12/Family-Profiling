// lib/pages/consolidated_page.dart
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
  String? selectedBarangay;
  String? zone;

  @override
  void initState() {
    super.initState();
    _loadHouseholds();
  }

  Future<void> _loadHouseholds() async {
    final data = await DBHelper.instance.getAllHouseholds(); // You may need to implement this
    setState(() {
      households = data.map((e) => Household.fromMap(e)).toList();
    });
  }

  Map<String, int> _calculateTotals() {
    int totalHouseholds = households.length;
    int totalMale = households.fold(0, (sum, h) => sum + (h.male ?? 0));
    int totalFemale = households.fold(0, (sum, h) => sum + (h.female ?? 0));
    int totalChildren = households.fold(0, (sum, h) => sum + (h.total ?? 0));
    int total4Ps = households.fold(0, (sum, h) => sum + (h.fourPs));
    int totalIndigenous = households.fold(0, (sum, h) => sum + (h.indigenousPeople));
    int totalIodizedSalt = households.fold(0, (sum, h) => sum + (h.iodizedSalt));

    return {
      "Total Households": totalHouseholds,
      "Total Male": totalMale,
      "Total Female": totalFemale,
      "Total Population": totalChildren,
      "4Ps Beneficiaries": total4Ps,
      "Indigenous People": totalIndigenous,
      "Uses Iodized Salt": totalIodizedSalt,
    };
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals();

    return Scaffold(
      appBar: AppBar(title: const Text("Consolidated")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Family Profile",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Optional: filter by zone/barangay
          Row(children: [
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
          ]),
          const SizedBox(height: 20),

          // Table Header
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
              ...totals.entries.map((e) => TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(e.key),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(e.value.toString()),
                    ),
                  ])),
            ],
          ),
        ]),
      ),
    );
  }
}