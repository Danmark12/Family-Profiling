// lib/widgets/gender_donut_chart.dart (COMPACT VERSION)
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GenderDonutChart extends StatelessWidget {
  final int male;
  final int female;

  const GenderDonutChart({
    Key? key,
    required this.male,
    required this.female,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = male + female;
    final malePercent = total > 0 ? (male / total * 100).toStringAsFixed(0) : '0';
    final femalePercent = total > 0 ? (female / total * 100).toStringAsFixed(0) : '0';

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
              'Gender',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: male.toDouble(),
                      title: '$malePercent%',
                      color: Colors.blue.shade400,
                      radius: 45,
                      titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: female.toDouble(),
                      title: '$femalePercent%',
                      color: Colors.pink.shade400,
                      radius: 45,
                      titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 1,
                  centerSpaceRadius: 25,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend('M', Colors.blue.shade400),
                const SizedBox(width: 12),
                _buildLegend('F', Colors.pink.shade400),
                const SizedBox(width: 12),
                Text(
                  'Total: ${total}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 9),
        ),
      ],
    );
  }
}