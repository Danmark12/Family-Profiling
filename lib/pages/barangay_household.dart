// lib/pages/barangay_household.dart
import 'package:flutter/material.dart';
import '../db/config.dart';
import '../models/household.dart';

class HouseholdPage extends StatefulWidget {
  const HouseholdPage({super.key});

  @override
  State<HouseholdPage> createState() => _HouseholdPageState();
}

class _HouseholdPageState extends State<HouseholdPage> {
  List<Household> households = [];

  @override
  void initState() {
    super.initState();
    _loadHouseholds();
  }

  Future<void> _loadHouseholds() async {
    final data = await DBHelper.instance.getAllHouseholds();
    setState(() {
      households = data.map((e) => Household.fromMap(e)).toList();
    });
  }

  // All columns we want to display in CSV-style
  List<String> get headers => [
        "Household No",
        "Zone",
        "Barangay",
        "4Ps",
        "Indigenous People",
        "Iodized Salt",
        "Father Name",
        "Father Occupation",
        "Father Education",
        "Mother Name",
        "Mother Occupation",
        "Mother Education",
        "Male",
        "Female",
        "Total",
        "Families",
        "Fully Immunized",
        "Exclusive",
        "Mixed",
        "Bottle Fed",
        "Complementary",
        "Preg <19",
        "Preg 20+",
        "Lactating",
        "0-5 mo",
        "6-11 mo",
        "12-23 mo",
        "24-59 mo",
        "5-9",
        "10-19",
        "20-59",
        "60+",
        "PWD",
        "Severely Underweight",
        "Underweight",
        "Normal",
        "Severely Wasted",
        "Wasted",
        "Overweight",
        "Obese",
        "Severely Stunted",
        "Stunted",
        "Toilet",
        "Garbage",
        "Water",
        "Food",
        "Dwelling Type"
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Household Records")),
      body: households.isEmpty
          ? const Center(child: Text("No household records yet"))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey[300]),
                  columns: headers
                      .map((h) => DataColumn(
                            label: Text(
                              h,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ))
                      .toList(),
                  rows: households.map((h) {
                    return DataRow(cells: [
                      DataCell(Text(h.householdNo.toString())),
                      DataCell(Text(h.zone ?? "")),
                      DataCell(Text(h.barangay ?? "")),
                      DataCell(Text(h.fourPs.toString())),
                      DataCell(Text(h.indigenousPeople.toString())),
                      DataCell(Text(h.iodizedSalt.toString())),
                      DataCell(Text(h.fatherName ?? "")),
                      DataCell(Text(h.fatherOccupation ?? "")),
                      DataCell(Text(h.fatherEducation ?? "")),
                      DataCell(Text(h.motherName ?? "")),
                      DataCell(Text(h.motherOccupation ?? "")),
                      DataCell(Text(h.motherEducation ?? "")),
                      DataCell(Text(h.male?.toString() ?? "")),
                      DataCell(Text(h.female?.toString() ?? "")),
                      DataCell(Text(h.total?.toString() ?? "")),
                      DataCell(Text(h.families?.toString() ?? "")),
                      DataCell(Text(h.fullyImmunized?.toString() ?? "")),
                      DataCell(Text(h.exclusive?.toString() ?? "")),
                      DataCell(Text(h.mixed?.toString() ?? "")),
                      DataCell(Text(h.bottleFed?.toString() ?? "")),
                      DataCell(Text(h.complementary?.toString() ?? "")),
                      DataCell(Text(h.preg19?.toString() ?? "")),
                      DataCell(Text(h.preg20?.toString() ?? "")),
                      DataCell(Text(h.lactating?.toString() ?? "")),
                      DataCell(Text(h.infant0to5?.toString() ?? "")),
                      DataCell(Text(h.infant6to11?.toString() ?? "")),
                      DataCell(Text(h.child12to23?.toString() ?? "")),
                      DataCell(Text(h.child24to59?.toString() ?? "")),
                      DataCell(Text(h.age5to9?.toString() ?? "")),
                      DataCell(Text(h.age10to19?.toString() ?? "")),
                      DataCell(Text(h.age20to59?.toString() ?? "")),
                      DataCell(Text(h.age60above?.toString() ?? "")),
                      DataCell(Text(h.pwd?.toString() ?? "")),
                      DataCell(Text(h.severelyUnderweight?.toString() ?? "")),
                      DataCell(Text(h.underweight?.toString() ?? "")),
                      DataCell(Text(h.normal?.toString() ?? "")),
                      DataCell(Text(h.severelyWasted?.toString() ?? "")),
                      DataCell(Text(h.wasted?.toString() ?? "")),
                      DataCell(Text(h.overweight?.toString() ?? "")),
                      DataCell(Text(h.obese?.toString() ?? "")),
                      DataCell(Text(h.severelyStunted?.toString() ?? "")),
                      DataCell(Text(h.stunted?.toString() ?? "")),
                      DataCell(Text(h.toilet ?? "")),
                      DataCell(Text(h.garbage ?? "")),
                      DataCell(Text(h.water ?? "")),
                      DataCell(Text(h.food ?? "")),
                      DataCell(Text(h.dwellingType ?? "")),
                    ]);
                  }).toList(),
                ),
              ),
            ),
    );
  }
}