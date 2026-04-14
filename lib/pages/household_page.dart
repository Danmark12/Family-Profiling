// lib/pages/household_page.dart
import 'package:flutter/material.dart';
import '../db/config.dart';
import '../models/household.dart';
import 'household_detail_page.dart';
import 'add_household_page.dart';
import 'edit_household_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
    import 'package:intl/intl.dart';

class HouseholdPage extends StatefulWidget {
  final String? barangayFilter;

  const HouseholdPage({super.key, this.barangayFilter});

  @override
  State<HouseholdPage> createState() => _HouseholdPageState();
}

class _HouseholdPageState extends State<HouseholdPage> {
  List<Household> households = [];
  List<Household> displayedHouseholds = [];
  Set<int> selectedIds = {};

  String searchText = "";
  String? selectedPurok;
  int? userId;

  final Color avocado = const Color(0xFF568203);

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    fetchHouseholds(barangay: widget.barangayFilter);
  }

  Future<void> fetchHouseholds({String? barangay}) async {
    if (userId == null) return;

    final data = await DBHelper.instance.getUserHouseholds(userId!);

    households = data.map((e) => Household.fromMap(e)).toList();

    if (barangay != null) {
      households = households.where((h) => h.barangay == barangay).toList();
    }

    displayedHouseholds = List.from(households);
    filterHouseholds();
  }

  void filterHouseholds() {
    displayedHouseholds = households.where((hh) {
      final matchesSearch =
          hh.householdNo.toString().contains(searchText) ||
          (hh.fatherName ?? "")
              .toLowerCase()
              .contains(searchText.toLowerCase()) ||
          (hh.motherName ?? "")
              .toLowerCase()
              .contains(searchText.toLowerCase());

      final matchesPurok =
          selectedPurok == null || hh.zone == selectedPurok;

      return matchesSearch && matchesPurok;
    }).toList();

    setState(() {});
  }

  List<String> getPuroks() {
    final list = households
        .map((e) => e.zone ?? "")
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    list.sort();
    return list;
  }

  // ✅ FORMAT DATE
  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";

    try {
      final dt = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dt);
    } catch (e) {
      return date;
    }
  }

  void showBottomSheet(Household hh) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditHouseholdPage(household: hh),
                    ),
                  ).then((_) =>
                      fetchHouseholds(barangay: widget.barangayFilter));
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive, color: Colors.orange),
                title: const Text(
                  "Archive",
                  style: TextStyle(color: Colors.orange),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Confirm Archive"),
                      content: const Text(
                          "Are you sure you want to archive this household?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "Archive",
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await DBHelper.instance.archiveHousehold(hh.id!);

                    fetchHouseholds(barangay: widget.barangayFilter);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Household archived")),
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
        title: const Text("Households"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: Column(
        children: [
          // SEARCH + FILTER
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search by Name or HH No.",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      searchText = val;
                      filterHouseholds();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String?>(
                  value: selectedPurok,
                  hint: const Text("Purok"),
                  items: [
                    const DropdownMenuItem(value: null, child: Text("All")),
                    ...getPuroks()
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))),
                  ],
                  onChanged: (val) {
                    selectedPurok = val;
                    filterHouseholds();
                  },
                ),
              ],
            ),
          ),

          // LIST
          Expanded(
            child: displayedHouseholds.isEmpty
                ? const Center(child: Text("No households found"))
                : ListView.builder(
                    itemCount: displayedHouseholds.length,
                    itemBuilder: (context, index) {
                      final hh = displayedHouseholds[index];

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
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.folder, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Household ${hh.householdNo}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Father: ${hh.fatherName ?? '-'} | Mother: ${hh.motherName ?? '-'}",
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      "Purok: ${hh.zone ?? '-'} | ${hh.barangay ?? '-'}",
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),

                                    // ✅ DATE ADDED HERE
                                    Text(
                                      "Updated: ${formatDate(hh.createdAt)}",
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: avocado,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHouseholdPage()),
          ).then((_) =>
              fetchHouseholds(barangay: widget.barangayFilter));
        },
      ),
    );
  }
}