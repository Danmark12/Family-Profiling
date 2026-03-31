// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/config.dart';
import '../models/household.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalMale = 0;
  int totalFemale = 0;
  bool isLoading = true;

  final maleColor = const Color(0xFF4A90E2); // soft blue
  final femaleColor = const Color(0xFFFF69B4); // soft pink

  @override
  void initState() {
    super.initState();
    fetchPopulation();
  }

  Future<void> fetchPopulation() async {
    final data = await DBHelper.instance.getAllHouseholds();
    int m = 0;
    int f = 0;

    for (var hh in data) {
      m += hh.male ?? 0;
      f += hh.female ?? 0;
    }

    setState(() {
      totalMale = m;
      totalFemale = f;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxPopulation = (totalMale > totalFemale ? totalMale : totalFemale)
        .toDouble(); // for scaling circles

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Floating Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            "Total Population",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Smaller BAR CHART without grid/side numbers
                          SizedBox(
                            height: 150, // smaller height
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxPopulation + 5,
                                barTouchData: BarTouchData(enabled: false),
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: [
                                  BarChartGroupData(
                                    x: 0,
                                    barRods: [
                                      BarChartRodData(
                                        toY: totalMale.toDouble(),
                                        color: maleColor,
                                        width: 24,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 1,
                                    barRods: [
                                      BarChartRodData(
                                        toY: totalFemale.toDouble(),
                                        color: femaleColor,
                                        width: 24,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Gender Indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: maleColor
                                              .withOpacity(totalMale / maxPopulation),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.male,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "$totalMale",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: femaleColor
                                              .withOpacity(totalFemale / maxPopulation),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.female,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "$totalFemale",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Total Population: ${totalMale + totalFemale}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
    );
  }
}