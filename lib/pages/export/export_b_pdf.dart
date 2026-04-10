import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/household.dart';

class ExportBarangayPDF {
  static Future<void> generate({
    required List<Household> data,
    required String barangay,
    required String zone,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(8),

        build: (context) => [

          // =========================
          // HEADER
          // =========================
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

          pw.SizedBox(height: 6),

          // =========================
          // TABLE
          // =========================
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
                "${i + 1}",
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

                "${h.fourPs ?? 0}",
                "${h.indigenousPeople ?? 0}",

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

                "${h.iodizedSalt ?? 0}",
              ];
            }),
          ),

          pw.SizedBox(height: 10),

          // =========================
          // ACRONYMS (NO BOXES, LANDSCAPE STYLE)
          // =========================
          pw.Text(
            "ACRONYMS / LEGEND",
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 5),

          pw.Wrap(
            spacing: 18,
            runSpacing: 6,
            children: [

              _groupText("HOUSEHOLD", [
                "HH = Household No",
                "Z = Zone/Purok",
                "4Ps = Pantawid Program",
                "IP = Indigenous People",
              ]),

              _groupText("MEMBERS", [
                "M = Male",
                "F = Female",
                "T = Total",
                "Fam = Families",
              ]),

              _groupText("IYCF", [
                "Ex = Exclusive BF",
                "Mix = Mixed Feeding",
                "Bot = Bottle Feeding",
                "Comp = Complementary Feeding",
              ]),

              _groupText("WOMEN", [
                "P19 = Pregnant <19",
                "P20 = Pregnant 20+",
                "Lac = Lactating Women",
              ]),

              _groupText("AGE GROUP", [
                "0-5 = 0-5 months",
                "6-11 = 6-11 months",
                "12-23 = 12-23 months",
                "24-59 = 24-59 months",
                "5-9 = 5-9 years",
                "10-19 = 10-19 years",
                "20-59 = 20-59 years",
                "60+ = 60+ years",
                "PWD = Persons with Disability",
              ]),

              _groupText("NUTRITION", [
                "SUW = Severely Underweight",
                "UW = Underweight",
                "Norm = Normal",
                "SW = Severely Wasted",
                "W = Wasted",
                "OW = Overweight",
                "Ob = Obese",
                "SS = Severely Stunted",
                "St = Stunted",
              ]),

              _groupText("FACILITIES", [

                // Toilet
                "Toi = Toilet Type",
                " - Water Sealed",
                " - Antipolo (Unsanitary)",
                " - Open Pit",
                " - Shared",
                " - No Toilet",

                // Garbage
                "Gar = Garbage Disposal",
                " - City Collector",
                " - Compost Pit",
                " - Burning",
                " - Dumping",

                // Water
                "Wat = Water Source",
                " - Pipe Water",
                " - Deep Well",
                " - Purified Water",
                " - Open Well",
                " - Artesian Well",
                " - Spring",

                // Food
                "Food = Food Production",
                " - Vegetable Garden",
                " - Poultry/Livestock",
                " - Fishpond",
                " - No Garden",

                // Dwelling
                "Dw = Dwelling Type",
                " - Semi Concrete",
                " - Wooden House",
                " - Nipa Bamboo",
                " - Barong-Barong",
                " - Makeshift",
              ]),

              _groupText("OTHER", [
                "Salt = Iodized Salt",
              ]),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  // =========================
  // SIMPLE TEXT GROUP (NO BOX)
  // =========================
  static pw.Widget _groupText(String title, List<String> items) {
    return pw.Container(
      width: 190,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 2),
          ...items.map(
            (e) => pw.Text(
              e,
              style: const pw.TextStyle(fontSize: 5.3),
            ),
          ),
        ],
      ),
    );
  }
}