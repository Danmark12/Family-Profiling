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
required bool sortAsc,

    required String generatedDate,
    required String generatedTime,
    
  }) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(8),

        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              "Date: $generatedDate | $generatedTime",
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            ),
          );
        },

        build: (context) => [

          // ================= HEADER =================
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
              // pw.Text("Zone: $zone",
              //     style: const pw.TextStyle(fontSize: 9)),

    //               pw.Text(
    //   sortAsc
    //       ? "Sort: Ascending (1 → 10)"
    //       : "Sort: Descending (10 → 1)",
    //   style: const pw.TextStyle(fontSize: 9),
    // ),

            ],
          ),

          pw.SizedBox(height: 6),

          // ================= TABLE =================
          pw.Table(
            border: pw.TableBorder.all(width: 0.4),
            children: [

              // ===== GROUP HEADER =====
              pw.TableRow(
                children: [

                  _groupCell(""), pw.SizedBox(),

                  _groupCell(""), pw.SizedBox(), pw.SizedBox(),

                  _groupCell(""), pw.SizedBox(), pw.SizedBox(),

                  _groupCell(""),
                  pw.SizedBox(), pw.SizedBox(), pw.SizedBox(), pw.SizedBox(),

                  _groupCell(""), pw.SizedBox(),

                  _groupCell("Age Group"),
                  pw.SizedBox(), pw.SizedBox(), pw.SizedBox(),
 
                  _groupCell(""),
                  pw.SizedBox(), pw.SizedBox(), pw.SizedBox(), pw.SizedBox(),

                  _groupCell("Women"), pw.SizedBox(), pw.SizedBox(),

                  _groupCell("IYCF"),
                  pw.SizedBox(), pw.SizedBox(), pw.SizedBox(),


                  _groupCell("Nutrition"),
                  pw.SizedBox(), pw.SizedBox(), pw.SizedBox(), pw.SizedBox(),
                  pw.SizedBox(), pw.SizedBox(), pw.SizedBox(), pw.SizedBox(),

                  _groupCell("Facilities"),
                  pw.SizedBox(), pw.SizedBox(), pw.SizedBox(), pw.SizedBox(),pw.SizedBox(),

                  _groupCell(""),
                ],
              ),

              // ===== COLUMN HEADER =====
              pw.TableRow(
                children: [
                  "H","Z",
                  "F","FO","FE",
                  "M","MO","ME",
                  "M","F","T","Fa","FI",

                  "4Ps","IP",

                  "0-5","6-11","12-23","24-59",

                  "5-9","10-19","20-59","60+",

                  "P19","P20","L",

                  "E","M","B","C",


                  "PWD","SUW","UW","N","SW","W","OW","O","SS","S",

                  "T","NS","G","W","F","D",

                  "St",
                ].map((text) => _headerCell(text)).toList(),
              ),

              // ===== DATA =====
              ...data.map((h) {
                return pw.TableRow(
                  children: [

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
                    "${h.fullyImmunized ?? 0}",

                    _yesNo(h.fourPs),
                    _yesNo(h.indigenousPeople),

                    "${h.infant0to5 ?? 0}",
                    "${h.infant6to11 ?? 0}",
                    "${h.child12to23 ?? 0}",
                    "${h.child24to59 ?? 0}",

                    "${h.age5to9 ?? 0}",
                    "${h.age10to19 ?? 0}",
                    "${h.age20to59 ?? 0}",
                    "${h.age60above ?? 0}",

                    "${h.preg19 ?? 0}",
                    "${h.preg20 ?? 0}",
                    "${h.lactating ?? 0}",

                    "${h.exclusive ?? 0}",
                    "${h.mixed ?? 0}",
                    "${h.bottleFed ?? 0}",
                    "${h.complementary ?? 0}",

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
                    _yesNo(h.shared), 
                    h.garbage ?? "",
                    h.water ?? "",
                    h.food ?? "",
                    h.dwellingType ?? "",

                    _yesNo(h.iodizedSalt),
                  ].map((e) => _cell(e)).toList(),
                );
              }),

            ],
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
                "H = Household Number",
                "Z = Zone / Purok",
                "4Ps = Pantawid Pamilyang Pilipino Program",
                "IP = Indigenous People",
              ])),

              pw.Expanded(child: _groupText("HOUSEHOLD MEMBERS", [
                "M = Male",
                "F = Female",
                "T = Total Members",
                "Fa = Number of Families",
                "FI = fully immunized children",
              ])),

              pw.Expanded(child: _groupText("IYCF", [
                "E = 0-5 months Exclusively Breastfed",
                "M = 0-5 months Mixed Feeding",
                "B = 0-5 months Bottle Fed",
                "C = 6-12 months Complementary Feeding",
              ])),

              pw.Expanded(child: _groupText("WOMEN STATUS", [
                "P19 = Pregnant 19 years old and below",
                "P20 = Pregnant 20 years old and above",
                "L = Lactating Women",
              ])),

              pw.Expanded(child: _groupText("AGE GROUP", [
                "0-5 Infants months old ",
                "6-11 Infants months old",
                "12-23 Preschool months old",
                "24-59 Preschool months old",
              ])),

              pw.Expanded(child: _groupText("", [
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
                "O = Obese",
                "SS = Severely Stunted",
                "S = Stunted",
              ])),

pw.Expanded(child: _groupText("TOILET TYPE Facility", [
  "Pour/flush type with septic tank",
  "Ventilated Pit (VIP) Latrine",
  "Water sealed toilet w/o septic tank",
  "Over hung Latrine",
  "Open Pit Latrine",
  "Without Toilet",
])),

pw.Expanded(child: _groupText("NOT SHARED TOILET", [
  // "Shared = Yes (1)",
  // "Not Shared = No (0)",
])),

pw.Expanded(child: _groupText("WASTE MANAGEMENT", [
  "Waste Segregation",
  "Backyard Composting",
  "Recycling/Reuse",
  "Collected by City/Municipal Collection",
  "Burning/Burying",
])),

pw.Expanded(child: _groupText("WATER SUPPLY & FOOD", [
  "Level I (point source)",
  "Level II (communal faucet)",
  "Level III (individual connection)",
  "Others, specify (doubtful sources)",
  "Vegetable Garden",
  "Poultry",
  "Livestock",
  "Fishpond",
  "No Garden",
])),

              pw.Expanded(child: _groupText("DWELLING & OTHER", [
                "Semi Concrete",
                "Wooden House",
                "Nipa Bamboo House",
                "Barong-Barong",
                "Makeshift",
                "St = Households using Iodized Salt",
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

  // ================= HELPERS =================
  static pw.Widget _groupCell(String text) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(2),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _headerCell(String text) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(2),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 5, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 5)),
    );
  }

  static pw.Widget _groupText(String title, List<String> items) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(right: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          ...items.map((e) =>
              pw.Text(e, style: const pw.TextStyle(fontSize: 5))),
        ],
      ),
    );
  }
}