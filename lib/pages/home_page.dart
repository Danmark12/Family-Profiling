// lib/pages/home_page.dart (UPDATED with overweight & obese)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/config.dart';
import '../services/dashboard_service.dart';
import '../widgets/kpi_card.dart';
import '../widgets/nutrition_bar_chart.dart';
import '../widgets/gender_donut_chart.dart';
import '../widgets/age_bar_chart.dart';
import '../widgets/zone_bar_chart.dart';
import '../widgets/feeding_bar_chart.dart';
import '../widgets/immunization_donut_chart.dart';
import '../widgets/recent_households_table.dart';
import 'settings.dart';
import 'barangay_household.dart';
import 'consolidated.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DashboardService _dashboardService = DashboardService();
  DashboardData? _dashboardData;
  bool _isLoading = true;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');

    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final data = await _dashboardService.getDashboardData(userId!);
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _isLoading = true;
    });
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 50,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _refreshDashboard,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            onPressed: () {
              if (userId == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(currentUserId: userId!),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dashboardData == null
              ? const Center(child: Text('No data available'))
              : RefreshIndicator(
                  onRefresh: _refreshDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================= KPI ROW 1 =================
                        Row(
                          children: [
                            Expanded(
                              child: KPICard(
                                title: 'Households',
                                value: _dashboardData!.totalHouseholds,
                                icon: Icons.house_outlined,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: KPICard(
                                title: 'Population',
                                value: _dashboardData!.totalPopulation,
                                icon: Icons.people_outline,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // ================= KPI ROW 2 =================
                        Row(
                          children: [
                            Expanded(
                              child: KPICard(
                                title: 'Malnourished',
                                value: _dashboardData!.malnourishedChildren,
                                icon: Icons.health_and_safety,
                                color: Colors.red.shade700,
                                subtitle: _dashboardData!.totalChildrenUnder5 > 0
                                    ? '${_dashboardData!.malnourishedPercentage}%'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: KPICard(
                                title: 'Pregnant',
                                value: _dashboardData!.pregnant,
                                icon: Icons.pregnant_woman,
                                color: Colors.pink.shade700,
                                subtitle: _dashboardData!.teenPregnant > 0
                                    ? '${_dashboardData!.teenPregnant} teens'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // ================= KPI ROW 3 =================
                        Row(
                          children: [
                            Expanded(
                              child: KPICard(
                                title: '4Ps',
                                value: _dashboardData!.fourPs,
                                icon: Icons.card_giftcard,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: KPICard(
                                title: 'PWDs',
                                value: _dashboardData!.pwd,
                                icon: Icons.accessibility_new,
                                color: Colors.purple.shade700,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // ================= NUTRITION CHART (UPDATED with ALL indicators) =================
                        NutritionBarChart(
                          severelyUnderweight: _dashboardData!.severelyUnderweight,
                          underweight: _dashboardData!.underweight,
                          normal: _dashboardData!.normal,
                          severelyWasted: _dashboardData!.severelyWasted,
                          wasted: _dashboardData!.wasted,
                          overweight: _dashboardData!.overweight,      // ADDED
                          obese: _dashboardData!.obese,                // ADDED
                          severelyStunted: _dashboardData!.severelyStunted,
                          stunted: _dashboardData!.stunted,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // ================= GENDER & AGE (STACK ON SMALL SCREENS) =================
                        if (isSmallScreen) ...[
                          GenderDonutChart(
                            male: _dashboardData!.totalMale,
                            female: _dashboardData!.totalFemale,
                          ),
                          const SizedBox(height: 12),
                          AgeBarChart(
                            age0to4: _dashboardData!.age0to4,
                            age5to9: _dashboardData!.age5to9,
                            age10to19: _dashboardData!.age10to19,
                            age20to59: _dashboardData!.age20to59,
                            age60plus: _dashboardData!.age60plus,
                          ),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: GenderDonutChart(
                                  male: _dashboardData!.totalMale,
                                  female: _dashboardData!.totalFemale,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AgeBarChart(
                                  age0to4: _dashboardData!.age0to4,
                                  age5to9: _dashboardData!.age5to9,
                                  age10to19: _dashboardData!.age10to19,
                                  age20to59: _dashboardData!.age20to59,
                                  age60plus: _dashboardData!.age60plus,
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        const SizedBox(height: 12),
                        
                        // ================= ZONE CHART =================
                        ZoneBarChart(zoneCount: _dashboardData!.zoneCount),
                        
                        const SizedBox(height: 12),
                        
                        // ================= FEEDING & IMMUNIZATION =================
                        if (isSmallScreen) ...[
                          FeedingBarChart(
                            exclusive: _dashboardData!.exclusive,
                            mixed: _dashboardData!.mixed,
                            bottleFed: _dashboardData!.bottleFed,
                            complementary: _dashboardData!.complementary,
                          ),
                          const SizedBox(height: 12),
                          ImmunizationDonutChart(
                            fullyImmunized: _dashboardData!.fullyImmunized,
                            totalChildren: _dashboardData!.totalChildren,
                          ),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: FeedingBarChart(
                                  exclusive: _dashboardData!.exclusive,
                                  mixed: _dashboardData!.mixed,
                                  bottleFed: _dashboardData!.bottleFed,
                                  complementary: _dashboardData!.complementary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ImmunizationDonutChart(
                                  fullyImmunized: _dashboardData!.fullyImmunized,
                                  totalChildren: _dashboardData!.totalChildren,
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // ================= RECENT HOUSEHOLDS =================
                        RecentHouseholdsTable(
                          households: _dashboardData!.recentHouseholds,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // ================= REPORTS SECTION =================
                        const Text(
                          "Reports",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        _reportItem(
                          icon: Icons.table_chart_outlined,
                          title: "Barangay Household Table",
                          subtitle: "View detailed household records",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BarangayHouseholdPage(),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 8),
                        
                        _reportItem(
                          icon: Icons.analytics_outlined,
                          title: "Consolidated Report",
                          subtitle: "Summary and analytics",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ConsolidatedReportPage(),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ================= REPORT ITEM =================
  Widget _reportItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        leading: Icon(icon, color: const Color.fromARGB(255, 14, 27, 15), size: 22),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Color.fromARGB(255, 7, 19, 7),
        ),
        onTap: onTap,
      ),
    );
  }
}