// lib/widgets/immunization_donut_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ImmunizationDonutChart extends StatelessWidget {
  final int fullyImmunized;
  final int totalChildren;

  const ImmunizationDonutChart({
    Key? key,
    required this.fullyImmunized,
    required this.totalChildren,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notImmunized = totalChildren - fullyImmunized;
    final immunizedPercent = totalChildren > 0 
        ? (fullyImmunized / totalChildren * 100).toStringAsFixed(1) 
        : '0';
    final notImmunizedPercent = totalChildren > 0 
        ? (notImmunized / totalChildren * 100).toStringAsFixed(1) 
        : '0';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Immunization Coverage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: fullyImmunized.toDouble(),
                      title: '$immunizedPercent%',
                      color: Colors.green.shade500,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: notImmunized.toDouble(),
                      title: '$notImmunizedPercent%',
                      color: Colors.red.shade400,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend('Fully Immunized', Colors.green.shade500),
                const SizedBox(width: 20),
                _buildLegend('Not Fully', Colors.red.shade400),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Target: 95% coverage',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}