import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/household.dart';

class ExportExcelService {
  static Future<String> generate(List<Household> households) async {
    final excel = Excel.createExcel();
    final sheet = excel['Family Profile'];

    // ✅ HEADER ROW
    sheet.appendRow([
      TextCellValue("Barangay"),
      TextCellValue("Male"),
      TextCellValue("Female"),
      TextCellValue("Families"),
      TextCellValue("4Ps"),
      TextCellValue("Indigenous"),
      TextCellValue("Iodized Salt"),
      TextCellValue("PWD"),
      TextCellValue("Toilet"),
      TextCellValue("Garbage"),
      TextCellValue("Water"),
      TextCellValue("Food"),
      TextCellValue("Dwelling Type"),
    ]);

    // ✅ DATA ROWS
    for (var h in households) {
      sheet.appendRow([
        TextCellValue(h.barangay ?? ''),
        IntCellValue(h.male ?? 0),
        IntCellValue(h.female ?? 0),
        IntCellValue(h.families ?? 0),
        IntCellValue(h.fourPs),
        IntCellValue(h.indigenousPeople),
        IntCellValue(h.iodizedSalt),
        IntCellValue(h.pwd ?? 0),
        TextCellValue(h.toilet ?? ''),
        TextCellValue(h.garbage ?? ''),
        TextCellValue(h.water ?? ''),
        TextCellValue(h.food ?? ''),
        TextCellValue(h.dwellingType ?? ''),
      ]);
    }

    // ✅ SAVE FILE
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/family_profile_report.xlsx");

    await file.writeAsBytes(excel.encode()!);

    return file.path;
  }
}