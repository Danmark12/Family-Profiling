// lib/models/household.dart
class Household {
  int? id; // auto-incremented in SQLite
  int householdNo;

  // DROPDOWNS / TEXT
  String? barangay;
  String? occupation;
  String? education;
  String? toilet;
  String? water;
  String? food;
  String? householdHead;

  // NUMERIC FIELDS
  int? zone;
  int? male;
  int? female;
  int? total;
  int? families;
  int? infantsComplementary;
  int? pregnant;
  int? lactating;
  int? infant0to5;
  int? infant6to11;
  int? infant12to23;
  int? infant24to59;
  int? underweightSevere;
  int? underweight;
  int? normal;
  int? wastedSevere;
  int? wasted;
  int? overweight;
  int? obese;
  int? stuntedSevere;
  int? stunted;

  // BOOLEAN FIELDS
  bool iodizedSalt;
  bool ifr;

  Household({
    this.id,
    required this.householdNo,
    this.barangay,
    this.occupation,
    this.education,
    this.toilet,
    this.water,
    this.food,
    this.zone,
    this.householdHead,
    this.male,
    this.female,
    this.total,
    this.families,
    this.pregnant,
    this.lactating,
    this.infant0to5,
    this.infant6to11,
    this.infant12to23,
    this.infant24to59,
    this.underweightSevere,
    this.underweight,
    this.normal,
    this.wastedSevere,
    this.wasted,
    this.overweight,
    this.obese,
    this.stuntedSevere,
    this.stunted,
    this.iodizedSalt = false,
    this.ifr = false,
    this.infantsComplementary,
  });

  // Convert Household object to Map<String, dynamic> for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'householdNo': householdNo,
      'barangay': barangay,
      'occupation': occupation,
      'education': education,
      'toilet': toilet,
      'water': water,
      'food': food,
      'zone': zone,
      'householdHead': householdHead,
      'male': male,
      'female': female,
      'total': total,
      'families': families,
      'infantsComplementary': infantsComplementary,
      'pregnant': pregnant,
      'lactating': lactating,
      'infant0to5': infant0to5,
      'infant6to11': infant6to11,
      'infant12to23': infant12to23,
      'infant24to59': infant24to59,
      'underweightSevere': underweightSevere,
      'underweight': underweight,
      'normal': normal,
      'wastedSevere': wastedSevere,
      'wasted': wasted,
      'overweight': overweight,
      'obese': obese,
      'stuntedSevere': stuntedSevere,
      'stunted': stunted,
      'iodizedSalt': iodizedSalt ? 1 : 0,
      'ifr': ifr ? 1 : 0,
    };
  }

  // Create Household object from SQLite map
  factory Household.fromMap(Map<String, dynamic> map) {
    return Household(
      id: map['id'] as int?,
      householdNo: map['householdNo'] as int,
      barangay: map['barangay'] as String?,
      occupation: map['occupation'] as String?,
      education: map['education'] as String?,
      toilet: map['toilet'] as String?,
      water: map['water'] as String?,
      food: map['food'] as String?,
      zone: map['zone'] as int?,
      householdHead: map['householdHead'] as String?,
      male: map['male'] as int?,
      female: map['female'] as int?,
      total: map['total'] as int?,
      families: map['families'] as int?,
     infantsComplementary: map['infantsComplementary'] as int?,
      pregnant: map['pregnant'] as int?,
      lactating: map['lactating'] as int?,
      infant0to5: map['infant0to5'] as int?,
      infant6to11: map['infant6to11'] as int?,
      infant12to23: map['infant12to23'] as int?,
      infant24to59: map['infant24to59'] as int?,
      underweightSevere: map['underweightSevere'] as int?,
      underweight: map['underweight'] as int?,
      normal: map['normal'] as int?,
      wastedSevere: map['wastedSevere'] as int?,
      wasted: map['wasted'] as int?,
      overweight: map['overweight'] as int?,
      obese: map['obese'] as int?,
      stuntedSevere: map['stuntedSevere'] as int?,
      stunted: map['stunted'] as int?,
      iodizedSalt: map['iodizedSalt'] == 1,
      ifr: map['ifr'] == 1,
    );
  }
}