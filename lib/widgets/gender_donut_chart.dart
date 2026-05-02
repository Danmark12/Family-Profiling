// lib/widgets/gender_donut_chart.dart (tap shows number on chart, no dialog)
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GenderDonutChart extends StatefulWidget {
  final int male;
  final int female;

  const GenderDonutChart({
    Key? key,
    required this.male,
    required this.female,
  }) : super(key: key);

  @override
  State<GenderDonutChart> createState() => _GenderDonutChartState();
}

class _GenderDonutChartState extends State<GenderDonutChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final total = widget.male + widget.female;
    final malePercent = total > 0 ? (widget.male / total * 100).toStringAsFixed(1) : '0';
    final femalePercent = total > 0 ? (widget.female / total * 100).toStringAsFixed(1) : '0';

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
                      value: widget.male.toDouble(),
                      title: _touchedIndex == 0 ? '${widget.male}' : '$malePercent%',
                      color: Colors.blue.shade400,
                      radius: 45,
                      titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      showTitle: true,
                    ),
                    PieChartSectionData(
                      value: widget.female.toDouble(),
                      title: _touchedIndex == 1 ? '${widget.female}' : '$femalePercent%',
                      color: Colors.pink.shade400,
                      radius: 45,
                      titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      showTitle: true,
                    ),
                  ],
                  sectionsSpace: 1,
                  centerSpaceRadius: 25,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      if (event is FlTapUpEvent && pieTouchResponse != null) {
                        final touchedSection = pieTouchResponse.touchedSection;
                        if (touchedSection != null) {
                          final sectionIndex = touchedSection.touchedSectionIndex;
                          setState(() {
                            _touchedIndex = sectionIndex;
                          });
                          Future.delayed(const Duration(milliseconds: 800), () {
                            if (mounted) {
                              setState(() {
                                _touchedIndex = null;
                              });
                            }
                          });
                        } else {
                          setState(() {
                            _touchedIndex = null;
                          });
                        }
                      }
                    },
                  ),
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
                  'Total: $total',
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