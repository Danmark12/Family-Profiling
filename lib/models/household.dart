// lib/models/household.dart
class Household {
  int? id;
  int householdNo;
  String name;
  String purok;
  String occupation;
  String education;
  int male;
  int female;
  int total;
  int pregnant;
  int lactating;
  int su;
  int uw;
  int nw;
  int sw;
  int w;
  int ow;
  int ob;
  int ss;
  int st;
  int inf0_5;
  int inf6_11;
  int pre0_23;
  int pre12_59;
  int pre24_59;
  int breastfed;
  int dewormed;
  int fic;
  String iodized;
  String eatery;
  int archived;

  Household({
    this.id,
    required this.householdNo,
    required this.name,
    required this.purok,
    required this.occupation,
    required this.education,
    required this.male,
    required this.female,
    required this.total,
    required this.pregnant,
    required this.lactating,
    required this.su,
    required this.uw,
    required this.nw,
    required this.sw,
    required this.w,
    required this.ow,
    required this.ob,
    required this.ss,
    required this.st,
    required this.inf0_5,
    required this.inf6_11,
    required this.pre0_23,
    required this.pre12_59,
    required this.pre24_59,
    required this.breastfed,
    required this.dewormed,
    required this.fic,
    required this.iodized,
    required this.eatery,
    this.archived = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'householdNo': householdNo,
      'name': name,
      'purok': purok,
      'occupation': occupation,
      'education': education,
      'male': male,
      'female': female,
      'total': total,
      'pregnant': pregnant,
      'lactating': lactating,
      'su': su,
      'uw': uw,
      'nw': nw,
      'sw': sw,
      'w': w,
      'ow': ow,
      'ob': ob,
      'ss': ss,
      'st': st,
      'inf0_5': inf0_5,
      'inf6_11': inf6_11,
      'pre0_23': pre0_23,
      'pre12_59': pre12_59,
      'pre24_59': pre24_59,
      'breastfed': breastfed,
      'dewormed': dewormed,
      'fic': fic,
      'iodized': iodized,
      'eatery': eatery,
      'archived': archived,
    };
  }

  factory Household.fromMap(Map<String, dynamic> map) {
    return Household(
      id: map['id'],
      householdNo: map['householdNo'],
      name: map['name'],
      purok: map['purok'],
      occupation: map['occupation'],
      education: map['education'],
      male: map['male'],
      female: map['female'],
      total: map['total'],
      pregnant: map['pregnant'],
      lactating: map['lactating'],
      su: map['su'],
      uw: map['uw'],
      nw: map['nw'],
      sw: map['sw'],
      w: map['w'],
      ow: map['ow'],
      ob: map['ob'],
      ss: map['ss'],
      st: map['st'],
      inf0_5: map['inf0_5'],
      inf6_11: map['inf6_11'],
      pre0_23: map['pre0_23'],
      pre12_59: map['pre12_59'],
      pre24_59: map['pre24_59'],
      breastfed: map['breastfed'],
      dewormed: map['dewormed'],
      fic: map['fic'],
      iodized: map['iodized'],
      eatery: map['eatery'],
      archived: map['archived'],
    );
  }
}