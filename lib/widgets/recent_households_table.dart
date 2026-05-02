// lib/widgets/recent_households_table.dart (FINAL with correct navigation)
import 'package:flutter/material.dart';
import '../models/household.dart';  // your Household model
import '../pages/household_detail_page.dart';  // your detail page

class RecentHouseholdsTable extends StatelessWidget {
  final List<Map<String, dynamic>> households;

  const RecentHouseholdsTable({
    Key? key,
    required this.households,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Recent Households',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Text(
                  'Last 10',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (households.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No households found',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: households.length > 10 ? 10 : households.length,
                itemBuilder: (context, index) {
                  final h = households[index];
                  final nutritionRisk = _getNutritionRisk(h);
                  
                  return GestureDetector(
                    onTap: () {
                      _showHouseholdDetails(context, h);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: nutritionRisk.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: nutritionRisk.color.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: nutritionRisk.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getRiskIcon(nutritionRisk.level),
                              color: nutritionRisk.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Household #${h['householdNo']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        h['zone']?.toString() ?? 'No Zone',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(Icons.people_outline,
                                        size: 10, color: Colors.grey[600]),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${h['total'] ?? 0}',
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: nutritionRisk.color,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              nutritionRisk.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showHouseholdDetails(BuildContext context, Map<String, dynamic> householdMap) {
    // Convert map to Household object
    final household = Household.fromMap(householdMap);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.house, size: 24, color: Colors.green.shade700),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Household #${household.householdNo}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Created: ${household.formattedCreatedAt}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            _buildInfoSection('Location', [
                              _infoRow(Icons.location_on, 'Zone', household.zone ?? 'N/A'),
                              _infoRow(Icons.map, 'Barangay', household.barangay ?? 'N/A'),
                            ]),
                            const SizedBox(height: 12),
                            _buildInfoSection('Population', [
                              _infoRow(Icons.people, 'Total Members', '${household.total ?? 0}'),
                              _infoRow(Icons.male, 'Male', '${household.male ?? 0}'),
                              _infoRow(Icons.female, 'Female', '${household.female ?? 0}'),
                            ]),
                            const SizedBox(height: 12),
                            if ((household.preg19 ?? 0) > 0 || (household.preg20 ?? 0) > 0)
                              _buildInfoSection('Maternal Health', [
                                _infoRow(Icons.pregnant_woman, 'Pregnant Teens', '${household.preg19 ?? 0}'),
                                _infoRow(Icons.woman, 'Pregnant Adults', '${household.preg20 ?? 0}'),
                                _infoRow(Icons.medical_services, 'Lactating', '${household.lactating ?? 0}'),
                              ]),
                            const SizedBox(height: 12),
                            if (_hasNutritionIssues(household))
                              _buildInfoSection('Nutrition Status', _getNutritionDetails(household)),
                            const SizedBox(height: 12),
                            _buildInfoSection('Programs', [
                              _infoRow(Icons.card_giftcard, '4Ps Member', _boolText(household.fourPs)),
                              _infoRow(Icons.people_outline, 'Indigenous People', _boolText(household.indigenousPeople)),
                              _infoRow(Icons.accessibility_new, 'PWD', '${household.pwd ?? 0}'),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // TWO BUTTONS: "View Full Details" (green) and "Close" (transparent)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // close bottom sheet
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HouseholdDetailPage(hh: household),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'View Full Details',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              side: BorderSide(color: Colors.grey.shade300),
                              backgroundColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ================= HELPER WIDGETS =================
  Widget _buildInfoSection(String title, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _boolText(int? value) {
    if (value == null) return "No";
    return value == 1 ? "Yes" : "No";
  }

  // ================= NUTRITION LOGIC =================
  NutritionRisk _getNutritionRisk(Map<String, dynamic> household) {
    int severelyWasted = household['severelyWasted'] ?? 0;
    int wasted = household['wasted'] ?? 0;
    int severelyUnderweight = household['severelyUnderweight'] ?? 0;
    int underweight = household['underweight'] ?? 0;
    int severelyStunted = household['severelyStunted'] ?? 0;
    int stunted = household['stunted'] ?? 0;
    int overweight = household['overweight'] ?? 0;
    int obese = household['obese'] ?? 0;

    if (severelyWasted > 0 || severelyUnderweight > 0 || severelyStunted > 0) {
      return NutritionRisk('Critical', Colors.red.shade700, 'critical');
    }
    if (wasted > 0 || underweight > 0 || stunted > 0 || obese > 0) {
      return NutritionRisk('At Risk', Colors.orange.shade700, 'risk');
    }
    if (overweight > 0) {
      return NutritionRisk('Monitor', Colors.amber.shade700, 'monitor');
    }
    return NutritionRisk('Normal', Colors.green.shade600, 'normal');
  }

  bool _hasNutritionIssues(Household household) {
    return (household.severelyWasted ?? 0) > 0 ||
           (household.wasted ?? 0) > 0 ||
           (household.severelyUnderweight ?? 0) > 0 ||
           (household.underweight ?? 0) > 0 ||
           (household.severelyStunted ?? 0) > 0 ||
           (household.stunted ?? 0) > 0 ||
           (household.overweight ?? 0) > 0 ||
           (household.obese ?? 0) > 0;
  }

  List<Widget> _getNutritionDetails(Household household) {
    List<Widget> details = [];
    if ((household.severelyWasted ?? 0) > 0) {
      details.add(_infoRow(Icons.warning, 'Severely Wasted', '${household.severelyWasted}', color: Colors.red));
    }
    if ((household.wasted ?? 0) > 0) {
      details.add(_infoRow(Icons.warning, 'Wasted', '${household.wasted}', color: Colors.orange));
    }
    if ((household.severelyUnderweight ?? 0) > 0) {
      details.add(_infoRow(Icons.warning, 'Severely Underweight', '${household.severelyUnderweight}', color: Colors.red));
    }
    if ((household.underweight ?? 0) > 0) {
      details.add(_infoRow(Icons.warning, 'Underweight', '${household.underweight}', color: Colors.orange));
    }
    if ((household.severelyStunted ?? 0) > 0) {
      details.add(_infoRow(Icons.height, 'Severely Stunted', '${household.severelyStunted}', color: Colors.red));
    }
    if ((household.stunted ?? 0) > 0) {
      details.add(_infoRow(Icons.height, 'Stunted', '${household.stunted}', color: Colors.orange));
    }
    if ((household.overweight ?? 0) > 0) {
      details.add(_infoRow(Icons.fitness_center, 'Overweight', '${household.overweight}', color: Colors.amber));
    }
    if ((household.obese ?? 0) > 0) {
      details.add(_infoRow(Icons.fitness_center, 'Obese', '${household.obese}', color: Colors.orange));
    }
    if (details.isEmpty) {
      details.add(_infoRow(Icons.check_circle, 'Status', 'Normal', color: Colors.green));
    }
    return details;
  }

  IconData _getRiskIcon(String level) {
    switch (level) {
      case 'critical':
        return Icons.warning_amber_rounded;
      case 'risk':
        return Icons.info_outline;
      case 'monitor':
        return Icons.timeline;
      default:
        return Icons.check_circle_outline;
    }
  }
}

class NutritionRisk {
  final String label;
  final Color color;
  final String level;
  NutritionRisk(this.label, this.color, this.level);
}