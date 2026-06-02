// lib/widgets/zone_bar_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ZoneBarChart extends StatelessWidget {
  final Map<String, int> zoneCount;

  const ZoneBarChart({
    Key? key,
    required this.zoneCount,
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
    final List<_ZoneData> data = zoneCount.entries
        .map((e) => _ZoneData(e.key, e.value, _extractZoneNumber(e.key)))
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));

    final hasData = data.isNotEmpty && data.any((e) => e.value > 0);
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
            _buildHeader('Households by Zone', '$total total'),
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

  FlTitlesData _buildTitles(List<_ZoneData> data, double maxY) {
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
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= data.length) return const Text('');
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                data[index].zone,
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
            Icon(Icons.location_off, size: 32, color: Colors.grey),
            SizedBox(height: 4),
            Text('No zone data available', style: TextStyle(color: Colors.grey, fontSize: 11)),
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
            Icon(Icons.location_pin, size: 18, color: const Color(0xFF7B1FA2)),
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
            color: const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF7B1FA2)),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<_ZoneData> data) {
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
            borderSide: const BorderSide(color: Color(0xFF9C27B0), width: 2),
          ),
        ],
        showingTooltipIndicators: item.value > 0 ? [0] : [],
      );
    }).toList();
  }

  int _extractZoneNumber(String zone) {
    final match = RegExp(r'(\d+)').firstMatch(zone);
    if (match != null) return int.parse(match.group(1)!);
    
    final letterMatch = RegExp(r'Zone\s+([A-Z])', caseSensitive: false).firstMatch(zone);
    if (letterMatch != null) {
      return letterMatch.group(1)!.toUpperCase().codeUnitAt(0) - 64;
    }
    
    return 999;
  }
}

class _ZoneData {
  final String zone;
  final int value;
  final int number;
  _ZoneData(this.zone, this.value, this.number);
}