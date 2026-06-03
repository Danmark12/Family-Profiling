// lib/services/dashboard_service.dart
import '../db/config.dart';

class DashboardService {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<DashboardData> getDashboardData(int userId) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> households = await db.query(
      'households',
      where: 'archived = 0 AND userId = ?',
      whereArgs: [userId],
    );

    // Initialize aggregates
    int totalHouseholds = households.length;
    int totalPopulation = 0;
    int totalMale = 0;
    int totalFemale = 0;
    
    // Nutrition (ALL 9 indicators)
    int severelyWasted = 0;
    int wasted = 0;
    int severelyUnderweight = 0;
    int underweight = 0;
    int severelyStunted = 0;
    int stunted = 0;
    int overweight = 0;
    int obese = 0;
    int normal = 0;
    
    // Age groups
    int age0to4 = 0;
    int age5to9 = 0;
    int age10to19 = 0;
    int age20to59 = 0;
    int age60plus = 0;
    
    // Pregnancy & Lactating
    int pregnant = 0;
    int teenPregnant = 0;      // 19 and below
    int adultPregnant = 0;     // 20 and above
    int lactating = 0;
    
    // Feeding
    int exclusive = 0;
    int mixed = 0;
    int bottleFed = 0;
    int complementary = 0;
    
    // Immunization
    int fullyImmunized = 0;
    int totalChildren = 0;
    
    // Special groups
    int fourPs = 0;
    int ips = 0;
    int pwd = 0;
    int iodizedSalt = 0;
    
    // Zones
    Map<String, int> zoneCount = {};
    
    // Recent households
    List<Map<String, dynamic>> recentHouseholds = [];
    
    for (var h in households) {
      totalPopulation += (h['total'] as int?) ?? 0;
      totalMale += (h['male'] as int?) ?? 0;
      totalFemale += (h['female'] as int?) ?? 0;
      
      // Nutrition (ALL 9 indicators)
      severelyWasted += (h['severelyWasted'] as int?) ?? 0;
      wasted += (h['wasted'] as int?) ?? 0;
      severelyUnderweight += (h['severelyUnderweight'] as int?) ?? 0;
      underweight += (h['underweight'] as int?) ?? 0;
      severelyStunted += (h['severelyStunted'] as int?) ?? 0;
      stunted += (h['stunted'] as int?) ?? 0;
      overweight += (h['overweight'] as int?) ?? 0;
      obese += (h['obese'] as int?) ?? 0;
      normal += (h['normal'] as int?) ?? 0;
      
      // Age groups
      int infant0to5 = (h['infant0to5'] as int?) ?? 0;
      int infant6to11 = (h['infant6to11'] as int?) ?? 0;
      int child12to23 = (h['child12to23'] as int?) ?? 0;
      int child24to59 = (h['child24to59'] as int?) ?? 0;
      
      age0to4 += infant0to5 + infant6to11 + child12to23 + child24to59;
      age5to9 += (h['age5to9'] as int?) ?? 0;
      age10to19 += (h['age10to19'] as int?) ?? 0;
      age20to59 += (h['age20to59'] as int?) ?? 0;
      age60plus += (h['age60above'] as int?) ?? 0;
      
      // Pregnancy & Lactating
      int preg19 = (h['preg19'] as int?) ?? 0;
      int preg20 = (h['preg20'] as int?) ?? 0;
      int lactatingCount = (h['lactating'] as int?) ?? 0;
      
      pregnant += preg19 + preg20;
      teenPregnant += preg19;
      adultPregnant += preg20;
      lactating += lactatingCount;
      
      // Feeding
      exclusive += (h['exclusive'] as int?) ?? 0;
      mixed += (h['mixed'] as int?) ?? 0;
      bottleFed += (h['bottleFed'] as int?) ?? 0;
      complementary += (h['complementary'] as int?) ?? 0;
      
      // Immunization
      int immunized = (h['fullyImmunized'] as int?) ?? 0;
      fullyImmunized += immunized;
      totalChildren += infant0to5 + infant6to11 + child12to23 + child24to59;
      
      // Special groups
      fourPs += (h['fourPs'] as int?) ?? 0;
      ips += (h['indigenousPeople'] as int?) ?? 0;
      pwd += (h['pwd'] as int?) ?? 0;
      iodizedSalt += (h['iodizedSalt'] as int?) ?? 0;
      
      // Zone
      String zone = h['zone']?.toString() ?? 'Unknown';
      zoneCount[zone] = (zoneCount[zone] ?? 0) + 1;
    }
    
    // Get recent households (last 10)
    recentHouseholds = await db.query(
      'households',
      where: 'archived = 0 AND userId = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: 10,
    );
    
    // Update malnourished children to include ALL indicators except normal
    int malnourishedChildren = severelyWasted + wasted + severelyUnderweight + underweight + severelyStunted + stunted + overweight + obese;
    
    return DashboardData(
      totalHouseholds: totalHouseholds,
      totalPopulation: totalPopulation,
      malnourishedChildren: malnourishedChildren,
      pregnant: pregnant,
      teenPregnant: teenPregnant,
      adultPregnant: adultPregnant,
      lactating: lactating,
      fourPs: fourPs,
      ips: ips,
      pwd: pwd,
      totalMale: totalMale,
      totalFemale: totalFemale,
      severelyWasted: severelyWasted,
      wasted: wasted,
      severelyUnderweight: severelyUnderweight,
      underweight: underweight,
      severelyStunted: severelyStunted,
      stunted: stunted,
      overweight: overweight,
      obese: obese,
      normal: normal,
      age0to4: age0to4,
      age5to9: age5to9,
      age10to19: age10to19,
      age20to59: age20to59,
      age60plus: age60plus,
      exclusive: exclusive,
      mixed: mixed,
      bottleFed: bottleFed,
      complementary: complementary,
      fullyImmunized: fullyImmunized,
      totalChildren: totalChildren,
      iodizedSalt: iodizedSalt,
      zoneCount: zoneCount,
      recentHouseholds: recentHouseholds,
    );
  }
}

class DashboardData {
  final int totalHouseholds;
  final int totalPopulation;
  final int malnourishedChildren;
  final int pregnant;
  final int teenPregnant;
  final int adultPregnant;
  final int lactating;
  final int fourPs;
  final int ips;
  final int pwd;
  final int totalMale;
  final int totalFemale;
  final int severelyWasted;
  final int wasted;
  final int severelyUnderweight;
  final int underweight;
  final int severelyStunted;
  final int stunted;
  final int overweight;
  final int obese;
  final int normal;
  final int age0to4;
  final int age5to9;
  final int age10to19;
  final int age20to59;
  final int age60plus;
  final int exclusive;
  final int mixed;
  final int bottleFed;
  final int complementary;
  final int fullyImmunized;
  final int totalChildren;
  final int iodizedSalt;
  final Map<String, int> zoneCount;
  final List<Map<String, dynamic>> recentHouseholds;

  DashboardData({
    required this.totalHouseholds,
    required this.totalPopulation,
    required this.malnourishedChildren,
    required this.pregnant,
    required this.teenPregnant,
    required this.adultPregnant,
    required this.lactating,
    required this.fourPs,
    required this.ips,
    required this.pwd,
    required this.totalMale,
    required this.totalFemale,
    required this.severelyWasted,
    required this.wasted,
    required this.severelyUnderweight,
    required this.underweight,
    required this.severelyStunted,
    required this.stunted,
    required this.overweight,
    required this.obese,
    required this.normal,
    required this.age0to4,
    required this.age5to9,
    required this.age10to19,
    required this.age20to59,
    required this.age60plus,
    required this.exclusive,
    required this.mixed,
    required this.bottleFed,
    required this.complementary,
    required this.fullyImmunized,
    required this.totalChildren,
    required this.iodizedSalt,
    required this.zoneCount,
    required this.recentHouseholds,
  });
  
  int get malnourishedPercentage {
    if (totalChildrenUnder5 == 0) return 0;
    return (malnourishedChildren / totalChildrenUnder5 * 100).round();
  }
  
  int get totalChildrenUnder5 {
    return age0to4;
  }
  
  int get immunizationPercentage {
    if (totalChildren == 0) return 0;
    return (fullyImmunized / totalChildren * 100).round();
  }
}