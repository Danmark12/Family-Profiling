// lib/widgets/nutrition_bar_chart.dart
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
    final List<_NutritionData> data = [
      _NutritionData('Sev\nWasted', severelyWasted, const Color(0xFFC62828)),
      _NutritionData('Sev\nUnder', severelyUnderweight, const Color(0xFFD32F2F)),
      _NutritionData('Sev\nStunted', severelyStunted, const Color(0xFFE53935)),
      _NutritionData('Wasted', wasted, const Color(0xFFF57C00)),
      _NutritionData('Under', underweight, const Color(0xFFFB8C00)),
      _NutritionData('Stunted', stunted, const Color(0xFFFFA726)),
      _NutritionData('Over', overweight, const Color(0xFFFFB74D)),
      _NutritionData('Obese', obese, const Color(0xFFFF8A65)),
      _NutritionData('Normal', normal, const Color(0xFF43A047)),
    ];

    final hasData = data.any((e) => e.value > 0);
    final total = data.fold(0, (sum, e) => sum + e.value);
    final healthy = normal;
    final healthyPercent = total > 0 ? (healthy / total * 100).toStringAsFixed(0) : '0';

    if (!hasData) {
      return _buildEmptyState();
    }

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
    final maxY = maxValue + (maxValue * 0.2);

    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('Nutrition Status', '$healthyPercent% healthy'),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 0,
                      getTooltipColor: (group) => Colors.transparent,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = data[group.x.toInt()];
                        if (item.value == 0) return null;
                        return BarTooltipItem(
                          '${item.value}',
                          const TextStyle(
                            color: Colors.black87,
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: _buildTitles(data),
                  barGroups: _buildBarGroups(data),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: _cardDecoration(),
      height: 240,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety, size: 32, color: Colors.grey),
            SizedBox(height: 4),
            Text('No nutrition data available', style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF43A047)),
          ),
        ),
      ],
    );
  }

  FlTitlesData _buildTitles(List<_NutritionData> data) {
    return FlTitlesData(
      show: true,
      leftTitles: AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    reservedSize: 28,
    interval: 1,
    getTitlesWidget: (value, meta) {
      // Only show integer values and prevent duplicates
      final intValue = value.toInt();
      if (value != intValue.toDouble()) return const Text('');
      return Text(
        intValue.toString(),
        style: const TextStyle(fontSize: 9, color: Color(0xFF7F8C8D)),
      );
    },
  ),
),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 48,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= data.length) return const Text('');
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                data[index].label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w500, color: Color(0xFF546E7A)),
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<_NutritionData> data) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.value.toDouble(),
            color: Colors.transparent,
            width: 24,
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide(color: item.color, width: 2),
          ),
        ],
        showingTooltipIndicators: item.value > 0 ? [0] : [],
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(const Color(0xFFE53935), 'Severe'),
          const SizedBox(width: 12),
          _legendItem(const Color(0xFFF57C00), 'Moderate'),
          const SizedBox(width: 12),
          _legendItem(const Color(0xFFFFB74D), 'Over/Obese'),
          const SizedBox(width: 12),
          _legendItem(const Color(0xFF43A047), 'Normal'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: Color(0xFF546E7A)),
        ),
      ],
    );
  }
}

class _NutritionData {
  final String label;
  final int value;
  final Color color;
  _NutritionData(this.label, this.value, this.color);
}