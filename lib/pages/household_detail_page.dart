import 'package:flutter/material.dart';
import '../models/household.dart';

class HouseholdDetailPage extends StatelessWidget {
  final Household hh;

  const HouseholdDetailPage({super.key, required this.hh});

  // ================= ROW BUILDER =================
  Widget buildRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String boolText(int? value) {
    if (value == null) return "-";
    return value == 1 ? "Yes" : "No";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= APP BAR (KEEP HOUSEHOLD # HERE ONLY) =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Household${hh.householdNo}",
          style: const TextStyle(color: Colors.black),
        ),
      ),

      body: Column(
        children: [

          // ================= CLEAN HEADER (NO PROFILE TEXT, NO DUPLICATE ID) =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "Zone/Purok: ${hh.zone ?? "-"}",
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  "Barangay: ${hh.barangay ?? "-"}",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),

          // ================= TABLE =================
          Expanded(
            child: ListView(
              children: [

                // PROGRAMS
                buildRow("4Ps", boolText(hh.fourPs)),
                buildRow("Indigenous People", boolText(hh.indigenousPeople)),

                // FATHER
                buildRow("Father Name", hh.fatherName ?? "-"),
                buildRow("Father Occupation", hh.fatherOccupation ?? "None"),
                buildRow("Father Education", hh.fatherEducation ?? "None"),

                // MOTHER
                buildRow("Mother Name", hh.motherName ?? "-"),
                buildRow("Mother Occupation", hh.motherOccupation ?? "None"),
                buildRow("Mother Education", hh.motherEducation ?? "None"),

                // HOUSEHOLD
                buildRow("Male", "${hh.male ?? 0}"),
                buildRow("Female", "${hh.female ?? 0}"),
                buildRow("No. of Families", "${hh.families ?? 0}"),
                buildRow("Fully Immunized Child", "${hh.fullyImmunized ?? 0}"),

                // AGE GROUP
                buildRow("0–5 months", "${hh.infant0to5 ?? 0}"),
                buildRow("6–11 months", "${hh.infant6to11 ?? 0}"),
                buildRow("12–23 months", "${hh.child12to23 ?? 0}"),
                buildRow("24–59 months", "${hh.child24to59 ?? 0}"),
                buildRow("5–9 years", "${hh.age5to9 ?? 0}"),
                buildRow("10–19 years", "${hh.age10to19 ?? 0}"),
                buildRow("20–59 years", "${hh.age20to59 ?? 0}"),
                buildRow("60+ years", "${hh.age60above ?? 0}"),
                buildRow("PWD", "${hh.pwd ?? 0}"),

                // FACILITIES
                buildRow("Toilet Type", hh.toilet ?? "-"),
                buildRow("Garbage Disposal", hh.garbage ?? "-"),
                buildRow("Water Source", hh.water ?? "-"),
                buildRow("Food Production", hh.food ?? "-"),
                buildRow("Dwelling Type", hh.dwellingType ?? "-"),
                buildRow("Iodized Salt", boolText(hh.iodizedSalt)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}