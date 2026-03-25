// lib/pages/household_page.dart
import 'package:flutter/material.dart';
import '../db/config.dart';
import '../models/household.dart';
import 'household_detail_page.dart';
import 'add_household_page.dart';

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
  String? selectedPurok;
  String sortBy = "Name A-Z";

  final avocado = const Color(0xFF568203);

  @override
  void initState() {
    super.initState();
    fetchHouseholds();
  }

  Future<void> fetchHouseholds() async {
    households = await DBHelper.instance.getAllHouseholds();
    displayedHouseholds = List.from(households);
    setState(() {});
  }

  void filterHouseholds() {
    displayedHouseholds = households.where((hh) {
      final matchesName = hh.name.toLowerCase().contains(searchText.toLowerCase());
      final matchesPurok = selectedPurok == null ? true : hh.purok == selectedPurok;
      return matchesName && matchesPurok;
    }).toList();

    // Sorting
    if (sortBy == "Name A-Z") {
      displayedHouseholds.sort((a, b) => a.name.compareTo(b.name));
    } else if (sortBy == "Name Z-A") {
      displayedHouseholds.sort((a, b) => b.name.compareTo(a.name));
    } else if (sortBy == "New-Old") {
      displayedHouseholds.sort((a, b) => b.id!.compareTo(a.id!));
    } else if (sortBy == "Old-New") {
      displayedHouseholds.sort((a, b) => a.id!.compareTo(b.id!));
    }

    setState(() {});
  }

  List<String> getPuroks() {
    final puroks = households.map((e) => e.purok).toSet().toList();
    puroks.sort();
    return puroks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Households"),
        backgroundColor: avocado,
      ),
      body: Column(
        children: [
          // SEARCH & FILTER BAR
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    // SEARCH BOX
                    Expanded(
                      flex: 3,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "Search by Name",
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (val) {
                          searchText = val;
                          filterHouseholds();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // SORT DROPDOWN
                    DropdownButton<String>(
                      value: sortBy,
                      items: ["Name A-Z","Name Z-A","New-Old","Old-New"]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        sortBy = val!;
                        filterHouseholds();
                      },
                      hint: const Text("Sort by"),
                    ),
                    const SizedBox(width: 16),
                    // PUROK DROPDOWN
                    DropdownButton<String>(
                      value: selectedPurok,
                      items: getPuroks()
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        selectedPurok = val;
                        filterHouseholds();
                      },
                      hint: const Text("Purok"),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // HOUSEHOLD LIST
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
                                selectedIds.add(hh.id!);
                              }
                            });
                          }
                        },
                        onLongPress: () {
                          setState(() {
                            if (isSelected) {
                              selectedIds.remove(hh.id);
                            } else {
                              selectedIds.add(hh.id!);
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? avocado.withOpacity(0.2) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSelected ? avocado : Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.folder, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(child: Text(hh.name, style: const TextStyle(fontSize: 16))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // ARCHIVE / EDIT BUTTONS
          if (selectedIds.isNotEmpty)
            Container(
              color: avocado.withOpacity(0.1),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    icon: const Icon(Icons.archive),
                    label: const Text("Archive"),
                    onPressed: () async {
                      bool? confirm = await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Confirm"),
                          content: const Text("Are you sure you want to archive selected households?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        for (var id in selectedIds) {
                          await DBHelper.instance.archive(id);
                        }
                        selectedIds.clear();
                        fetchHouseholds();
                      }
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: avocado),
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                    onPressed: () {
                      if (selectedIds.length == 1) {
                        final hhId = selectedIds.first;
                        final hh = households.firstWhere((e) => e.id == hhId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddHouseholdPage()), // TODO: Replace with EditPage
                        ).then((_) => fetchHouseholds());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select only 1 household to edit")),
                        );
                      }
                    },
                  ),
                ],
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
          ).then((_) => fetchHouseholds());
        },
      ),
    );
  }
}