// lib/pages/household_detail_page.dart
import 'package:flutter/material.dart';
import '../models/household.dart';

class HouseholdDetailPage extends StatelessWidget {
  final Household hh;

  const HouseholdDetailPage({super.key, required this.hh});

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  TableRow buildRow(String label, dynamic value) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Text(value?.toString() ?? '-'),
      ),
    ]);
  }

  String boolText(bool value) => value ? "Yes" : "No";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Household #${hh.householdNo}"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ✅ BASIC INFO
            buildSectionTitle("Basic Information"),
            Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
              border: TableBorder.all(color: Colors.grey),
              children: [
                buildRow("Household No.", hh.householdNo),
                buildRow("Household Head", hh.householdHead),
                buildRow("Barangay", hh.barangay),
                buildRow("Purok/Zone", hh.zone),
                buildRow("Occupation", hh.occupation),
                buildRow("Education", hh.education),
                buildRow("Male Members", hh.male),
                buildRow("Female Members", hh.female),
                buildRow("Total Members", hh.total),
                buildRow("Families in Household", hh.families),
                buildRow("Pregnant Members", hh.pregnant),
                buildRow("Lactating Members", hh.lactating),
              ],
            ),

            // ✅ INFANTS & CHILDREN
            buildSectionTitle("Children (by Age)"),
            Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
              border: TableBorder.all(color: Colors.grey),
              children: [
                buildRow("0-5 months", hh.infant0to5),
                buildRow("6-11 months", hh.infant6to11),
                buildRow("12-23 months", hh.infant12to23),
                buildRow("24-59 months", hh.infant24to59),
              ],
            ),

            // ✅ NUTRITION STATUS
            buildSectionTitle("Nutrition Status"),
            Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
              border: TableBorder.all(color: Colors.grey),
              children: [
                buildRow("Severe Underweight", hh.underweightSevere),
                buildRow("Underweight", hh.underweight),
                buildRow("Normal", hh.normal),
                buildRow("Severe Wasted", hh.wastedSevere),
                buildRow("Wasted", hh.wasted),
                buildRow("Overweight", hh.overweight),
                buildRow("Obese", hh.obese),
                buildRow("Severe Stunted", hh.stuntedSevere),
                buildRow("Stunted", hh.stunted),
              ],
            ),

            // ✅ FACILITIES
            buildSectionTitle("Facilities"),
            Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
              border: TableBorder.all(color: Colors.grey),
              children: [
                buildRow("Toilet Type", hh.toilet),
                buildRow("Water Source", hh.water),
                buildRow("Food Production", hh.food),
              ],
            ),

            // ✅ HOUSEHOLD PRACTICES
            buildSectionTitle("Household Practices"),
            Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
              border: TableBorder.all(color: Colors.grey),
              children: [
                buildRow("Uses Iodized Salt", boolText(hh.iodizedSalt)),
                buildRow("Uses IFR", boolText(hh.ifr)),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}