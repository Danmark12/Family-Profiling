import 'package:flutter/material.dart';
import '../db/config.dart';
import '../models/household.dart';
import 'household_detail_page.dart';
import 'add_household_page.dart';
import 'edit_household_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String sortOption = "A-Z";

  int? userId;

  final Color avocado = const Color(0xFF568203);

  // =========================
  // CUSTOM DROPDOWN STATE
  // =========================
  OverlayEntry? _dropdownOverlay;
  final GlobalKey _sortKey = GlobalKey();
  final GlobalKey _purokKey = GlobalKey();

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

    if (sortOption == "A-Z") {
      displayedHouseholds.sort((a, b) =>
          getHouseholdName(a)
              .toLowerCase()
              .compareTo(getHouseholdName(b).toLowerCase()));
    } else {
      displayedHouseholds.sort((a, b) =>
          (b.id ?? 0).compareTo(a.id ?? 0));
    }

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

  String getHouseholdName(Household hh) {
    final father = hh.fatherName ?? "";
    final mother = hh.motherName ?? "";

    if (father.isEmpty && mother.isEmpty) return "No Name";
    if (father.isEmpty) return mother;
    if (mother.isEmpty) return father;

    return "$father & $mother";
  }

  // =========================
  // CUSTOM DROPDOWN (SORT + PUROK)
  // =========================
  void _showDropdown({
    required String type,
    required List<String> items,
  }) {
    _hideDropdown();

    final key = type == "sort" ? _sortKey : _purokKey;
    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _dropdownOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: _hideDropdown,
              child: Container(color: Colors.transparent),
            ),

            Positioned(
              left: position.dx,
              top: position.dy + renderBox.size.height + 5,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: items.map((e) {
                      return InkWell(
                        onTap: () {
                          if (type == "sort") {
                            sortOption = e;
                          } else {
                            selectedPurok = e == "All" ? null : e;
                          }

                          filterHouseholds();
                          _hideDropdown();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Text(
                            e,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_dropdownOverlay!);
  }

  void _hideDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  // =========================
  // LONG PRESS (RESTORED)
  // =========================
  void showBottomSheet(Household hh) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditHouseholdPage(household: hh),
                    ),
                  ).then((_) =>
                      fetchHouseholds(barangay: widget.barangayFilter));
                },
              ),

              ListTile(
                leading: const Icon(Icons.archive),
                title: const Text("Archive"),
                onTap: () async {
                  Navigator.pop(context);
                  await DBHelper.instance.archiveHousehold(hh.id!);
                  fetchHouseholds(barangay: widget.barangayFilter);
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
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
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Column(
        children: [
          // SEARCH + FILTER + SORT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // SEARCH
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
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

                const SizedBox(width: 8),

                // PUROK
                GestureDetector(
                  key: _purokKey,
                  onTap: () => _showDropdown(
                    type: "purok",
                    items: ["All", ...getPuroks()],
                  ),
                  child: _buildButton(selectedPurok ?? "Purok"),
                ),

                const SizedBox(width: 8),

                // SORT
                GestureDetector(
                  key: _sortKey,
                  onTap: () => _showDropdown(
                    type: "sort",
                    items: ["A-Z", "New-Old"],
                  ),
                  child: _buildButton(sortOption),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // LIST
          Expanded(
            child: ListView.builder(
              itemCount: displayedHouseholds.length,
              itemBuilder: (context, index) {
                final hh = displayedHouseholds[index];

                return ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: Text(getHouseholdName(hh)),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            HouseholdDetailPage(hh: hh),
                      ),
                    );
                  },

                  // ✅ RESTORED LONG PRESS
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
          ).then((_) =>
              fetchHouseholds(barangay: widget.barangayFilter));
        },
      ),
    );
  }

  // =========================
  // REUSABLE BUTTON STYLE
  // =========================
  Widget _buildButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 18),
        ],
      ),
    );
  }
}