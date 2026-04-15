import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/household.dart';

class ExportBarangayPDF {

    static String _yesNo(dynamic value) {
    return (value == 1) ? "Y" : "N";
  }

  static Future<void> generate({
    required List<Household> data,
    required String barangay,
    required String zone,

    // ✅ ADDED DATE & TIME
    required String generatedDate,
    required String generatedTime,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(8),

        // ✅ FOOTER (BOTTOM OF EVERY PAGE)
        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              "Date: $generatedDate | $generatedTime ()",
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey,
              ),
            ),
          );
        },

        build: (context) => [

          // ========================= HEADER =========================
          pw.Center(
            child: pw.Text(
              "FAMILY PROFILING FORM",
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 6),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Barangay: $barangay",
                  style: const pw.TextStyle(fontSize: 9)),
              pw.Text("Zone: $zone",
                  style: const pw.TextStyle(fontSize: 9)),
            ],
          ),

          pw.SizedBox(height: 4),

          // // ✅ DATE + TIME (HEADER PART)
          // pw.Row(
          //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //   children: [
          //     pw.Text("Date: $generatedDate",
          //         style: const pw.TextStyle(fontSize: 8)),
          //     pw.Text("Time: $generatedTime",
          //         style: const pw.TextStyle(fontSize: 8)),
          //   ],
          // ),

          // pw.SizedBox(height: 6),

          // ========================= TABLE =========================
          pw.Table.fromTextArray(
            border: pw.TableBorder.all(width: 0.4),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 5,
            ),
            cellStyle: const pw.TextStyle(fontSize: 5),

            headers: [
              "HH","Z",
              "Father","FOcc","FEdu",
              "Mother","MOcc","MEdu",
              "M","F","T","Fam",
              "4Ps","IP",
              "P19","P20","Lac",
              "Ex","Mix","Bot","Comp",
              "0-5","6-11","12-23","24-59",
              "5-9","10-19","20-59","60+",
              "PWD","SUW","UW","Norm","SW","W","OW","Ob","SS","St",
              "Toi","Gar","Wat","Food","Dw",
              "Salt",
            ],

            data: List.generate(data.length, (i) {
              final h = data[i];

              return [
              "${h.householdNo}",
                h.zone ?? "",

                h.fatherName ?? "",
                h.fatherOccupation ?? "",
                h.fatherEducation ?? "",

                h.motherName ?? "",
                h.motherOccupation ?? "",
                h.motherEducation ?? "",

                "${h.male ?? 0}",
                "${h.female ?? 0}",
                "${h.total ?? 0}",
                "${h.families ?? 0}",

                _yesNo(h.fourPs),
                _yesNo(h.indigenousPeople),

                "${h.preg19 ?? 0}",
                "${h.preg20 ?? 0}",
                "${h.lactating ?? 0}",

                "${h.exclusive ?? 0}",
                "${h.mixed ?? 0}",
                "${h.bottleFed ?? 0}",
                "${h.complementary ?? 0}",

                "${h.infant0to5 ?? 0}",
                "${h.infant6to11 ?? 0}",
                "${h.child12to23 ?? 0}",
                "${h.child24to59 ?? 0}",
                "${h.age5to9 ?? 0}",
                "${h.age10to19 ?? 0}",
                "${h.age20to59 ?? 0}",
                "${h.age60above ?? 0}",

                "${h.pwd ?? 0}",
                "${h.severelyUnderweight ?? 0}",
                "${h.underweight ?? 0}",
                "${h.normal ?? 0}",
                "${h.severelyWasted ?? 0}",
                "${h.wasted ?? 0}",
                "${h.overweight ?? 0}",
                "${h.obese ?? 0}",
                "${h.severelyStunted ?? 0}",
                "${h.stunted ?? 0}",

                h.toilet ?? "",
                h.garbage ?? "",
                h.water ?? "",
                h.food ?? "",
                h.dwellingType ?? "",

                _yesNo(h.iodizedSalt),
              ];
            }),
          ),

          pw.SizedBox(height: 10),

          // ========================= LEGEND =========================
          pw.Text(
            "ACRONYMS / LEGEND",
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 5),

          // -------- ROW 1 --------
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Expanded(child: _groupText("HOUSEHOLD INFORMATION", [
                "HH = Household Number",
                "Z = Zone / Purok",
                "4Ps = Pantawid Pamilyang Pilipino Program",
                "IP = Indigenous People",
              ])),

              pw.Expanded(child: _groupText("HOUSEHOLD MEMBERS", [
                "M = Male",
                "F = Female",
                "T = Total Members",
                "Fam = Number of Families",
              ])),

              pw.Expanded(child: _groupText("IYCF", [
                "Ex = 0-5 months Exclusively Breastfed",
                "Mix = 0-5 months Mixed Feeding",
                "Bot = 0-5 months Bottle Fed",
                "Comp = 6-12 months Complementary Feeding",
              ])),

              pw.Expanded(child: _groupText("WOMEN STATUS", [
                "P19 = Pregnant 19 years old and below",
                "P20 = Pregnant 20 years old and above",
                "Lac = Lactating Women",
              ])),

              pw.Expanded(child: _groupText("AGE GROUP (INFANTS)", [
                "0-5 months old",
                "6-11 months old",
                "12-23 months old",
                "24-59 months old",
              ])),

              pw.Expanded(child: _groupText("AGE GROUP (OTHERS)", [
                "5-9 years old",
                "10-19 years old",
                "20-59 years old",
                "60 years old and above",
                "PWD = Person with Disability",
              ])),
            ],
          ),

          pw.SizedBox(height: 6),

          // -------- ROW 2 --------
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Expanded(child: _groupText("NUTRITION STATUS", [
                "SUW = Severely Underweight",
                "UW = Underweight",
                "Norm = Normal Weight",
                "SW = Severely Wasted",
                "W = Wasted",
              ])),

              pw.Expanded(child: _groupText("", [
                "OW = Overweight",
                "Ob = Obese",
                "SS = Severely Stunted",
                "St = Stunted",
              ])),

              pw.Expanded(child: _groupText("TOILET TYPE", [
                "Water Sealed",
                "Antipolo (Unsanitary Toilet)",
                "Open Pit",
                "Shared",
                "No Toilet",
              ])),

              pw.Expanded(child: _groupText("GARBAGE DISPOSAL", [
                "Barangay/City Garbage Collector",
                "Own Compost Pit",
                "Burning",
                "Dumping",
              ])),

              pw.Expanded(child: _groupText("WATER & FOOD", [
                "Pipe Water (Faucet)",
                "Deep Well with other source",
                "Purified Water",
                "Open Shallow Dug Well",
                "Artesian Well",
                "Spring",
                "Vegetable Garden",
                "Poultry/Livestock",
                "Fishpond",
                "No Garden",
              ])),

              pw.Expanded(child: _groupText("DWELLING & OTHER", [
                "Semi Concrete",
                "Wooden House",
                "Nipa Bamboo House",
                "Barong-Barong",
                "Makeshift",
                "Salt = Households using Iodized Salt",
              ])),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
  format: PdfPageFormat.a4.landscape,
  onLayout: (format) async => pdf.save(),
        );
  }

  static pw.Widget _groupText(String title, List<String> items) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(right: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 6.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 2),
          ...items.map(
            (e) => pw.Text(
              e,
              style: const pw.TextStyle(fontSize: 5),
            ),
          ),
        ],
      ),
    );
  }
}