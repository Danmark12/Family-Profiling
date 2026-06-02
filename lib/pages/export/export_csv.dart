import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import '../../models/household.dart';

class ExportCsvService {
  static Future<void> generate({
    required List<Household> households,
    required String barangay,
    required String zone,
  }) async {

    // =========================
    // TOTAL COMPUTATION (same logic as PDF)
    // =========================
    int totalHouseholds = households.length;
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
    Map<String, int> sharedToiletCounts = {};
    Map<String, int> garbageCounts = {};
    Map<String, int> waterCounts = {};
    Map<String, int> foodCounts = {};
    Map<String, int> dwellingCounts = {};

    void count(Map<String, int> map, String? key) {
      if (key == null) return;
      map[key] = (map[key] ?? 0) + 1;
    }

    void countMulti(Map<String, int> map, String? raw) {
      if (raw == null || raw.isEmpty) return;

      final items = raw.split(",").map((e) => e.trim());

      for (final item in items) {
        if (item.isEmpty) continue;
        map[item] = (map[item] ?? 0) + 1;
      }
    }

    for (var h in households) {
      int members = (h.male ?? 0) + (h.female ?? 0);

      totalMale += h.male ?? 0;
      totalFemale += h.female ?? 0;
      totalMembers += members;
      totalFamilies += h.families ?? 0;
      totalFullyImmunized += h.fullyImmunized ?? 0;

      if (members <= 5) totalHHLess5++;
      else totalHHMore5++;

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

      count(toiletCounts, h.toilet);
      countMulti(garbageCounts, h.garbage);
      count(waterCounts, h.water);
      countMulti(foodCounts, h.food);
      count(dwellingCounts, h.dwellingType);
      count(sharedToiletCounts, h.shared == 1 ? "Shared" : "Not Shared");
    }

    // =========================
    // 2-COLUMN CSV FORMAT
    // =========================
    List<List<dynamic>> rows = [];

    rows.add(["Family Profile", ""]);
    rows.add(["Barangay", barangay]);
    rows.add(["Indicator", "Number"]);

    rows.add(["Total households", totalHouseholds]);
    rows.add(["Total number of members", totalMembers]);
    rows.add(["Male", totalMale]);
    rows.add(["Female", totalFemale]);
    rows.add(["Total number of family", totalFamilies]);
    rows.add(["Total number of HHs less than 5 members", totalHHLess5]);
    rows.add(["Total number of HHs more than 5 members", totalHHMore5]);
    rows.add(["Total number of fully immunized children", totalFullyImmunized]);
    rows.add(["Total number of 4Ps", totalFourPs]);
    rows.add(["Total number of IPs", totalIndigenous]);

    rows.add(["Age Group", ""]);
    rows.add(["Total number of infants 0-5 months old", totalInfant0to5]);
    rows.add(["Total number of infants 6-11 months old", totalInfant6to11]);
    rows.add(["Total number of children 12-23 months old", totalChild12to23]);
    rows.add(["Total number of children 24-59 months old", totalChild24to59]);
    rows.add(["Total number of age 5-9 years old", totalAge5to9]);
    rows.add(["Total number of age 10-19 years old", totalAge10to19]);
    rows.add(["Total number of age 20-59 years old", totalAge20to59]);
    rows.add(["Total number of age 60 and above", totalAge60above]);
    rows.add(["Total number of PWD", totalPWD]);

    rows.add(["Total number of women who are:", ""]);
    rows.add(["Pregnant 19 below", totalPreg19]);
    rows.add(["Pregnant 20 above", totalPreg20]);
    rows.add(["Lactating", totalLactating]);

    rows.add(["Infant and young child feeding (IYCF):", ""]);
    rows.add(["Total number of 0-5 months exclusively breastfed", totalExclusive]);
    rows.add(["Total number of 0 - 5 months mixed fed", totalMixed]);
    rows.add(["Total number of 0 - 5 bottle fed", totalBottleFed]);
    rows.add(["Total number of 6-12 given complementary fed", totalComplementary]);

    rows.add(["Total number of preschool children who are:", ""]);
    rows.add(["Severely underweight", totalSU]);
    rows.add(["Underweight", totalUW]);
    rows.add(["Normal", totalNW]);
    rows.add(["Severely wasted", totalSW]);
    rows.add(["Wasted", totalW]);
    rows.add(["Overweight", totalOW]);
    rows.add(["Obese", totalOB]);
    rows.add(["Severely stunted", totalSS]);
    rows.add(["Stunted", totalST]);

    // TOILET DISPOSAL SECTION
    rows.add(["Households, by type of toilet facility:", ""]);
    rows.add(["Pour/flush type with septic tank", toiletCounts['Pour/flush type with septic tank'] ?? 0]);
    rows.add(["Ventilated Pit (VIP) Latrine", toiletCounts['Ventilated Pit (VIP) Lactrine'] ?? 0]);
    rows.add(["Water sealed toilet w/o septic tank", toiletCounts['Water sealed toilet w/o septic tank'] ?? 0]);
    rows.add(["Over hung Latrine", toiletCounts['Over hung Latrine'] ?? 0]);
    rows.add(["Open Pit Latrine", toiletCounts['Open Pit Latrine'] ?? 0]);
    rows.add(["Without Toilet", toiletCounts['Without Toilet'] ?? 0]);

    // SHARED TOILET SECTION
    rows.add(["Shared Toilet Status:", ""]);
    rows.add(["Shared Toilet", sharedToiletCounts['Shared'] ?? 0]);
    rows.add(["Not Shared Toilet", sharedToiletCounts['Not Shared'] ?? 0]);

    // WASTE MANAGEMENT SECTION
    rows.add(["Households, by type of waste management:", ""]);
    rows.add(["Waste Segregation", garbageCounts['Waste Segregation'] ?? 0]);
    rows.add(["Backyard Composting", garbageCounts['Backyard Composting'] ?? 0]);
    rows.add(["Recycling/Reuse", garbageCounts['Recycling Reuse'] ?? 0]);
    rows.add(["Collected by City/Municipal Collection", garbageCounts['Collected by City/Municipal Collection and Disposal System'] ?? 0]);
    rows.add(["Burning/Burying", garbageCounts['Burning/Burying'] ?? 0]);

    // WATER SOURCE SECTION
    rows.add(["Households, by type of water supply:", ""]);
    rows.add(["Level I (point source)", waterCounts['Level I (point source)'] ?? 0]);
    rows.add(["Level II (communal faucet)", waterCounts['Level II (communal facet)'] ?? 0]);
    rows.add(["Level III (individual connection)", waterCounts['Level III (individual connection)'] ?? 0]);
    rows.add(["Others, specify (doubtful sources)", waterCounts['For doubtful sources, e.g. open dug well, etc.'] ?? 0]);

    // FOOD PRODUCTION SECTION
    rows.add(["Households, by type of food production activity:", ""]);
    rows.add(["Vegetable Garden", foodCounts['Vegetable Garden'] ?? 0]);
    rows.add(["Poultry", foodCounts['Poultry'] ?? 0]);
    rows.add(["Livestock", foodCounts['Livestock'] ?? 0]);
    rows.add(["Fishpond", foodCounts['Fishpond'] ?? 0]);
    rows.add(["No Garden", foodCounts['No Garden'] ?? 0]);

    // DWELLING TYPE SECTION
    rows.add(["Households, according to type of dwelling unit:", ""]);
    rows.add(["Concrete", dwellingCounts['Concrete'] ?? 0]);
    rows.add(["Semi Concrete", dwellingCounts['Semi Concrete'] ?? 0]);
    rows.add(["Wooden", dwellingCounts['Wooden'] ?? 0]);
    rows.add(["Nipa Bamboo House", dwellingCounts['Nipa Bamboo House'] ?? 0]);
    rows.add(["Barong-Barong", dwellingCounts['Barong-Barong'] ?? 0]);
    rows.add(["Makeshift", dwellingCounts['Makeshift'] ?? 0]);

    rows.add(["Total number of households using iodized salt", totalIodizedSalt]);

    // =========================
    // EXPORT FILE
    // =========================
    final csvData = const ListToCsvConverter().convert(rows);

    final dir = await getTemporaryDirectory();

    final zoneText = zone == "All" ? "AllZones" : "Zone$zone";
    final file = File(
      "${dir.path}/Family_Profile_${barangay}_${zoneText}_${DateTime.now().millisecondsSinceEpoch}.csv",
    );

    await file.writeAsString(csvData);

    await FlutterFileDialog.saveFile(
      params: SaveFileDialogParams(
        sourceFilePath: file.path,
        fileName: "Family_Profile_${barangay}_${zoneText}.csv",
      ),
    );
  }
}