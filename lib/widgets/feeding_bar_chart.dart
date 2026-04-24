// lib/widgets/feeding_bar_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FeedingBarChart extends StatelessWidget {
  final int exclusive;
  final int mixed;
  final int bottleFed;
  final int complementary;

  const FeedingBarChart({
    Key? key,
    required this.exclusive,
    required this.mixed,
    required this.bottleFed,
    required this.complementary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<FeedingData> data = [
      FeedingData('Exclusive\nBreastfeeding', exclusive, Colors.green.shade600),
      FeedingData('Mixed\nFeeding', mixed, Colors.orange.shade600),
      FeedingData('Bottle\nFeeding', bottleFed, Colors.red.shade600),
      FeedingData('Complementary\nFeeding', complementary, Colors.blue.shade600),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Infant Feeding Practices',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: data.map((e) => e.count.toDouble()).reduce((a, b) => a > b ? a : b) + 2,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= data.length) {
                            return const Text('');
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              data[index].label,
                              textAlign: TextAlign.center,
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
                    FeedingData d = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: d.count.toDouble(),
                          color: d.color,
                          width: 40,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedingData {
  final String label;
  final int count;
  final Color color;
  
  FeedingData(this.label, this.count, this.color);
}