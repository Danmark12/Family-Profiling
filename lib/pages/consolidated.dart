// lib/pages/consolidated_report_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/config.dart';
import '../models/household.dart';
import 'package:printing/printing.dart';
import 'export/export_pdf.dart';
import 'package:intl/intl.dart';
import 'export/export_csv.dart';

class ConsolidatedReportPage extends StatefulWidget {
  const ConsolidatedReportPage({super.key});

  @override
  State<ConsolidatedReportPage> createState() => _ConsolidatedReportPageState();
}

class _ConsolidatedReportPageState extends State<ConsolidatedReportPage> {
  int? userId;
  String barangay = '';
  
  // Zone filter variables
  String selectedZone = "All";
  List<String> zones = ["All"];
  List<Household> allHouseholds = [];

  // Totals for display
  int totalHouseholds = 0;
  int totalMembers = 0;
  int totalMale = 0;
  int totalFemale = 0;
  int totalFamilies = 0;
  int totalFullyImmunized = 0;

  int totalHHLess5 = 0;
  int totalHHMore5 = 0;

  int totalFourPs = 0;
  int totalIndigenous = 0;
  int totalIodizedSalt = 0;

  int totalPreg19 = 0;
  int totalPreg20 = 0;
  int totalLactating = 0;

  int totalExclusive = 0;
  int totalMixed = 0;
  int totalBottleFed = 0;
  int totalComplementary = 0;

  int totalInfant0to5 = 0;
  int totalInfant6to11 = 0;
  int totalChild12to23 = 0;
  int totalChild24to59 = 0;
  int totalAge5to9 = 0;
  int totalAge10to19 = 0;
  int totalAge20to59 = 0;
  int totalAge60above = 0;
  int totalPWD = 0;

  int totalSU = 0, totalUW = 0, totalNW = 0;
  int totalSW = 0, totalW = 0, totalOW = 0, totalOB = 0;
  int totalSS = 0, totalST = 0;

  Map<String, int> toiletCounts = {};
  Map<String, int> garbageCounts = {};
  Map<String, int> waterCounts = {};
  Map<String, int> foodCounts = {};
  Map<String, int> dwellingCounts = {};
  Map<String, int> sharedToiletCounts = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void _count(Map<String, int> map, String? key) {
    if (key == null) return;
    map[key] = (map[key] ?? 0) + 1;
  }

  void _countMulti(Map<String, int> map, String? raw) {
    if (raw == null || raw.isEmpty) return;

    final items = raw.split(",").map((e) => e.trim()).toList();

    for (var item in items) {
      if (item.isEmpty) continue;
      map[item] = (map[item] ?? 0) + 1;
    }
  }

  // Calculate totals for a specific list of households
  void _calculateTotals(List<Household> households) {
    // Reset all totals
    totalHouseholds = households.length;
    totalMembers = 0;
    totalMale = 0;
    totalFemale = 0;
    totalFamilies = 0;
    totalFullyImmunized = 0;
    totalHHLess5 = 0;
    totalHHMore5 = 0;
    totalFourPs = 0;
    totalIndigenous = 0;
    totalIodizedSalt = 0;
    totalPreg19 = 0;
    totalPreg20 = 0;
    totalLactating = 0;
    totalExclusive = 0;
    totalMixed = 0;
    totalBottleFed = 0;
    totalComplementary = 0;
    totalInfant0to5 = 0;
    totalInfant6to11 = 0;
    totalChild12to23 = 0;
    totalChild24to59 = 0;
    totalAge5to9 = 0;
    totalAge10to19 = 0;
    totalAge20to59 = 0;
    totalAge60above = 0;
    totalPWD = 0;
    totalSU = 0;
    totalUW = 0;
    totalNW = 0;
    totalSW = 0;
    totalW = 0;
    totalOW = 0;
    totalOB = 0;
    totalSS = 0;
    totalST = 0;
    
    toiletCounts.clear();
    garbageCounts.clear();
    waterCounts.clear();
    foodCounts.clear();
    dwellingCounts.clear();
    sharedToiletCounts.clear();

    for (var h in households) {
      int members = (h.male ?? 0) + (h.female ?? 0);

      totalMale += h.male ?? 0;
      totalFemale += h.female ?? 0;
      totalMembers += members;
      totalFamilies += h.families ?? 0;
      totalFullyImmunized += h.fullyImmunized ?? 0;

      if (members <= 5) {
        totalHHLess5++;
      } else {
        totalHHMore5++;
      }

      totalFourPs += h.fourPs;
      totalIndigenous += h.indigenousPeople;
      totalIodizedSalt += h.iodizedSalt;

      totalPreg19 += h.preg19 ?? 0;
      totalPreg20 += h.preg20 ?? 0;
      totalLactating += h.lactating ?? 0;

      totalExclusive += h.exclusive ?? 0;
      totalMixed += h.mixed ?? 0;
      totalBottleFed += h.bottleFed ?? 0;
      totalComplementary += h.complementary ?? 0;

      totalInfant0to5 += h.infant0to5 ?? 0;
      totalInfant6to11 += h.infant6to11 ?? 0;
      totalChild12to23 += h.child12to23 ?? 0;
      totalChild24to59 += h.child24to59 ?? 0;
      totalAge5to9 += h.age5to9 ?? 0;
      totalAge10to19 += h.age10to19 ?? 0;
      totalAge20to59 += h.age20to59 ?? 0;
      totalAge60above += h.age60above ?? 0;
      totalPWD += h.pwd ?? 0;

      totalSU += h.severelyUnderweight ?? 0;
      totalUW += h.underweight ?? 0;
      totalNW += h.normal ?? 0;
      totalSW += h.severelyWasted ?? 0;
      totalW += h.wasted ?? 0;
      totalOW += h.overweight ?? 0;
      totalOB += h.obese ?? 0;
      totalSS += h.severelyStunted ?? 0;
      totalST += h.stunted ?? 0;

      _count(toiletCounts, h.toilet);
      _countMulti(garbageCounts, h.garbage);
      _count(waterCounts, h.water);
      _countMulti(foodCounts, h.food);
      _count(dwellingCounts, h.dwellingType);
      _count(sharedToiletCounts, h.shared == 1 ? "Shared" : "Not Shared");
    }

    setState(() {});
  }

  // Filter households by selected zone
  void _filterByZone() {
    if (selectedZone == "All") {
      _calculateTotals(allHouseholds);
    } else {
      final filtered = allHouseholds.where((h) => h.zone == selectedZone).toList();
      _calculateTotals(filtered);
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    if (userId == null) return;

    final data = await DBHelper.instance.getUserHouseholds(userId!);
    if (data.isEmpty) return;

    allHouseholds = data.map((e) => Household.fromMap(e)).toList();

    barangay = allHouseholds.first.barangay ?? '';
    
    // Extract unique zones
    final uniqueZones = allHouseholds
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
      zones = ["All", ...uniqueZones];
    });

    // Calculate initial totals
    _calculateTotals(allHouseholds);
  }

  String get(Map<String, int> map, String key) =>
      (map[key] ?? 0).toString();

  // Get filtered households for export
  List<Household> getFilteredHouseholdsForExport() {
    if (selectedZone == "All") {
      return allHouseholds;
    } else {
      return allHouseholds.where((h) => h.zone == selectedZone).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("FAMILY PROFILE"),
        actions: [
          // 📄 PDF EXPORT BUTTON
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: () async {
              if (userId == null) return;

              final households = getFilteredHouseholdsForExport();
              if (households.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No data to export for selected zone")),
                );
                return;
              }

              final now = DateTime.now().toUtc().add(const Duration(hours: 8));

              final generatedDate = DateFormat('MMMM dd, yyyy').format(now);
              final generatedTime = DateFormat('hh:mm a').format(now);

              await Printing.layoutPdf(
                onLayout: (format) async {
                  final pdfService = ExportPdfService(
                    households: households,
                    barangay: barangay,
                    zone: selectedZone,
                    generatedDate: generatedDate,
                    generatedTime: generatedTime,
                  );

                  return pdfService.generate();
                },
              );
            },
          ),

          // 📊 CSV EXPORT BUTTON
          IconButton(
            icon: const Icon(Icons.grid_on),
            tooltip: 'Export CSV',
            onPressed: () async {
              if (userId == null) return;

              final households = getFilteredHouseholdsForExport();
              if (households.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No data to export for selected zone")),
                );
                return;
              }

              await ExportCsvService.generate(
                households: households,
                barangay: barangay,
                zone: selectedZone,
              );

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("CSV exported successfully"),
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Card(
            elevation: 8,
            child: Container(
              width: 595,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "FAMILY PROFILE",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Row with Barangay and Zone Dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Barangay: $barangay"),
                      Row(
                        children: [
                          const Text("Zone: "),
                          Container(
                            height: 35,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color.fromARGB(255, 216, 216, 216)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedZone,
                                isDense: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedZone = value;
                                      _filterByZone();
                                    });
                                  }
                                },
                                items: zones.map((z) {
                                  return DropdownMenuItem(
                                    value: z,
                                    child: Text(
                                      z == "All" ? "All Zones" : "Zone $z",
                                      style: const TextStyle(fontSize: 12),
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
                  
                  const SizedBox(height: 10),

                  Table(
                    border: TableBorder.all(),
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(1),
                    },
                    children: [
                      _row("Indicator", "Number", true),

                      _row("Total households", "$totalHouseholds"),
                      _row("Total number of members", "$totalMembers"),
                      _row("Male", "$totalMale"),
                      _row("Female", "$totalFemale"),
                      _row("Total number of family", "$totalFamilies"),
                      
                      _row("Total number of HHs less than 5 members", "$totalHHLess5"),
                      _row("Total number of HHs more than 5 members", "$totalHHMore5"),
                      _row("Total number of fully immunized children", "$totalFullyImmunized"),
                      _row("Total number of 4Ps", "$totalFourPs"),
                      _row("Total number of IPs", "$totalIndigenous"),

                      _title("Age group:"),
                      _row("Total number of infants 0-5 months old", "$totalInfant0to5"),
                      _row("Total number of infants 6-11 months old", "$totalInfant6to11"),
                      _row("Total number of children 12-23 months old", "$totalChild12to23"),
                      _row("Total number of children 24-59 months old", "$totalChild24to59"),
                      _row("Total number of age 5-9 years old", "$totalAge5to9"),
                      _row("Total number of age 10-19 years old", "$totalAge10to19"),
                      _row("Total number of age 20-59 years old", "$totalAge20to59"),
                      _row("Total number of age 60 and above", "$totalAge60above"),
                      _row("Total number of PWD", "$totalPWD"),

                      _title("Total number of women who are:"),
                      _row("Pregnant 19 below", "$totalPreg19"),
                      _row("Pregnant 20 above", "$totalPreg20"),
                      _row("Lactating", "$totalLactating"),

                      _title("Infant and young child feeding (IYCF):"),
                      _row("Total number of 0-5 months exclusively breastfed", "$totalExclusive"),
                      _row("Total number of 0 - 5 months mixed fed", "$totalMixed"),
                      _row("Total number of 0 - 5 bottle fed", "$totalBottleFed"),
                      _row("Total number of 6-12 given complementary fed", "$totalComplementary"),

                      _title("Total number of preschool children who are:"),
                      _row("Severely underweight", "$totalSU"),
                      _row("Underweight", "$totalUW"),
                      _row("Normal weight", "$totalNW"),
                      _row("Severely wasted", "$totalSW"),
                      _row("wasted", "$totalW"),
                      _row("Overweight", "$totalOW"),
                      _row("Obese", "$totalOB"),
                      _row("Severely Stunted", "$totalSS"),
                      _row("Stunted", "$totalST"),

                      _title("Households, by type of toilet facility:"),
                      _row("Pour/flush type with septic tank", get(toiletCounts, "Pour/flush type with septic tank")),
                      _row("Ventilated Pit (VIP) Latrine", get(toiletCounts, "Ventilated Pit (VIP) Lactrine")),
                      _row("Water sealed toilet w/o septic tank", get(toiletCounts, "Water sealed toilet w/o septic tank")),
                      _row("Over hung Latrine", get(toiletCounts, "Over hung Latrine")),
                      _row("Open Pit Latrine", get(toiletCounts, "Open Pit Latrine")),
                      _row("Without Toilet", get(toiletCounts, "Without Toilet")),

                      _title("Shared Toilet Status:"),
                      _row("Shared Toilet", get(sharedToiletCounts, "Shared")),
                      _row("Not Shared Toilet", get(sharedToiletCounts, "Not Shared")),

                      _title("Households, by type of waste management:"),
                      _row("Waste Segregation", get(garbageCounts, "Waste Segregation")),
                      _row("Backyard Composting", get(garbageCounts, "Backyard Composting")),
                      _row("Recycling/Reuse", get(garbageCounts, "Recycling Reuse")),
                      _row("Collected by City/Municipal Collection", get(garbageCounts, "Collected by City/Municipal Collection and Disposal System")),
                      _row("Burning/Burying", get(garbageCounts, "Burning/Burying")),

                      _title("Households, by type of water supply:"),
                      _row("Level I (point source)", get(waterCounts, "Level I (point source)")),
                      _row("Level II (communal faucet)", get(waterCounts, "Level II (communal facet)")),
                      _row("Level III (individual connection)", get(waterCounts, "Level III (individual connection)")),
                      _row("Others, specify (doubtful sources)", get(waterCounts, "For doubtful sources, e.g. open dug well, etc.")),

                      _title("Households, by type of food production:"),
                      _row("Vegetable Garden", get(foodCounts, "Vegetable Garden")),
                      _row("Poultry", get(foodCounts, "Poultry")),
                      _row("Livestock", get(foodCounts, "Livestock")),
                      _row("Fishpond", get(foodCounts, "Fishpond")),
                      _row("No Garden", get(foodCounts, "No Garden")),

                      _title("Households, according to type of dwelling unit:"),
                      _row("Concrete", get(dwellingCounts, "Concrete")),
                      _row("Semi Concrete", get(dwellingCounts, "Semi Concrete")),
                      _row("Wooden", get(dwellingCounts, "Wooden")),
                      _row("Nipa Bamboo House", get(dwellingCounts, "Nipa Bamboo House")),
                      _row("Barong-Barong", get(dwellingCounts, "Barong-Barong")),
                      _row("Makeshift", get(dwellingCounts, "Makeshift")), 

                      _row("Total number of households using iodized salt", "$totalIodizedSalt"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TableRow _row(String a, String b, [bool header = false]) {
    return TableRow(
      decoration: header ? BoxDecoration(color: Colors.grey[300]) : null,
      children: [
        Padding(padding: const EdgeInsets.all(8), child: Text(a)),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(b, textAlign: TextAlign.center),
        ),
      ],
    );
  }

  TableRow _title(String t) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.normal)),
      ),
      const SizedBox(),
    ]);
  }
}