// lib/pages/archived_household_page.dart
import 'package:flutter/material.dart';
import '../db/config.dart';
import '../models/household.dart';
import 'household_detail_page.dart';

class ArchivedHouseholdPage extends StatefulWidget {
  final int currentUserId; // Logged-in user's ID

  const ArchivedHouseholdPage({super.key, required this.currentUserId});

  @override
  State<ArchivedHouseholdPage> createState() => _ArchivedHouseholdPageState();
}

class _ArchivedHouseholdPageState extends State<ArchivedHouseholdPage> {
  List<Household> archivedHouseholds = [];
  List<Household> filteredHouseholds = [];
  String? filterZone;
  String? filterBarangay;

  @override
  void initState() {
    super.initState();
    fetchArchivedHouseholds();
  }

  Future<void> fetchArchivedHouseholds() async {
    final data = await DBHelper.instance.getArchivedHouseholds(widget.currentUserId);
    archivedHouseholds = data.map((e) => Household.fromMap(e)).toList();
    applyFilter();
  }

  void applyFilter() {
    setState(() {
      filteredHouseholds = archivedHouseholds.where((hh) {
        final matchZone = filterZone == null || filterZone!.isEmpty
            ? true
            : hh.zone?.toLowerCase().contains(filterZone!.toLowerCase()) ?? false;
        final matchBarangay = filterBarangay == null || filterBarangay!.isEmpty
            ? true
            : hh.barangay?.toLowerCase().contains(filterBarangay!.toLowerCase()) ?? false;
        return matchZone && matchBarangay;
      }).toList();
    });
  }

  void showBottomSheet(Household hh) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.unarchive, color: Colors.green),
                title: const Text("Unarchive", style: TextStyle(color: Colors.green)),
                onTap: () async {
                  Navigator.pop(context);
                  await DBHelper.instance.unarchiveHousehold(hh.id!);
                  fetchArchivedHouseholds();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Household unarchived")),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete Permanently", style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Confirm Delete"),
                      content: const Text(
                          "Are you sure you want to delete this household permanently?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Delete", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await DBHelper.instance.deleteHouseholdPermanently(hh.id!);
                    fetchArchivedHouseholds();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Household deleted permanently")),
                    );
                  }
                },
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
        title: const Text("Archived Households"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- Search / Filter ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Filter by Zone/Purok",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      filterZone = v;
                      applyFilter();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Filter by Barangay",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      filterBarangay = v;
                      applyFilter();
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- List ---
          Expanded(
            child: filteredHouseholds.isEmpty
                ? const Center(
                    child: Text(
                      "No archived households",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredHouseholds.length,
                    itemBuilder: (context, index) {
                      final hh = filteredHouseholds[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HouseholdDetailPage(hh: hh),
                            ),
                          );
                        },
                        onLongPress: () => showBottomSheet(hh),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.archive,
                                    color: Colors.orange,
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Household ${hh.householdNo}",
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Father: ${hh.fatherName ?? '-'} | Mother: ${hh.motherName ?? '-'}",
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Purok: ${hh.zone ?? '-'} | ${hh.barangay ?? '-'}",
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.more_vert, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}