import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/household.dart';

class ExportCsvService {
  static Future<String> generate(List<Household> households) async {
    List<List<dynamic>> rows = [];

    // ✅ HEADER
    rows.add([
      "Barangay",
      "Male",
      "Female",
      "Families",
      "4Ps",
      "Indigenous",
      "Iodized Salt",
      "PWD",
      "Toilet",
      "Garbage",
      "Water",
      "Food",
      "Dwelling Type",
    ]);

    // ✅ DATA
    for (var h in households) {
      rows.add([
        h.barangay ?? '',
        h.male ?? 0,
        h.female ?? 0,
        h.families ?? 0,
        h.fourPs,
        h.indigenousPeople,
        h.iodizedSalt,
        h.pwd ?? 0,
        h.toilet ?? '',
        h.garbage ?? '',
        h.water ?? '',
        h.food ?? '',
        h.dwellingType ?? '',
      ]);
    }

    // ✅ CONVERT TO CSV STRING
    final csvData = const ListToCsvConverter().convert(rows);

    // ✅ SAVE FILE
    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      "${directory.path}/family_profile_export.csv",
    );

    await file.writeAsString(csvData);

    return file.path;
  }
}