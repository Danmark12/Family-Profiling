import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/config.dart';
import '../models/household.dart';
import 'export/export_b_pdf.dart';
import 'export/export_b_csv.dart';
import 'package:intl/intl.dart';

class BarangayHouseholdPage extends StatefulWidget {
  const BarangayHouseholdPage({super.key});

  @override
  State<BarangayHouseholdPage> createState() =>
      _BarangayHouseholdPageState();
}

class _BarangayHouseholdPageState
    extends State<BarangayHouseholdPage> {
  int? userId;
  String barangay = "";

  String generatedDate = "";
  String generatedTime = "";

  String selectedZone = "All";
bool sortAsc = true;



  List<Household> households = [];
  List<Household> filtered = [];

  List<String> zones = ["All"];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');

    if (userId == null) return;

    final user = await DBHelper.instance.getUserById(userId!);
    final data = await DBHelper.instance.getUserHouseholds(userId!);

    final list = data.map((e) => Household.fromMap(e)).toList();

    final uniqueZones = list
        .map((e) => e.zone ?? "")
        .where((z) => z.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) {
        final intA = int.tryParse(a) ?? 0;
        final intB = int.tryParse(b) ?? 0;
        return intA.compareTo(intB);
      });

    setState(() {
      barangay = user?['barangay'] ?? "";
      households = list;
      filtered = list;
      zones = ["All", ...uniqueZones];
    });
  }

void _sortHousehold() {
  setState(() {
    sortAsc = !sortAsc;

    filtered.sort((a, b) {
      final zoneA = int.tryParse(a.zone ?? "0") ?? 0;
      final zoneB = int.tryParse(b.zone ?? "0") ?? 0;

      return sortAsc
          ? zoneA.compareTo(zoneB)
          : zoneB.compareTo(zoneA);
    });
  });
}

void _filterZone(String zone) {
  setState(() {
    selectedZone = zone;

    if (zone == "All") {
      filtered = List.from(households);
    } else {
      filtered = households.where((h) => h.zone == zone).toList();
    }

    // ALWAYS apply current sort after filtering
    filtered.sort((a, b) {
      final aNo = int.tryParse(a.householdNo.toString()) ?? 0;
      final bNo = int.tryParse(b.householdNo.toString()) ?? 0;

      return sortAsc ? aNo.compareTo(bNo) : bNo.compareTo(aNo);
    });
  });
}

  // ✅ GENERATE PH TIME
  void _generateDateTime() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 8));

    generatedDate = DateFormat('MMMM dd, yyyy').format(now);
    generatedTime = DateFormat('hh:mm a').format(now);
  }

  // ✅ FIXED PDF EXPORT
Future<void> _exportPdf() async {
  if (userId == null) return;

  _generateDateTime();

  // 🔥 USE EXACT SAME DATA AS TABLE (ALREADY SORTED + FILTERED)
  final dataToExport = List<Household>.from(filtered);

  await ExportBarangayPDF.generate(
    data: dataToExport,
    barangay: barangay,
    zone: selectedZone,
    generatedDate: generatedDate,
    generatedTime: generatedTime,
    sortAsc: sortAsc,
  );
}

  // ✅ ADDED: convert 1/0 to Y/N
  String _yesNo(dynamic value) {
    return (value == 1) ? "Y" : "N";
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Barangay Household Table"),
      actions: [

        // 📄 PDF EXPORT
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: "Export PDF",
          onPressed: _exportPdf,
        ),

        // 📊 CSV EXPORT
        IconButton(
          icon: const Icon(Icons.grid_on),
          tooltip: "Export CSV",
          onPressed: () async {
            if (userId == null) return;
            _generateDateTime();
            // final data =
            //     await DBHelper.instance.getUserHouseholds(userId!);

            // final households =
            //     data.map((e) => Household.fromMap(e)).toList();
            final households = List<Household>.from(filtered);



await ExportBarangayCSV.generate(
  data: households,
  barangay: barangay,
  zone: selectedZone,
);

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("CSV file saved successfully"),
              ),
            );
          },
        ),

      ],
    ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Center(
                  child: Text(
                    "Family Profile",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

               Row(
  children: [
    Expanded(
      child: Text("Barangay: $barangay"),
    ),

    // SMALL SORT BUTTON (ONLY IF ALL)
    if (selectedZone == "All")
      IconButton(
        tooltip: sortAsc
            ? "Sort Descending"
            : "Sort Ascending",
        icon: Icon(
          sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
          size: 20,
        ),
        onPressed: _sortHousehold,
      ),

    // ZONE DROPDOWN (unchanged, just compact spacing)
    Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedZone,
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: (value) {
            if (value != null) _filterZone(value);
          },
          items: zones.map((z) {
            return DropdownMenuItem(
              value: z,
              child: Text(
                z == "All" ? "All Zones" : "Zone $z",
              ),
            );
          }).toList(),
        ),
      ),
    ),
  ],
),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: _buildTable(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TableRow> _buildTable() {
    final headers = [
      "HH",
      "Zone",
      "Father Name",
      "Father Occupation",
      "Father Education",
      "Mother Name",
      "Mother Occupation",
      "Mother Education",
      "Male",
      "Female",
      "Total",
      "Families",
      "Fully Immunized",
      "4Ps",
      "IP",
      "0-5",
      "6-11",
      "12-23",
      "24-59",
      "5-9",
      "10-19",
      "20-59",
      "60+",
      "PWD",

      "Preg <19",
      "Preg 20+",
      "Lactating",

      "0-5 Exclusive",
      "0-5 Mixed",
      "0-5 Bottle-fed",
      "6-12 Complementary",


      "Sev UW",
      "UW",
      "Normal",
      "Sev W",
      "W",
      "OW",
      "Obese",
      "Sev St",
      "St",

      "Toilet",
      "Not Shared", 
      "Garbage",
      "Water",
      "Food",
      "Dwelling",

      "Salt",
    ];

    List<TableRow> rows = [];

    rows.add(
      TableRow(
        decoration: const BoxDecoration(color: Colors.grey),
        children: headers
            .map((h) => Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    h,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ))
            .toList(),
      ),
    );

    if (filtered.isEmpty) {
      rows.add(TableRow(
        children: List.generate(
          headers.length,
          (_) => const Padding(
            padding: EdgeInsets.all(6),
            child: Text("-"),
          ),
        ),
      ));
      return rows;
    }

    for (int i = 0; i < filtered.length; i++) {
      final h = filtered[i];

      rows.add(TableRow(children: [
        _cell("${h.householdNo}"),
        _cell(h.zone ?? "-"),
        _cell(h.fatherName ?? "-"),
        _cell(h.fatherOccupation ?? "-"),
        _cell(h.fatherEducation ?? "-"),
        _cell(h.motherName ?? "-"),
        _cell(h.motherOccupation ?? "-"),
        _cell(h.motherEducation ?? "-"),
        _cell("${h.male ?? 0}"),
        _cell("${h.female ?? 0}"),
        _cell("${h.total ?? 0}"),
        _cell("${h.families ?? 0}"),
        _cell("${h.fullyImmunized ?? 0}"),

        // ✅ CHANGED HERE ONLY
        _cell(_yesNo(h.fourPs)),
        _cell(_yesNo(h.indigenousPeople)),

        _cell("${h.infant0to5 ?? 0}"),
        _cell("${h.infant6to11 ?? 0}"),
        _cell("${h.child12to23 ?? 0}"),
        _cell("${h.child24to59 ?? 0}"),
        _cell("${h.age5to9 ?? 0}"),
        _cell("${h.age10to19 ?? 0}"),
        _cell("${h.age20to59 ?? 0}"),
        _cell("${h.age60above ?? 0}"),
        _cell("${h.pwd ?? 0}"),

        _cell("${h.preg19 ?? 0}"),
        _cell("${h.preg20 ?? 0}"),
        _cell("${h.lactating ?? 0}"),


        _cell("${h.exclusive ?? 0}"),
        _cell("${h.mixed ?? 0}"),
        _cell("${h.bottleFed ?? 0}"),
        _cell("${h.complementary ?? 0}"),


        _cell("${h.severelyUnderweight ?? 0}"),
        _cell("${h.underweight ?? 0}"),
        _cell("${h.normal ?? 0}"),
        _cell("${h.severelyWasted ?? 0}"),
        _cell("${h.wasted ?? 0}"),
        _cell("${h.overweight ?? 0}"),
        _cell("${h.obese ?? 0}"),
        _cell("${h.severelyStunted ?? 0}"),
        _cell("${h.stunted ?? 0}"),


        _cell(h.toilet ?? "-"),
        _cell(_yesNo(h.shared)),
        _cell(h.garbage ?? "-"),
        _cell(h.water ?? "-"),
        _cell(h.food ?? "-"),
        _cell(h.dwellingType ?? "-"),
        

        // ✅ CHANGED HERE ONLY
        _cell(_yesNo(h.iodizedSalt)),
      ]));
    }

    return rows;
  }

  Widget _cell(String value) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(value, textAlign: TextAlign.center),
    );
  }
} 