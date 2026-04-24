// lib/widgets/nutrition_bar_chart.dart (COMPLETE WITH ALL INDICATORS)
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class NutritionBarChart extends StatelessWidget {
  final int severelyUnderweight;
  final int underweight;
  final int normal;
  final int severelyWasted;
  final int wasted;
  final int overweight;
  final int obese;
  final int severelyStunted;
  final int stunted;

  const NutritionBarChart({
    Key? key,
    required this.severelyUnderweight,
    required this.underweight,
    required this.normal,
    required this.severelyWasted,
    required this.wasted,
    required this.overweight,
    required this.obese,
    required this.severelyStunted,
    required this.stunted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<NutritionData> data = [
      // Severe conditions (Red shades)
      NutritionData('Severely\nWasted', severelyWasted, Colors.red.shade900),
      NutritionData('Severely\nUnderweight', severelyUnderweight, Colors.red.shade800),
      NutritionData('Severely\nStunted', severelyStunted, Colors.red.shade700),
      
      // Moderate conditions (Orange shades)
      NutritionData('Wasted', wasted, Colors.orange.shade800),
      NutritionData('Underweight', underweight, Colors.orange.shade700),
      NutritionData('Stunted', stunted, Colors.orange.shade600),
      
      // Overweight/Obese (Amber/Yellow shades)
      NutritionData('Overweight', overweight, Colors.amber.shade700),
      NutritionData('Obese', obese, Colors.deepOrange.shade600),
      
      // Normal (Green)
      NutritionData('Normal', normal, Colors.green.shade600),
    ];

    // Filter out zero values to save space (optional - remove if you want to show zeros)
    final nonZeroData = data.where((d) => d.value > 0).toList();
    final displayData = nonZeroData.isEmpty ? data : nonZeroData;

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
                const Icon(Icons.health_and_safety, size: 16, color: Colors.red),
                const SizedBox(width: 6),
                Text(
                  'Child Nutrition Status',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Under 5 years old (All indicators)',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 280, // Increased height to accommodate more bars
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: displayData.map((e) => e.value.toDouble()).reduce((a, b) => a > b ? a : b) + 2,
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
                        reservedSize: 55,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= displayData.length) {
                            return const Text('');
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              displayData[index].label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 8),
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
                  barGroups: displayData.asMap().entries.map((entry) {
                    int index = entry.key;
                    NutritionData d = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: d.value.toDouble(),
                          color: d.color,
                          width: 22,
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
            // Legend
            Wrap(
              spacing: 10,
              runSpacing: 5,
              alignment: WrapAlignment.center,
              children: [
                _buildLegend('Severe', Colors.red.shade700),
                _buildLegend('Moderate', Colors.orange.shade700),
                _buildLegend('Over/Obese', Colors.amber.shade700),
                _buildLegend('Normal', Colors.green.shade600),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9),
        ),
      ],
    );
  }
}

class NutritionData {
  final String label;
  final int value;
  final Color color;
  
  NutritionData(this.label, this.value, this.color);
}