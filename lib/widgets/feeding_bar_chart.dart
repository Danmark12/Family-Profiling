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

  double _getYAxisInterval(double maxValue) {
    if (maxValue <= 10) return 1;
    if (maxValue <= 20) return 2;
    if (maxValue <= 50) return 5;
    if (maxValue <= 100) return 10;
    if (maxValue <= 200) return 20;
    if (maxValue <= 500) return 50;
    if (maxValue <= 1000) return 100;
    return 200;
  }

  @override
  Widget build(BuildContext context) {
    final List<_FeedingData> data = [
      _FeedingData('Exclusive', exclusive, const Color(0xFF2E7D32)),
      _FeedingData('Mixed', mixed, const Color(0xFFF57C00)),
      _FeedingData('Bottle', bottleFed, const Color(0xFFC62828)),
      _FeedingData('Complementary', complementary, const Color(0xFF1565C0)),
    ];

    final hasData = data.any((e) => e.value > 0);
    final total = data.fold(0, (sum, e) => sum + e.value);

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
            _buildHeader('Infant Feeding', '$total infants'),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
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
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: _buildTitles(data, maxY),
                  barGroups: _buildBarGroups(data),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FlTitlesData _buildTitles(List<_FeedingData> data, double maxY) {
    return FlTitlesData(
      show: true,
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 35,
          interval: _getYAxisInterval(maxY),
          getTitlesWidget: (value, meta) {
            if (value != value.toInt().toDouble()) return const Text('');
            String formattedValue = value.toInt().toString();
            if (value >= 1000) {
              formattedValue = '${(value / 1000).toStringAsFixed(0)}k';
            }
            return Text(
              formattedValue,
              style: const TextStyle(fontSize: 9, color: Color(0xFF7F8C8D)),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= data.length) return const Text('');
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                data[index].label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF546E7A)),
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: _cardDecoration(),
      height: 200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.baby_changing_station, size: 32, color: Colors.grey),
            SizedBox(height: 4),
            Text('No feeding data available', style: TextStyle(color: Colors.grey, fontSize: 11)),
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
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF1565C0)),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<_FeedingData> data) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.value.toDouble(),
            color: Colors.transparent,
            width: 38,
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide(color: item.color, width: 2),
          ),
        ],
        showingTooltipIndicators: item.value > 0 ? [0] : [],
      );
    }).toList();
  }
}

class _FeedingData {
  final String label;
  final int value;
  final Color color;
  _FeedingData(this.label, this.value, this.color);
}