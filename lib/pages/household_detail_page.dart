// lib/pages/household_detail_page.dart
import 'package:flutter/material.dart';
import '../models/household.dart';

class HouseholdDetailPage extends StatelessWidget {
  final Household hh;
  const HouseholdDetailPage({super.key, required this.hh});

  // helper to show a row
  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // helper to show a card section
  Widget buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...children
          ],
        ),
      ),
    );
  }

  String boolToYesNo(int? value) {
    if (value == null) return "-";
    return value == 1 ? "Yes" : "No";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Household ${hh.householdNo}"),
        backgroundColor: const Color(0xFF568203),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            buildSection("Basic Info", [
              buildRow("Zone/Purok", hh.zone ?? "-"),
              buildRow("Barangay", hh.barangay ?? "-"),
              buildRow("4Ps", boolToYesNo(hh.fourPs)),
              buildRow("Indigenous People", boolToYesNo(hh.indigenousPeople)),
              buildRow("Iodized Salt", boolToYesNo(hh.iodizedSalt)),
            ]),

            buildSection("Father", [
              buildRow("Name", hh.fatherName ?? "-"),
              buildRow("Occupation", hh.fatherOccupation ?? "-"),
              buildRow("Education", hh.fatherEducation ?? "-"),
            ]),

            buildSection("Mother", [
              buildRow("Name", hh.motherName ?? "-"),
              buildRow("Occupation", hh.motherOccupation ?? "-"),
              buildRow("Education", hh.motherEducation ?? "-"),
            ]),

            buildSection("Household Members", [
              buildRow("Male", hh.male?.toString() ?? "-"),
              buildRow("Female", hh.female?.toString() ?? "-"),
              buildRow("Total", hh.total?.toString() ?? "-"),
              buildRow("Families", hh.families?.toString() ?? "-"),
              buildRow("Fully Immunized Children", hh.fullyImmunized?.toString() ?? "-"),
            ]),

            buildSection("IYCF", [
              buildRow("Exclusive", hh.exclusive?.toString() ?? "-"),
              buildRow("Mixed", hh.mixed?.toString() ?? "-"),
              buildRow("Bottle Fed", hh.bottleFed?.toString() ?? "-"),
              buildRow("Complementary Feeding", hh.complementary?.toString() ?? "-"),
            ]),

            buildSection("Women Status", [
              buildRow("Pregnant <19", hh.preg19?.toString() ?? "-"),
              buildRow("Pregnant 20+", hh.preg20?.toString() ?? "-"),
              buildRow("Lactating", hh.lactating?.toString() ?? "-"),
            ]),

            buildSection("Age Groups", [
              buildRow("0-5 months", hh.infant0to5?.toString() ?? "-"),
              buildRow("6-11 months", hh.infant6to11?.toString() ?? "-"),
              buildRow("12-23 months", hh.child12to23?.toString() ?? "-"),
              buildRow("24-59 months", hh.child24to59?.toString() ?? "-"),
              buildRow("5-9 years", hh.age5to9?.toString() ?? "-"),
              buildRow("10-19 years", hh.age10to19?.toString() ?? "-"),
              buildRow("20-59 years", hh.age20to59?.toString() ?? "-"),
              buildRow("60+ years", hh.age60above?.toString() ?? "-"),
              buildRow("PWD", hh.pwd?.toString() ?? "-"),
            ]),

            buildSection("Nutritional Status", [
              buildRow("Severely Underweight", hh.severelyUnderweight?.toString() ?? "-"),
              buildRow("Underweight", hh.underweight?.toString() ?? "-"),
              buildRow("Normal", hh.normal?.toString() ?? "-"),
              buildRow("Severely Wasted", hh.severelyWasted?.toString() ?? "-"),
              buildRow("Wasted", hh.wasted?.toString() ?? "-"),
              buildRow("Overweight", hh.overweight?.toString() ?? "-"),
              buildRow("Obese", hh.obese?.toString() ?? "-"),
              buildRow("Severely Stunted", hh.severelyStunted?.toString() ?? "-"),
              buildRow("Stunted", hh.stunted?.toString() ?? "-"),
            ]),

            buildSection("Facilities", [
              buildRow("Toilet Type", hh.toilet ?? "-"),
              buildRow("Garbage Disposal", hh.garbage ?? "-"),
              buildRow("Water Source", hh.water ?? "-"),
              buildRow("Food Production", hh.food ?? "-"),
              buildRow("Dwelling Type", hh.dwellingType ?? "-"),
            ]),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}