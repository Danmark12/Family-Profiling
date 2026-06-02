import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import '../../models/household.dart';

class ExportBarangayCSV {
  static Future<void> generate({
    required List<Household> data,
    required String barangay,
    required String zone,
  }) async {
    // Check if there's data to export
    if (data.isEmpty) {
      throw Exception('No data to export');
    }

    // YES/NO FORMAT
    String yesNo(dynamic value) {
      return (value == 1) ? "Y" : "N";
    }

    List<List<dynamic>> rows = [];

    // =========================
    // HEADER INFORMATION (Optional metadata)
    // =========================
      rows.add(["Family Profile"]);
    rows.add(["Barangay: $barangay"]);
    // rows.add(["Zone: ${zone == "All" ? "All Zones" : zone}"]);
    // rows.add(["Generated: ${DateTime.now().toString()}"]);
    rows.add([]); // Empty row for spacing

    // =========================
    // MAIN HEADERS (Single row - matches table display)
    // =========================
    rows.add([
      "HH No.",
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
      "Salt"
    ]);

    // =========================
    // DATA ROWS (Matches exactly what's displayed in the table)
    // =========================
    for (var h in data) {
      rows.add([
        h.householdNo.toString(),
        h.zone ?? "-",
        h.fatherName ?? "-",
        h.fatherOccupation ?? "-",
        h.fatherEducation ?? "-",
        h.motherName ?? "-",
        h.motherOccupation ?? "-",
        h.motherEducation ?? "-",
        h.male?.toString() ?? "0",
        h.female?.toString() ?? "0",
        h.total?.toString() ?? "0",
        h.families?.toString() ?? "0",
        h.fullyImmunized?.toString() ?? "0",
        yesNo(h.fourPs),
        yesNo(h.indigenousPeople),
        h.infant0to5?.toString() ?? "0",
        h.infant6to11?.toString() ?? "0",
        h.child12to23?.toString() ?? "0",
        h.child24to59?.toString() ?? "0",
        h.age5to9?.toString() ?? "0",
        h.age10to19?.toString() ?? "0",
        h.age20to59?.toString() ?? "0",
        h.age60above?.toString() ?? "0",
        h.pwd?.toString() ?? "0",
        h.preg19?.toString() ?? "0",
        h.preg20?.toString() ?? "0",
        h.lactating?.toString() ?? "0",
        h.exclusive?.toString() ?? "0",
        h.mixed?.toString() ?? "0",
        h.bottleFed?.toString() ?? "0",
        h.complementary?.toString() ?? "0",
        h.severelyUnderweight?.toString() ?? "0",
        h.underweight?.toString() ?? "0",
        h.normal?.toString() ?? "0",
        h.severelyWasted?.toString() ?? "0",
        h.wasted?.toString() ?? "0",
        h.overweight?.toString() ?? "0",
        h.obese?.toString() ?? "0",
        h.severelyStunted?.toString() ?? "0",
        h.stunted?.toString() ?? "0",
        h.toilet ?? "-",
        yesNo(h.shared),  
        h.garbage ?? "-",
        h.water ?? "-",
        h.food ?? "-",
        h.dwellingType ?? "-",
        yesNo(h.iodizedSalt),
      ]);
    }

    // Add summary row at the bottom (optional)
    rows.add([]); // Empty row
    // rows.add(["Total Households: ${data.length}"]);
    
    // // Calculate totals for numeric fields
    // int totalPopulation = data.fold(0, (sum, h) => sum + (h.total ?? 0));
    // int totalFourPs = data.where((h) => h.fourPs == 1).length;
    // int totalIndigenous = data.where((h) => h.indigenousPeople == 1).length;
    
    // rows.add(["Total Population: $totalPopulation"]);
    // rows.add(["Total 4Ps Beneficiaries: $totalFourPs"]);
    // rows.add(["Total Indigenous People: $totalIndigenous"]);

    rows.add(["Date ${DateTime.now().toString()}"]);

    // =========================
    // EXPORT FILE
    // =========================
    try {
      final csv = const ListToCsvConverter().convert(rows);
      
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = "Barangay_${barangay}_Zone_${zone}_$timestamp.csv";
      
      final file = File("${dir.path}/$fileName");
      await file.writeAsString(csv);
      
      // Save file with dialog
      await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          sourceFilePath: file.path,
          fileName: fileName,
        ),
      );
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }
}