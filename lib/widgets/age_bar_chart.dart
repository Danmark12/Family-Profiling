// lib/widgets/age_bar_chart.dart (COMPACT VERSION)
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AgeBarChart extends StatelessWidget {
  final int age0to4;
  final int age5to9;
  final int age10to19;
  final int age20to59;
  final int age60plus;

  const AgeBarChart({
    Key? key,
    required this.age0to4,
    required this.age5to9,
    required this.age10to19,
    required this.age20to59,
    required this.age60plus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<AgeGroupData> data = [
      AgeGroupData('0-4', age0to4, Colors.teal.shade400),
      AgeGroupData('5-9', age5to9, Colors.teal.shade500),
      AgeGroupData('10-19', age10to19, Colors.teal.shade600),
      AgeGroupData('20-59', age20to59, Colors.teal.shade700),
      AgeGroupData('60+', age60plus, Colors.teal.shade800),
    ];

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
            Text(
              'Age Groups',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: data.map((e) => e.value.toDouble()).reduce((a, b) => a > b ? a : b) + 2,
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
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= data.length) {
                            return const Text('');
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              data[index].label,
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
                    AgeGroupData d = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: d.value.toDouble(),
                          color: d.color,
                          width: 25,
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
          ],
        ),
      ),
    );
  }
}

class AgeGroupData {
  final String label;
  final int value;
  final Color color;
  
  AgeGroupData(this.label, this.value, this.color);
}