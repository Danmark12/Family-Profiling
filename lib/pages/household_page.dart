import 'package:flutter/material.dart';
import '../db/config.dart';
import '../models/household.dart';
import 'household_detail_page.dart';
import 'add_household_page.dart';
import 'edit_household_page.dart';
import 'import/import_csv.dart';
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

  // Selection mode variables
  bool isSelectionMode = false;
  Set<int> selectedHouseholdIds = {};

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
    
    // Exit selection mode when data refreshes
    _exitSelectionMode();
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
  // SELECTION MODE METHODS
  // =========================
  void _enterSelectionMode(int householdId) {
    setState(() {
      isSelectionMode = true;
      selectedHouseholdIds = {householdId};
    });
  }

  void _exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedHouseholdIds.clear();
    });
  }

  void _toggleSelection(int householdId) {
    setState(() {
      if (selectedHouseholdIds.contains(householdId)) {
        selectedHouseholdIds.remove(householdId);
        if (selectedHouseholdIds.isEmpty) {
          isSelectionMode = false;
        }
      } else {
        selectedHouseholdIds.add(householdId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (selectedHouseholdIds.length == displayedHouseholds.length) {
        // If all are selected, deselect all
        selectedHouseholdIds.clear();
        isSelectionMode = false;
      } else {
        // Select all displayed households
        selectedHouseholdIds = displayedHouseholds
            .map((hh) => hh.id!)
            .toSet();
        isSelectionMode = true;
      }
    });
  }

  bool get isAllSelected => selectedHouseholdIds.length == displayedHouseholds.length && displayedHouseholds.isNotEmpty;

  Future<void> _archiveSelected() async {
    if (selectedHouseholdIds.isEmpty) return;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Archive Households"),
        content: Text("Are you sure you want to archive ${selectedHouseholdIds.length} household(s)?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Archive"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Archive all selected households
    for (int id in selectedHouseholdIds) {
      await DBHelper.instance.archiveHousehold(id);
    }

    // Refresh and exit selection mode
    await fetchHouseholds(barangay: widget.barangayFilter);
    _exitSelectionMode();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Archived Succesfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _editSelected() async {
    if (selectedHouseholdIds.length != 1) return;

    final householdToEdit = households.firstWhere(
      (hh) => hh.id == selectedHouseholdIds.first,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditHouseholdPage(household: householdToEdit),
      ),
    );

    if (result == true) {
      await fetchHouseholds(barangay: widget.barangayFilter);
    }
    _exitSelectionMode();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: isSelectionMode
            ? Text(
                "${selectedHouseholdIds.length} selected",
                style: const TextStyle(color: Colors.black),
              )
            : const Text(
                "Households",
                style: TextStyle(color: Colors.black),
              ),
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              )
            : null,
        actions: isSelectionMode
            ? [
                // Select All Checkbox Button
                Row(
                  children: [
                    GestureDetector(
                      onTap: _selectAll,
                      child: Row(
                        children: [
                          Checkbox(
                            value: isAllSelected,
                            onChanged: (_) => _selectAll(),
                            activeColor: const Color(0xFF568203),
                          ),
                          const Text(
                            "Select All",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            : null,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Column(
        children: [
          // SEARCH + FILTER + SORT (hide when in selection mode? optional)
          if (!isSelectionMode)
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
                final isSelected = selectedHouseholdIds.contains(hh.id);

                return ListTile(
                  leading: isSelectionMode
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggleSelection(hh.id!),
                          activeColor: avocado,
                        )
                      : const Icon(Icons.home_outlined),
                  title: Text(getHouseholdName(hh)),
                  selected: isSelected,
                  selectedTileColor: Colors.grey.shade100,

                  onTap: () {
                    if (isSelectionMode) {
                      _toggleSelection(hh.id!);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HouseholdDetailPage(hh: hh),
                        ),
                      );
                    }
                  },

                  onLongPress: () {
                    if (!isSelectionMode) {
                      _enterSelectionMode(hh.id!);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Action Buttons (Edit & Archive for single, Archive only for multiple)
      floatingActionButton: isSelectionMode
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show Edit button only when exactly ONE is selected
                if (selectedHouseholdIds.length == 1)
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: FloatingActionButton(
                      heroTag: "edit_selected",
                      backgroundColor: Colors.white,
                      elevation: 2,
                      child: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: _editSelected,
                    ),
                  ),
                
                if (selectedHouseholdIds.length == 1)
                  const SizedBox(height: 10),

                // Archive button (shown for any selection)
                SizedBox(
                  width: 56,
                  height: 56,
                  child: FloatingActionButton(
                    heroTag: "archive_selected",
                    backgroundColor: Colors.white,
                    elevation: 2,
                    child: const Icon(Icons.archive, color: Colors.red),
                    onPressed: _archiveSelected,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 📥 IMPORT BUTTON (White with border)
                SizedBox(
                  width: 56,
                  height: 56,
                  child: FloatingActionButton(
                    heroTag: "import",
                    backgroundColor: Colors.white,
                    elevation: 2,
                    child: const Icon(Icons.upload_file, color: Colors.blue),
                    onPressed: () async {
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("User not logged in")),
                        );
                        return;
                      }

                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                'Importing households...',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              const Text('Please wait', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      );

                      try {
                        // ✅ FIXED: Use correct import method
                        final result = await ImportBarangayCSV.import(
                          userId: userId!,
                          barangay: widget.barangayFilter ?? "",
                        );

                        // Close loading dialog
                        if (context.mounted) Navigator.pop(context);

                        // Show result
                        if (result.success) {
                          // Refresh the list
                          await fetchHouseholds(barangay: widget.barangayFilter);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        } else {
                          // Show detailed error in dialog
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Import Failed"),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(result.message),
                                      if (result.errors.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        const Text(
                                          "Details:",
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        ...result.errors.map((error) => Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            error,
                                            style: const TextStyle(fontSize: 12, color: Colors.red),
                                          ),
                                        )),
                                      ],
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        // Close loading dialog
                        if (context.mounted) Navigator.pop(context);
                        
                        // Show error
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Import error: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // ➕ ADD BUTTON (White with border)
                SizedBox(
                  width: 56,
                  height: 56,
                  child: FloatingActionButton(
                    heroTag: "add",
                    backgroundColor: Colors.white,
                    elevation: 2,
                    child: const Icon(Icons.add, color: Color(0xFF568203)),
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
                ),
              ],
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