// lib/widgets/immunization_donut_chart.dart (tap shows number on chart)
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ImmunizationDonutChart extends StatefulWidget {
  final int fullyImmunized;
  final int totalChildren;

  const ImmunizationDonutChart({
    Key? key,
    required this.fullyImmunized,
    required this.totalChildren,
  }) : super(key: key);

  @override
  State<ImmunizationDonutChart> createState() => _ImmunizationDonutChartState();
}

class _ImmunizationDonutChartState extends State<ImmunizationDonutChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final notImmunized = widget.totalChildren - widget.fullyImmunized;
    final immunizedPercent = widget.totalChildren > 0 
        ? (widget.fullyImmunized / widget.totalChildren * 100).toStringAsFixed(1) 
        : '0';
    final notImmunizedPercent = widget.totalChildren > 0 
        ? (notImmunized / widget.totalChildren * 100).toStringAsFixed(1) 
        : '0';

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
              'Immunization Coverage',
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
                      value: widget.fullyImmunized.toDouble(),
                      title: _touchedIndex == 0 
                          ? '${widget.fullyImmunized}' 
                          : '$immunizedPercent%',
                      color: Colors.green.shade500,
                      radius: 45,
                      titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      showTitle: true,
                    ),
                    PieChartSectionData(
                      value: notImmunized.toDouble(),
                      title: _touchedIndex == 1 
                          ? '$notImmunized' 
                          : '$notImmunizedPercent%',
                      color: Colors.red.shade400,
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
                          // Reset after a short delay to show number then revert to percentage
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
                _buildLegend('Fully Immunized', Colors.green.shade500),
                const SizedBox(width: 12),
                _buildLegend('Not Fully', Colors.red.shade400),
                const SizedBox(width: 12),
                Text(
                  'Total: ${widget.totalChildren}',
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