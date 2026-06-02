import 'package:flutter/material.dart';
import '../db/config.dart';
import '../models/household.dart';
import 'edit_household_page.dart';

class HouseholdDetailPage extends StatefulWidget {
  final Household hh;

  const HouseholdDetailPage({super.key, required this.hh});

  @override
  State<HouseholdDetailPage> createState() => _HouseholdDetailPageState();
}

class _HouseholdDetailPageState extends State<HouseholdDetailPage> {
  late Household household;

  @override
  void initState() {
    super.initState();
    household = widget.hh;
  }

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

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Household ${household.householdNo}",
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditHouseholdPage(household: household),
                ),
              );
              // Refresh if edit was successful
              if (result == true) {
                final updated = await DBHelper.instance.getHousehold(household.id!);
                if (updated != null) {
                  setState(() {
                    household = Household.fromMap(updated);
                  });
                }
              }
            },
          ),
        ],
      ),

      body: Column(
        children: [

          // ================= HEADER =================
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
                  "Zone/Purok: ${household.zone ?? "-"}",
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  "Barangay: ${household.barangay ?? "-"}",
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
                buildRow("4Ps", boolText(household.fourPs)),
                buildRow("Indigenous People", boolText(household.indigenousPeople)),

                // FATHER
                buildRow("Father Name", household.fatherName ?? "-"),
                buildRow("Father Occupation", household.fatherOccupation ?? "None"),
                buildRow("Father Education", household.fatherEducation ?? "None"),

                // MOTHER
                buildRow("Mother Name", household.motherName ?? "-"),
                buildRow("Mother Occupation", household.motherOccupation ?? "None"),
                buildRow("Mother Education", household.motherEducation ?? "None"),

                // HOUSEHOLD
                buildRow("Household Members:", ""),               
                buildRow("Male", "${household.male ?? 0}"),
                buildRow("Female", "${household.female ?? 0}"),
                buildRow("No. of Families", "${household.families ?? 0}"),
                buildRow("Fully Immunized Child", "${household.fullyImmunized ?? 0}"),

                // AGE GROUP
                buildRow("Age Group:", ""),
                buildRow("0-5 months old", "${household.infant0to5 ?? 0}"),
                buildRow("6–11 months old", "${household.infant6to11 ?? 0}"),
                buildRow("12–23 months old", "${household.child12to23 ?? 0}"),
                buildRow("24–59 months old", "${household.child24to59 ?? 0}"),
                buildRow("5–9 years old", "${household.age5to9 ?? 0}"),
                buildRow("10–19 years old", "${household.age10to19 ?? 0}"),
                buildRow("20–59 years old", "${household.age20to59 ?? 0}"),
                buildRow("60+ years old", "${household.age60above ?? 0}"),
                buildRow("PWD", "${household.pwd ?? 0}"),

                buildRow("Women Status:", ""),
                buildRow("Pregnant 19 below", "${household.preg19 ?? 0}"),
                buildRow("Pregnant 20 above", "${household.preg20 ?? 0}"),
                buildRow("Lactating", "${household.lactating ?? 0}"),

                // IYCF
                buildRow("IYCF:", ""),
                buildRow("0-5 Months Exclusive Breastfeeding", "${household.exclusive ?? 0}"),
                buildRow("0-5 Months Mixed Feeding", "${household.mixed ?? 0}"),
                buildRow("0-5 Months Bottle Feeding", "${household.bottleFed ?? 0}"),
                buildRow("6-12 Months Complementary Feeding", "${household.complementary ?? 0}"),

                buildRow("Preschool Children Nutritional Status:", ""),
                buildRow("Severely Underweight", "${household.severelyUnderweight ?? 0}"),
                buildRow("Underweight", "${household.underweight ?? 0}"),
                buildRow("Normal", "${household.normal ?? 0}"),
                buildRow("Severely Wasted", "${household.severelyWasted ?? 0}"),
                buildRow("Wasted", "${household.wasted ?? 0}"),
                buildRow("Overweight", "${household.overweight ?? 0}"),
                buildRow("Obese", "${household.obese ?? 0}"),
                buildRow("Severely Stunted", "${household.severelyStunted ?? 0}"),
                buildRow("Stunted", "${household.stunted ?? 0}"),

                // FACILITIES
                buildRow("Facilities:", ""),
                buildRow("Toilet Type Facility", household.toilet ?? "-"),
                buildRow("Shared Toilet", boolText(household.shared)),
                buildRow("Waste Management", household.garbage ?? "-"),
                buildRow("Type of Water Supply", household.water ?? "-"),
                buildRow("Food Production", household.food ?? "-"),
                buildRow("Dwelling Type", household.dwellingType ?? "-"),

                buildRow("Iodized Salt", boolText(household.iodizedSalt)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}