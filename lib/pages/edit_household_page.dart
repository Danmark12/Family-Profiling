// lib/pages/household_detail_page.dart

import 'package:flutter/material.dart';
import '../models/household.dart';
import '../db/config.dart';

class HouseholdDetailPage extends StatelessWidget {
  final Household hh;

  const HouseholdDetailPage({super.key, required this.hh});

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget row(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hh.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive),
            onPressed: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Confirm"),
                  content: const Text("Are you sure you want to archive this household?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
                  ],
                ),
              );

              if (confirm == true) {
                await DBHelper.instance.archive(hh.id!);
                Navigator.pop(context);
              }
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // BASIC INFO
            sectionTitle("Basic Information"),
            row("Household No.", hh.householdNo),
            row("Name", hh.name),
            row("Purok", hh.purok),
            row("Occupation", hh.occupation),
            row("Education", hh.education),

            // POPULATION
            sectionTitle("Population"),
            row("Male", hh.male),
            row("Female", hh.female),
            row("Total Members", hh.total),

            // WOMEN STATUS
            sectionTitle("Women Status"),
            row("Pregnant", hh.pregnant),
            row("Lactating", hh.lactating),

            // NUTRITIONAL STATUS
            sectionTitle("Preschool Nutritional Status"),
            row("Severely Underweight", hh.su),
            row("Underweight", hh.uw),
            row("Normal Weight", hh.nw),
            row("Severely Wasted", hh.sw),
            row("Wasted", hh.w),
            row("Overweight", hh.ow),
            row("Obese", hh.ob),
            row("Severely Stunted", hh.ss),
            row("Stunted", hh.st),

            // INFANTS & CHILDREN
            sectionTitle("Infants & Children"),
            row("0-5 months", hh.inf0_5),
            row("6-11 months", hh.inf6_11),
            row("Preschool 0-23", hh.pre0_23),
            row("Preschool 12-59", hh.pre12_59),
            row("Preschool 24-59", hh.pre24_59),
            row("Exclusively Breastfed", hh.breastfed),
            row("Dewormed", hh.dewormed),
            row("Fully Immunized (FIC)", hh.fic),

            // HOUSEHOLD PRACTICES
            sectionTitle("Household Practices"),
            row("Iodized Salt", hh.iodized),
            row("Eatery/Carenderia", hh.eatery),

            const SizedBox(height: 30),

            // ARCHIVE BUTTON (BOTTOM)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.archive),
                label: const Text("Archive Household"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  bool? confirm = await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Confirm"),
                      content: const Text("Are you sure you want to archive this household?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await DBHelper.instance.archive(hh.id!);
                    Navigator.pop(context);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}