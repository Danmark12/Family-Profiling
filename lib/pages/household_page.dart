// lib/pages/household_page.dart
import 'package:flutter/material.dart';
import '../db/config.dart';
import '../models/household.dart';
import 'household_detail_page.dart';
import 'add_household_page.dart';
import 'edit_household_page.dart'; // NEW IMPORT

class HouseholdPage extends StatefulWidget {
  const HouseholdPage({super.key});

  @override
  State<HouseholdPage> createState() => _HouseholdPageState();
}

class _HouseholdPageState extends State<HouseholdPage> {
  List<Household> households = [];
  List<Household> displayedHouseholds = [];
  Set<int> selectedIds = {};

  String searchText = "";
  int? selectedPurok;

  final Color avocado = const Color(0xFF568203);

  @override
  void initState() {
    super.initState();
    fetchHouseholds();
  }

  Future<void> fetchHouseholds() async {
    households = await DBHelper.instance.getAllHouseholds();
    displayedHouseholds = List.from(households);
    filterHouseholds();
  }

  void filterHouseholds() {
    displayedHouseholds = households.where((hh) {
      final matchesSearch =
          hh.householdNo.toString().contains(searchText) ||
          (hh.householdHead ?? "")
              .toLowerCase()
              .contains(searchText.toLowerCase());

      final matchesPurok = selectedPurok == null || hh.zone == selectedPurok;

      return matchesSearch && matchesPurok;
    }).toList();

    setState(() {});
  }

  List<int> getPuroks() {
    final list = households
        .map((e) => e.zone ?? 0)
        .where((e) => e > 0)
        .toSet()
        .toList();
    list.sort();
    return list;
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
                  ).then((_) => fetchHouseholds());
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive),
                title: const Text("Archive"),
                onTap: () async {
                  Navigator.pop(context);
                  if (hh.id != null) {
                    await DBHelper.instance.archive(hh.id!);
                    fetchHouseholds();
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
          // 🔍 SEARCH + PUROK DROPDOWN
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // SEARCH BAR
                Expanded(
                  flex: 3,
  //               SizedBox(
  // width: 150,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Search",
                        border: InputBorder.none,
                        icon: Icon(Icons.search), 
                      ),
                      onChanged: (val) {
                        searchText = val;
                        filterHouseholds();
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ✅ PUROK DROPDOWN WITH "ALL"
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: DropdownButton<int?>(
                    value: selectedPurok,
                    hint: const Text("Purok"),
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text("All"),
                      ),
                      ...getPuroks().map(
                        (e) => DropdownMenuItem<int?>(
                          value: e,
                          child: Text(e.toString()),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        selectedPurok = val;
                      });
                      filterHouseholds();
                    },
                  ),
                ),
              ],
            ),
          ),

          // 📋 HOUSEHOLD LIST
          Expanded(
            child: displayedHouseholds.isEmpty
                ? const Center(child: Text("No households found"))
                : ListView.builder(
                    itemCount: displayedHouseholds.length,
                    itemBuilder: (context, index) {
                      final hh = displayedHouseholds[index];
                      final isSelected = selectedIds.contains(hh.id);

                      return GestureDetector(
                        onTap: () {
                          if (selectedIds.isEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HouseholdDetailPage(hh: hh),
                              ),
                            );
                          } else {
                            setState(() {
                              if (isSelected) {
                                selectedIds.remove(hh.id);
                              } else {
                                selectedIds.add(hh.id ?? 0);
                              }
                            });
                          }
                        },
                        onLongPress: () {
                          showBottomSheet(hh);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? avocado.withOpacity(0.2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: isSelected
                                    ? avocado
                                    : Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.folder, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "HH ${hh.householdNo} - ${hh.householdHead ?? "-"}",
                                  style: const TextStyle(fontSize: 16),
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

      // ➕ ADD BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: avocado,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHouseholdPage()),
          ).then((_) => fetchHouseholds());
        },
      ),
    );
  }
}