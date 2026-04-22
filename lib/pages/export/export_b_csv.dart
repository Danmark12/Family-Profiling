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

    // ✅ YES/NO FORMAT
    String yesNo(dynamic value) {
      return (value == 1) ? "Y" : "N";
    }

    List<List<dynamic>> rows = [];

    // =========================
    // ROW 1 → TITLE
    // =========================
    rows.add(["","","","","","","","","","","","","","","","","","","","","","","Barangay Households"]);
    rows.add(["Barangay: $barangay",]);

    // =========================
    // ROW 2 → BARANGAY + ZONE
    // =========================
    rows.add(["","","","","","","","","","","","","","","","Age Group","","","","","","","","","Women Status","","","IYCF", "","","",
    "Preschool Children Nutritional Status","","","","","","","","","Facilities"]);

    // =========================
    // ROW 3 → HEADERS
    // =========================
    rows.add([
      "Houshold No.",
      "Zone",

      "Father Name",
      "Father Occupation",
      "Father Education",
      "Mother Name",
      "Mother Occupation",
      "Mother Education",

      "Male",
      "Female",
      "Total of members",
      "No. of families",
      "Fully Immunized child",

      "4Ps",
      "IPs",

      "0-5 months infants",
      "6-11 months infants",
      "12-23 preschool children ",
      "24-59 preschool children",
      "5-9 years old",
      "10-19 years old",
      "20-59 years old",
      "60+",
      "PWD",

      "Preg <19",
      "Preg 20+",
      "Lactating",

      "0-5 months exclusively breastfed",
      "0-5 months mixed fed",
      "0-5 months bottle fed",
      "6-12 given complementary fed",


      "Sev Underweight",
      "Underweight",
      "Normal",
      "Sev Wasted",
      "Wasted",
      "Overweight",
      "Obese",
      "Sev Stunted",
      "Stunted",

      "Toilet",
      "Garbage",
      "Water",
      "Food",
      "Dwelling",

      "Uses Iodized Salt",
    ]);

    // =========================
    // ROW 4+ → DATA
    // =========================
    for (var h in data) {
      rows.add([
        h.householdNo ?? "-",
        h.zone ?? "-",
        h.fatherName ?? "-",
        h.fatherOccupation ?? "-",
        h.fatherEducation ?? "-",
        h.motherName ?? "-",
        h.motherOccupation ?? "-",
        h.motherEducation ?? "-",
        h.male ?? 0,
        h.female ?? 0,
        h.total ?? 0,
        h.families ?? 0,
        h.fullyImmunized ?? 0,
        yesNo(h.fourPs),
        yesNo(h.indigenousPeople),

        h.infant0to5 ?? 0,
        h.infant6to11 ?? 0,
        h.child12to23 ?? 0,
        h.child24to59 ?? 0,
        h.age5to9 ?? 0,
        h.age10to19 ?? 0,
        h.age20to59 ?? 0,
        h.age60above ?? 0,
        h.pwd ?? 0,

        h.preg19 ?? 0,
        h.preg20 ?? 0,
        h.lactating ?? 0,


        h.exclusive ?? 0,
        h.mixed ?? 0,
        h.bottleFed ?? 0,
        h.complementary ?? 0,


        h.severelyUnderweight ?? 0,
        h.underweight ?? 0,
        h.normal ?? 0,
        h.severelyWasted ?? 0,
        h.wasted ?? 0,
        h.overweight ?? 0,
        h.obese ?? 0,
        h.severelyStunted ?? 0,
        h.stunted ?? 0,


        h.toilet ?? "-",
        h.garbage ?? "-",
        h.water ?? "-",
        h.food ?? "-",
        h.dwellingType ?? "-",

        yesNo(h.iodizedSalt),
      ]);
    }

    // =========================
    // EXPORT FILE
    // =========================
    final csv = const ListToCsvConverter().convert(rows);

    final dir = await getTemporaryDirectory();

    final file = File(
      "${dir.path}/Barangay_Table_${DateTime.now().millisecondsSinceEpoch}.csv",
    );

    await file.writeAsString(csv);

    await FlutterFileDialog.saveFile(
      params: SaveFileDialogParams(
        sourceFilePath: file.path,
        fileName: "Barangay_Household_Table.csv",
      ),
    );
  }
}