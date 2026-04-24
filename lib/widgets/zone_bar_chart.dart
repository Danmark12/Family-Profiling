// lib/widgets/zone_bar_chart.dart (SORTED NUMERICALLY)
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ZoneBarChart extends StatelessWidget {
  final Map<String, int> zoneCount;

  const ZoneBarChart({
    Key? key,
    required this.zoneCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert zone strings to numbers and sort numerically
    final List<ZoneData> data = zoneCount.entries
        .map((e) {
          // Extract number from zone string (e.g., "Zone 1" -> 1, "Zone A" -> 0)
          int zoneNumber = _extractZoneNumber(e.key);
          return ZoneData(e.key, e.value, zoneNumber);
        })
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));

    if (data.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12),
        ),
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text('No zone data available', style: TextStyle(fontSize: 12)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.purple),
                const SizedBox(width: 6),
                Text(
                  'Households by Zone',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: data.map((e) => e.count.toDouble()).reduce((a, b) => a > b ? a : b) + 1,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 9),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= data.length) {
                            return const Text('');
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              data[index].zone,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: data.asMap().entries.map((entry) {
                    int index = entry.key;
                    ZoneData d = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: d.count.toDouble(),
                          color: Colors.purple.shade400,
                          width: 35,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    );
                  }).toList(),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Summary row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Zones: ${data.length}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Total Households: ${data.map((e) => e.count).reduce((a, b) => a + b)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to extract number from zone string
  int _extractZoneNumber(String zone) {
    // Try to extract number from patterns like "Zone 1", "Zone1", "1", "Zone A"
    final RegExp regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(zone);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    
    // Handle letter zones (A, B, C) - convert to numbers
    final letterRegex = RegExp(r'Zone\s+([A-Z])', caseSensitive: false);
    final letterMatch = letterRegex.firstMatch(zone);
    if (letterMatch != null) {
      String letter = letterMatch.group(1)!.toUpperCase();
      // A=1, B=2, C=3, etc.
      return letter.codeUnitAt(0) - 64;
    }
    
    // Default: put unknown zones at the end
    return 999;
  }
}

class ZoneData {
  final String zone;
  final int count;
  final int number; // For sorting

  ZoneData(this.zone, this.count, this.number);
}