import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../../models/household.dart';

class ExportPdfService {
  final List<Household> households;
  final String barangay;
  final String zone;
  final String generatedDate;
  final String generatedTime;

  ExportPdfService({
    required this.households,
    required this.barangay,
    required this.zone,
    required this.generatedDate,
    required this.generatedTime,
  });

  Future<Uint8List> generate() async {
    final pdf = pw.Document();

    int totalHouseholds = households.length;
    int totalMembers = 0;
    int totalMale = 0;
    int totalFemale = 0;
    int totalFamilies = 0;
    int totalHHLess5 = 0;
    int totalHHMore5 = 0;
    int totalFullyImmunized = 0;

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

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,

        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            padding: const pw.EdgeInsets.only(right: 10),
            child: pw.Text(
              'Date: $generatedDate | $generatedTime',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
            ),
          );  
        },

        build: (context) => [
          pw.Center(
            child: pw.Text(
              'FAMILY PROFILE',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Barangay: $barangay'), 
          pw.SizedBox(height: 5),

          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(1),
            },
            children: [
              // HEADER (ONLY ONCE)
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      'Indicator',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      'Number',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),

              // DATA ROWS
              _row('Total households', '$totalHouseholds'),
              _row('Total number of members', '$totalMembers'),
              _row('Male', '$totalMale'),
              _row('Female', '$totalFemale'),
              _row('Total number of family', '$totalFamilies'),
              _row('Total number of HHs less than 5 members', '$totalHHLess5'),
              _row('Total number of HHs more than 5 members', '$totalHHMore5'),
              _row("Total number of fully immunized children", "$totalFullyImmunized"),
              _row('Total number of 4Ps', '$totalFourPs'),
              _row('Total number of IPs', '$totalIndigenous'),

              _row('Age group:', ''),
              _row('Total number of infants 0-5 months old', '$totalInfant0to5'),
              _row('Total number of infants 6-11 months old', '$totalInfant6to11'),
              _row('Total number of children 12-23 months old', '$totalChild12to23'),
              _row('Total number of children 24-59 months old', '$totalChild24to59'),
              _row('Total number of age 5-9 years old', '$totalAge5to9'),
              _row('Total number of age 10-19 years old', '$totalAge10to19'),
              _row('Total number of age 20-59 years old', '$totalAge20to59'),
              _row('Total number of age 60 and above', '$totalAge60above'),
              _row('Total number of PWD', '$totalPWD'),

              _row('Total number of women who are:', ''),
              _row('Pregnant 19 below', '$totalPreg19'),
              _row('Pregnant 20 above', '$totalPreg20'),
              _row('Lactating', '$totalLactating'),

              _row('Infant and young child feeding (IYCF):', ''),
              _row('Total number of 0-5 months exclusively breastfed', '$totalExclusive'),
              _row('Total number of 0 - 5 months mixed fed', '$totalMixed'),
              _row('Total number of 0 - 5 bottle fed', '$totalBottleFed'),
              _row('Total number of 6-12 given complementary fed', '$totalComplementary'),

              _row('Total number of preschool children who are:', ''),
              _row('Severely underweight', '$totalSU'),
              _row('Underweight', '$totalUW'),
              _row('Normal weight', '$totalNW'),
              _row('Severely wasted', '$totalSW'),
              _row('wasted', '$totalW'),
              _row('Overweight', '$totalOW'),
              _row('Obese', '$totalOB'),
              _row('Severely Stunted', '$totalSS'),
              _row('Stunted', '$totalST'),

              // TOILET DISPOSAL SECTION
              _row('Households, by type of toilet facility:', ''),
              _row('Pour/flush type with septic tank', '${toiletCounts['Pour/flush type with septic tank'] ?? 0}'),
              _row('Ventilated Pit (VIP) Latrine', '${toiletCounts['Ventilated Pit (VIP) Lactrine'] ?? 0}'),
              _row('Water sealed toilet w/o septic tank', '${toiletCounts['Water sealed toilet w/o septic tank'] ?? 0}'),
              _row('Over hung Latrine', '${toiletCounts['Over hung Latrine'] ?? 0}'),
              _row('Open Pit Latrine', '${toiletCounts['Open Pit Latrine'] ?? 0}'),
              _row('Without Toilet', '${toiletCounts['Without Toilet'] ?? 0}'),

              // SHARED TOILET SECTION
              _row('Shared Toilet Status:', ''),
              _row('Shared Toilet', '${sharedToiletCounts['Shared'] ?? 0}'),
              _row('Not Shared Toilet', '${sharedToiletCounts['Not Shared'] ?? 0}'),

              // WASTE MANAGEMENT SECTION
              _row('Households, by type of waste management:', ''),
              _row('Waste Segregation', '${garbageCounts['Waste Segregation'] ?? 0}'),
              _row('Backyard Composting', '${garbageCounts['Backyard Composting'] ?? 0}'),
              _row('Recycling/Reuse', '${garbageCounts['Recycling Reuse'] ?? 0}'),
              _row('Collected by City/Municipal Collection', '${garbageCounts['Collected by City/Municipal Collection and Disposal System'] ?? 0}'),
              _row('Burning/Burying', '${garbageCounts['(Burning/Burying)(within hosuehold; not satisfactory method of disposal)'] ?? 0}'),

              // WATER SOURCE SECTION
              _row('Households, by type of water supply:', ''),
              _row('Level I (point source)', '${waterCounts['Level I (point source)'] ?? 0}'),
              _row('Level II (communal faucet)', '${waterCounts['Level II (communal facet)'] ?? 0}'),
              _row('Level III (individual connection)', '${waterCounts['Level III (individual connection)'] ?? 0}'),
              _row('Others, specify (doubtful sources)', '${waterCounts['Others, specify (for doubtful sources, e.g. open dug well, etc.)'] ?? 0}'),

              // FOOD PRODUCTION SECTION
              _row('Households, by type of food production activity:', ''),
              _row('Vegetable Garden', '${foodCounts['Vegetable Garden'] ?? 0}'),
              _row('Poultry', '${foodCounts['Poultry'] ?? 0}'),
              _row('Livestock', '${foodCounts['Livestock'] ?? 0}'),
              _row('Fishpond', '${foodCounts['Fishpond'] ?? 0}'),
              _row('No Garden', '${foodCounts['No Garden'] ?? 0}'),

              // DWELLING TYPE SECTION
              _row('Households, according to type of dwelling unit:', ''),
              _row('Concrete', '${dwellingCounts['Concrete'] ?? 0}'),
              _row('Semi Concrete', '${dwellingCounts['Semi Concrete'] ?? 0}'),
              _row('Wooden', '${dwellingCounts['Wooden'] ?? 0}'),
              _row('Nipa Bamboo House', '${dwellingCounts['Nipa Bamboo House'] ?? 0}'),
              _row('Barong-Barong', '${dwellingCounts['Barong-Barong'] ?? 0}'),
              _row('Makeshift', '${dwellingCounts['Makeshift'] ?? 0}'),

              _row('Total number of households using iodized salt', '$totalIodizedSalt'),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.TableRow _row(String a, String b) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(a),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(b),
        ),
      ],
    );
  }
}