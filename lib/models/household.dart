// lib/models/household.dart
class Household {
  final int? id;
  final int householdNo;

  final String? zone;
  final String? barangay;

  final int fourPs;
  final int indigenousPeople;
  final int iodizedSalt;

  final String? fatherName;
  final String? fatherOccupation;
  final String? fatherEducation;

  final String? motherName;
  final String? motherOccupation;
  final String? motherEducation;

  final int? male;
  final int? female;
  final int? total;
  final int? families;
  final int? fullyImmunized;

  final int? exclusive;
  final int? mixed;
  final int? bottleFed;
  final int? complementary;

  final int? preg19;
  final int? preg20;
  final int? lactating;

  final int? infant0to5;
  final int? infant6to11;
  final int? child12to23;
  final int? child24to59;
  final int? age5to9;
  final int? age10to19;
  final int? age20to59;
  final int? age60above;
  final int? pwd;

  final int? severelyUnderweight;
  final int? underweight;
  final int? normal;
  final int? severelyWasted;
  final int? wasted;
  final int? overweight;
  final int? obese;
  final int? severelyStunted;
  final int? stunted;

  final String? toilet;
  final String? garbage;
  final String? water;
  final String? food;
  final String? dwellingType;

  Household({
    this.id,
    required this.householdNo,

    this.zone,
    this.barangay,

    required this.fourPs,
    required this.indigenousPeople,
    required this.iodizedSalt,

    this.fatherName,
    this.fatherOccupation,
    this.fatherEducation,

    this.motherName,
    this.motherOccupation,
    this.motherEducation,

    this.male,
    this.female,
    this.total,
    this.families,
    this.fullyImmunized,

    this.exclusive,
    this.mixed,
    this.bottleFed,
    this.complementary,

    this.preg19,
    this.preg20,
    this.lactating,

    this.infant0to5,
    this.infant6to11,
    this.child12to23,
    this.child24to59,
    this.age5to9,
    this.age10to19,
    this.age20to59,
    this.age60above,
    this.pwd,

    this.severelyUnderweight,
    this.underweight,
    this.normal,
    this.severelyWasted,
    this.wasted,
    this.overweight,
    this.obese,
    this.severelyStunted,
    this.stunted,

    this.toilet,
    this.garbage,
    this.water,
    this.food,
    this.dwellingType,
  });

  /// Convert object → Map (for DB insert)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "householdNo": householdNo,

      "zone": zone,
      "barangay": barangay,

      "fourPs": fourPs,
      "indigenousPeople": indigenousPeople,
      "iodizedSalt": iodizedSalt,

      "fatherName": fatherName,
      "fatherOccupation": fatherOccupation,
      "fatherEducation": fatherEducation,

      "motherName": motherName,
      "motherOccupation": motherOccupation,
      "motherEducation": motherEducation,

      "male": male,
      "female": female,
      "total": total,
      "families": families,
      "fullyImmunized": fullyImmunized,

      "exclusive": exclusive,
      "mixed": mixed,
      "bottleFed": bottleFed,
      "complementary": complementary,

      "preg19": preg19,
      "preg20": preg20,
      "lactating": lactating,

      "infant0to5": infant0to5,
      "infant6to11": infant6to11,
      "child12to23": child12to23,
      "child24to59": child24to59,
      "age5to9": age5to9,
      "age10to19": age10to19,
      "age20to59": age20to59,
      "age60above": age60above,
      "pwd": pwd,

      "severelyUnderweight": severelyUnderweight,
      "underweight": underweight,
      "normal": normal,
      "severelyWasted": severelyWasted,
      "wasted": wasted,
      "overweight": overweight,
      "obese": obese,
      "severelyStunted": severelyStunted,
      "stunted": stunted,

      "toilet": toilet,
      "garbage": garbage,
      "water": water,
      "food": food,
      "dwellingType": dwellingType,
    };
  }

  /// Convert Map → Object (for reading DB later)
  factory Household.fromMap(Map<String, dynamic> map) {
    return Household(
      id: map['id'],
      householdNo: map['householdNo'],

      zone: map['zone'],
      barangay: map['barangay'],

      fourPs: map['fourPs'],
      indigenousPeople: map['indigenousPeople'],
      iodizedSalt: map['iodizedSalt'],

      fatherName: map['fatherName'],
      fatherOccupation: map['fatherOccupation'],
      fatherEducation: map['fatherEducation'],

      motherName: map['motherName'],
      motherOccupation: map['motherOccupation'],
      motherEducation: map['motherEducation'],

      male: map['male'],
      female: map['female'],
      total: map['total'],
      families: map['families'],
      fullyImmunized: map['fullyImmunized'],

      exclusive: map['exclusive'],
      mixed: map['mixed'],
      bottleFed: map['bottleFed'],
      complementary: map['complementary'],

      preg19: map['preg19'],
      preg20: map['preg20'],
      lactating: map['lactating'],

      infant0to5: map['infant0to5'],
      infant6to11: map['infant6to11'],
      child12to23: map['child12to23'],
      child24to59: map['child24to59'],
      age5to9: map['age5to9'],
      age10to19: map['age10to19'],
      age20to59: map['age20to59'],
      age60above: map['age60above'],
      pwd: map['pwd'],

      severelyUnderweight: map['severelyUnderweight'],
      underweight: map['underweight'],
      normal: map['normal'],
      severelyWasted: map['severelyWasted'],
      wasted: map['wasted'],
      overweight: map['overweight'],
      obese: map['obese'],
      severelyStunted: map['severelyStunted'],
      stunted: map['stunted'],

      toilet: map['toilet'],
      garbage: map['garbage'],
      water: map['water'],
      food: map['food'],
      dwellingType: map['dwellingType'],
    );
  }
}