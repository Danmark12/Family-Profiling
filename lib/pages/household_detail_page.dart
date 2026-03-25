// lib/pages/household_detail_page.dart
import 'package:flutter/material.dart';
import '../models/household.dart';

class HouseholdDetailPage extends StatelessWidget {
  final Household hh;

  const HouseholdDetailPage({super.key, required this.hh});

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        child: Text(value.toString()),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hh.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // BASIC INFO
            buildSectionTitle("Basic Information"),
            Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
              border: TableBorder.all(color: Colors.grey),
              children: [
                buildRow("Household No.", hh.householdNo),
                buildRow("Name", hh.name),
                buildRow("Purok", hh.purok),
                buildRow("Occupation", hh.occupation),
                buildRow("Education", hh.education),
              ],
            ),

            // POPULATION
            buildSectionTitle("Population"),
            Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
              border: TableBorder.all(color: Colors.grey),
              children: [
                buildRow("Male", hh.male),
                buildRow("Female", hh.female),
                buildRow("Total Members", hh.total),
                buildRow("Pregnant", hh.pregnant),
                buildRow("Lactating", hh.lactating),
              ],
            ),

            // NUTRITIONAL STATUS
            buildSectionTitle("Preschool Nutritional Status"),
            Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
              border: TableBorder.all(color: Colors.grey),
              children: [
                buildRow("Severely Underweight", hh.su),
                buildRow("Underweight", hh.uw),
                buildRow("Normal Weight", hh.nw),
                buildRow("Severely Wasted", hh.sw),
                buildRow("Wasted", hh.w),
                buildRow("Overweight", hh.ow),
                buildRow("Obese", hh.ob),
                buildRow("Severely Stunted", hh.ss),
                buildRow("Stunted", hh.st),
              ],
            ),

            // INFANTS & CHILDREN
            buildSectionTitle("Infants & Children"),
            Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
              border: TableBorder.all(color: Colors.grey),
              children: [
                buildRow("0-5 months", hh.inf0_5),
                buildRow("6-11 months", hh.inf6_11),
                buildRow("Preschool 0-23 months", hh.pre0_23),
                buildRow("Preschool 12-59 months", hh.pre12_59),
                buildRow("Preschool 24-59 months", hh.pre24_59),
                buildRow("Exclusively Breastfed 0-5", hh.breastfed),
                buildRow("Dewormed", hh.dewormed),
                buildRow("Fully Immunized Children (FIC)", hh.fic),
              ],
            ),

            // HOUSEHOLD PRACTICES
            buildSectionTitle("Household Practices"),
            Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
              border: TableBorder.all(color: Colors.grey),
              children: [
                buildRow("Iodized Salt", hh.iodized),
                buildRow("Eatery/Carenderia", hh.eatery),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}