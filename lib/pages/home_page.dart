// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/config.dart';
import 'settings.dart';
import 'barangay_household.dart';
import 'consolidated.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalHouseholds = 0;
  int totalResidents = 0;
  int male = 0;
  int female = 0;

  Map<String, int> zoneCount = {};
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');

    if (userId == null) return;

    final households =
        await DBHelper.instance.getAllHouseholds(userId!);

    int totalRes = 0;
    int totalMale = 0;
    int totalFemale = 0;

    Map<String, int> tempZoneCount = {};

    for (var h in households) {
      int m = h['male'] ?? 0;
      int f = h['female'] ?? 0;

      totalRes += m + f;
      totalMale += m;
      totalFemale += f;

      String zone = h['zone']?.toString() ?? 'Unknown';
      tempZoneCount[zone] = (tempZoneCount[zone] ?? 0) + 1;
    }

    setState(() {
      totalHouseholds = households.length;
      totalResidents = totalRes;
      male = totalMale;
      female = totalFemale;

      zoneCount = Map.fromEntries(
        tempZoneCount.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 52,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 22),
            onPressed: () {
              if (userId == null) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SettingsPage(currentUserId: userId!),
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= OVERVIEW =================
            const Text(
              "Overview",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.normal,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _card("Households", totalHouseholds),
                const SizedBox(width: 10),
                _card("Residents", totalResidents),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                _card("Male", male),
                const SizedBox(width: 10),
                _card("Female", female),
              ],
            ),

            const SizedBox(height: 22),

            // ================= ZONE CHART =================
            const Text(
              "Households per Zone",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),

            const SizedBox(height: 12),

            _zoneChart(),

            const SizedBox(height: 22),

            // ================= REPORTS =================
            const Text(
              "Reports",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),

            const SizedBox(height: 12),

            _reportItem(
              icon: Icons.table_chart_outlined,
              title: "Barangay Household Table",
              subtitle: "View detailed household records",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BarangayHouseholdPage(),
                  ),
                );
              },
            ),

            _reportItem(
              icon: Icons.analytics_outlined,
              title: "Consolidated Report",
              subtitle: "Summary and analytics",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConsolidatedReportPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= ZONE CHART =================
  Widget _zoneChart() {
    if (zoneCount.isEmpty) {
      return const Text(
        "No data available",
        style: TextStyle(color: Colors.black54),
      );
    }

    int maxValue = zoneCount.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: zoneCount.entries.map((e) {
          double ratio = e.value / maxValue;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    e.key,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),

                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: ratio,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 4, 93, 7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  "${e.value}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= CARD (ZOOMED IN) =================
  Widget _card(String title, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= REPORT ITEM =================
  Widget _reportItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ),
        leading: Icon(icon, color: const Color.fromARGB(255, 14, 27, 15), size: 22),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 15,
          color: Color.fromARGB(255, 7, 19, 7),
        ),
        onTap: onTap,
      ),
    );
  }
}