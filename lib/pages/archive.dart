// lib/pages/archived_household_page.dart
import 'package:flutter/material.dart';
import '../db/config.dart';
import '../models/household.dart';
import 'household_detail_page.dart';

class ArchivedHouseholdPage extends StatefulWidget {
  final int currentUserId;

  const ArchivedHouseholdPage({super.key, required this.currentUserId});

  @override
  State<ArchivedHouseholdPage> createState() =>
      _ArchivedHouseholdPageState();
}

class _ArchivedHouseholdPageState extends State<ArchivedHouseholdPage> {
  List<Household> archivedHouseholds = [];
  List<Household> filteredHouseholds = [];

  String searchText = "";

  // =========================
  // SORT
  // =========================
  String sortOption = "A-Z";

  final GlobalKey _sortKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  // =========================
  // SELECTION MODE
  // =========================
  bool isSelectionMode = false;
  Set<int> selectedItems = {};

  @override
  void initState() {
    super.initState();
    fetchArchivedHouseholds();
  }

  Future<void> fetchArchivedHouseholds() async {
    final data = await DBHelper.instance
        .getArchivedHouseholds(widget.currentUserId);

    archivedHouseholds =
        data.map((e) => Household.fromMap(e)).toList();

    applyFilter();
  }

  void applyFilter() {
    List<Household> temp = archivedHouseholds.where((hh) {
      final name =
          "${hh.fatherName ?? ''} ${hh.motherName ?? ''}"
              .toLowerCase();

      final purok = (hh.zone ?? '').toLowerCase();
      final barangay = (hh.barangay ?? '').toLowerCase();

      final query = searchText.toLowerCase();

      return name.contains(query) ||
          purok.contains(query) ||
          barangay.contains(query);
    }).toList();

    // =========================
    // SORT LOGIC (FIXED)
    // =========================
    if (sortOption == "A-Z") {
      temp.sort((a, b) =>
          getHouseholdName(a).toLowerCase().compareTo(
              getHouseholdName(b).toLowerCase()));
    } else if (sortOption == "New-Old") {
      temp.sort((a, b) =>
          (b.id ?? 0).compareTo(a.id ?? 0));
    }

    setState(() {
      filteredHouseholds = temp;
    });
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
  // SORT MENU
  // =========================
  void showSortMenu() {
    final renderBox =
        _sortKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: hideSortMenu,
            child: Container(color: Colors.transparent),
          ),

          Positioned(
            left: offset.dx - 30,
            top: offset.dy + 40,
            child: Material(
              color: Colors.white,
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 140,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sortItem("A-Z"),
                    _sortItem("New-Old"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _sortItem(String value) {
    final isSelected = sortOption == value;

    return InkWell(
      onTap: () {
        setState(() {
          sortOption = value;
        });
        applyFilter();
        hideSortMenu();
      },
      child: Container(
        width: double.infinity,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Text(
          value,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void hideSortMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // =========================
  // SELECTION LOGIC
  // =========================
  void startSelection(Household hh) {
    setState(() {
      isSelectionMode = true;
      selectedItems.add(hh.id!);
    });
  }

  void toggleSelect(int id) {
    setState(() {
      if (selectedItems.contains(id)) {
        selectedItems.remove(id);
      } else {
        selectedItems.add(id);
      }

      if (selectedItems.isEmpty) {
        isSelectionMode = false;
      }
    });
  }

  void clearSelection() {
    setState(() {
      selectedItems.clear();
      isSelectionMode = false;
    });
  }

  void toggleSelectAll() {
    setState(() {
      if (selectedItems.length == filteredHouseholds.length) {
        selectedItems.clear();
        isSelectionMode = false;
      } else {
        selectedItems =
            filteredHouseholds.map((e) => e.id!).toSet();
        isSelectionMode = true;
      }
    });
  }

  Future<void> unarchiveSelected() async {
    for (final id in selectedItems) {
      await DBHelper.instance.unarchiveHousehold(id);
    }

    clearSelection();
    fetchArchivedHouseholds();
  }

  Future<void> deleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text(
            "Delete selected households permanently?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (final id in selectedItems) {
        await DBHelper.instance.deleteHouseholdPermanently(id);
      }

      clearSelection();
      fetchArchivedHouseholds();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),

        title: Text(
          isSelectionMode
              ? "${selectedItems.length} selected"
              : "Archived Households",
          style: const TextStyle(color: Colors.black),
        ),
      ),

      body: Column(
        children: [
          // ================= SEARCH + SORT =================
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      searchText = val;
                      applyFilter();
                    },
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  key: _sortKey,
                  onTap: showSortMenu,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ================= LIST =================
          Expanded(
            child: filteredHouseholds.isEmpty
                ? const Center(child: Text("No archived households"))
                : ListView.builder(
                    itemCount: filteredHouseholds.length,
                    itemBuilder: (context, index) {
                      final hh = filteredHouseholds[index];
                      final isSelected =
                          selectedItems.contains(hh.id);

                      return ListTile(
                        leading: isSelectionMode
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (_) =>
                                    toggleSelect(hh.id!),
                              )
                            : const Icon(
                                Icons.archive_outlined,
                                color: Colors.grey,
                              ),

                        title: Text(
                          getHouseholdName(hh),
                          style: const TextStyle(color: Colors.black),
                        ),

                        onTap: () {
                          if (isSelectionMode) {
                            toggleSelect(hh.id!);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HouseholdDetailPage(hh: hh),
                              ),
                            );
                          }
                        },

                        onLongPress: () => startSelection(hh),
                      );
                    },
                  ),
          ),
        ],
      ),

      bottomNavigationBar: isSelectionMode
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      onPressed: unarchiveSelected,
                      icon: const Icon(Icons.unarchive,
                          color: Colors.black),
                      label: const Text("Unarchive",
                          style: TextStyle(color: Colors.black)), 
                    ),
                    TextButton.icon(
                      onPressed: deleteSelected,
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.black),
                      label: const Text("Delete",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}