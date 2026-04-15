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

    filterHouseholds();
  }

  void filterHouseholds() {
    displayedHouseholds = households.where((hh) {
      final matchesSearch =
          (hh.fatherName ?? "").toLowerCase().contains(searchText.toLowerCase()) ||
          (hh.motherName ?? "").toLowerCase().contains(searchText.toLowerCase());

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

  void showBottomSheet(Household hh) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Column(
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
                ).then((_) => fetchHouseholds(barangay: widget.barangayFilter));
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive, color: Colors.orange),
              title: const Text("Archive"),
              onTap: () async {
                Navigator.pop(context);
                await DBHelper.instance.archiveHousehold(hh.id!);
                fetchHouseholds(barangay: widget.barangayFilter);
              },
            ),
          ],
        );
      },
    );
  }

  // ✅ CLEAN NAME FORMAT (ONLY NAME)
  String getHouseholdName(Household hh) {
    final father = hh.fatherName ?? "";
    final mother = hh.motherName ?? "";

    if (father.isEmpty && mother.isEmpty) return "No Name";
    if (father.isEmpty) return mother;
    if (mother.isEmpty) return father;

    return "$father & $mother";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Households",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Column(
        children: [
          // SEARCH + FILTER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search name...",
                        prefixIcon: const Icon(Icons.search, size: 18),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        searchText = val;
                        filterHouseholds();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String?>(
                    value: selectedPurok,
                    underline: const SizedBox(),
                    hint: const Text("Purok"),
                    items: [
                      const DropdownMenuItem(value: null, child: Text("All")),
                      ...getPuroks().map(
                        (e) => DropdownMenuItem(value: e, child: Text(e)),
                      ),
                    ],
                    onChanged: (val) {
                      selectedPurok = val;
                      filterHouseholds();
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // LIST (NAME ONLY)
          Expanded(
            child: displayedHouseholds.isEmpty
                ? const Center(child: Text("No households found"))
                : ListView.separated(
                    itemCount: displayedHouseholds.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final hh = displayedHouseholds[index];

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),

                        leading: const Icon(
                          Icons.home_outlined,
                          color: Colors.grey,
                        ),

                        // ✅ ONLY NAME (NO HOUSEHOLD #)
                        title: Text(
                          getHouseholdName(hh),
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),

                        // subtitle: Text(
                        //   hh.zone ?? '-',
                        //   style: const TextStyle(fontSize: 12),
                        // ),

                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey,
                        ),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HouseholdDetailPage(hh: hh),
                            ),
                          );
                        },

                        onLongPress: () => showBottomSheet(hh),
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
            MaterialPageRoute(
              builder: (_) => const AddHouseholdPage(),
            ),
          ).then((_) => fetchHouseholds(barangay: widget.barangayFilter));
        },
      ),
    );
  }
}