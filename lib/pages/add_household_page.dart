// lib/pages/add_household_page.dart
import 'package:flutter/material.dart';
import '../db/config.dart';

class AddHouseholdPage extends StatefulWidget {
  const AddHouseholdPage({super.key});

  @override
  State<AddHouseholdPage> createState() => _AddHouseholdPageState();
}

class _AddHouseholdPageState extends State<AddHouseholdPage> {
  int householdNo = 1;

  // Dropdowns
  String? barangay, toilet, garbage, water, food, dwellingType;
  String? fatherOccupation, fatherEducation;
  String? motherOccupation, motherEducation;

  // Checkboxes
  bool fourPs = false;
  bool indigenousPeople = false;
  bool iodizedSalt = false;
  bool noFather = false;
  bool noMother = false;

  // Controllers
  final zone = TextEditingController();
  final father = TextEditingController();
  final mother = TextEditingController();

  final male = TextEditingController();
  final female = TextEditingController();
  final total = TextEditingController();
  final families = TextEditingController();
  final immunized = TextEditingController();

  final exclusive = TextEditingController();
  final mixed = TextEditingController();
  final bottle = TextEditingController();
  final complementary = TextEditingController();

  final preg19 = TextEditingController();
  final preg20 = TextEditingController();
  final lactating = TextEditingController();

  final i0_5 = TextEditingController();
  final i6_11 = TextEditingController();
  final c12_23 = TextEditingController();
  final c24_59 = TextEditingController();
  final a5_9 = TextEditingController();
  final a10_19 = TextEditingController();
  final a20_59 = TextEditingController();
  final a60 = TextEditingController();
  final pwd = TextEditingController();

  final su = TextEditingController();
  final uw = TextEditingController();
  final nw = TextEditingController();
  final sw = TextEditingController();
  final w = TextEditingController();
  final ow = TextEditingController();
  final ob = TextEditingController();
  final ss = TextEditingController();
  final st = TextEditingController();

  int? userId; // logged-in user ID

  @override
  void initState() {
    super.initState();
    _loadNo();
    _loadUserBarangay();

    male.addListener(_total);
    female.addListener(_total);
  }

  void _total() {
    total.text =
        ((int.tryParse(male.text) ?? 0) + (int.tryParse(female.text) ?? 0))
            .toString();
  }

  Future _loadNo() async {
    final last = await DBHelper.instance.getLastHouseholdNo();
    setState(() => householdNo = (last ?? 0) + 1);
  }

  Future<void> _loadUserBarangay() async {
    // TODO: replace with actual logged-in user ID from session/shared preferences
    userId = 1; // example for testing
    final user = await DBHelper.instance.getUserById(userId!);
    if (user != null) {
      setState(() {
        barangay = user['barangay'];
      });
    }
  }

  int? num(TextEditingController c) =>
      c.text.isEmpty ? null : int.tryParse(c.text);

  @override
  Widget build(BuildContext context) {
    // final barangays = [
    //   "Amoros","Bolisong","Cogon","Himaya","Hinigdaan","Kalabaylabay",
    //   "Molugan","Pedro S. Baculio","Poblacion","Quibonbon",
    //   "Sambulawan","San Francisco de Asis","Sinaloc","Taytay","Ulaliman"
    // ];

    final occupations = [
      "Private Employee","Government Employee","Self-Employed/Business Owner",
      "Farmer/Fisherfolk","Overseas Filipino Worker","Skilled Laborer",
      "Unemployed","Housewife/Househusband","Others","None"
    ];

    final educ = [
      "Elementary Level","Elementary Graduate","High School Level",
      "High School Graduate","College Level","Graduate","Vocational","Others"
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Family Profiling Form")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Household No.: $householdNo"),

          _field("Zone / Purok", zone),

          // 🔹 Barangay dropdown prefilled with user barangay
          // _drop(
          //   "Barangay",
          //   barangay,
          //   barangays,
          //   null, // user cannot change it
          //   disabled: true,
          // ),
          _field("Barangay", TextEditingController(text: barangay ?? ""), readOnly: true, type: TextInputType.text),

          CheckboxListTile(
              value: fourPs,
              onChanged: (v) => setState(() => fourPs = v!),
              title: const Text("4Ps")),
          CheckboxListTile(
              value: indigenousPeople,
              onChanged: (v) => setState(() => indigenousPeople = v!),
              title: const Text("Indigenous People")),

          const Text("Father"),
          CheckboxListTile(
            value: noFather,
            onChanged: (v) {
              setState(() {
                noFather = v!;
                if (noFather) {
                  father.clear();
                  fatherOccupation = null;
                  fatherEducation = null;
                }
              });
            },
            title: const Text("None"),
          ),
          _field("Name of Father", father,
              type: TextInputType.text, readOnly: noFather),
          _drop("Occupation", fatherOccupation, occupations,
              noFather ? null : (v) => setState(() => fatherOccupation = v),
              disabled: noFather),
          _drop("Educational Attainment", fatherEducation, educ,
              noFather ? null : (v) => setState(() => fatherEducation = v),
              disabled: noFather),

          const Text("Mother"),
          CheckboxListTile(
            value: noMother,
            onChanged: (v) {
              setState(() {
                noMother = v!;
                if (noMother) {
                  mother.clear();
                  motherOccupation = null;
                  motherEducation = null;
                }
              });
            },
            title: const Text("None"),
          ),
          _field("Name of Mother", mother,
              type: TextInputType.text, readOnly: noMother),
          _drop("Occupation", motherOccupation, occupations,
              noMother ? null : (v) => setState(() => motherOccupation = v),
              disabled: noMother),
          _drop("Educational Attainment", motherEducation, educ,
              noMother ? null : (v) => setState(() => motherEducation = v),
              disabled: noMother),

          const Text("Household Members"),
          _field("Male", male),
          _field("Female", female),
          _field("Total", total, readOnly: true),
          _field("Families", families),
          _field("Fully Immunized Children", immunized),

          const Text("IYCF"),
          _field("Exclusive", exclusive),
          _field("Mixed", mixed),
          _field("Bottle Fed", bottle),
          _field("Complementary Feeding", complementary),

          const Text("Women Status"),
          _field("Pregnant Below 19", preg19),
          _field("Pregnant 20+", preg20),
          _field("Lactating", lactating),

          const Text("Age Group"),
          _field("0-5 months", i0_5),
          _field("6-11 months", i6_11),
          _field("12-23 months", c12_23),
          _field("24-59 months", c24_59),
          _field("5-9", a5_9),
          _field("10-19", a10_19),
          _field("20-59", a20_59),
          _field("60+", a60),
          _field("PWD", pwd),

          const Text("Nutritional Status"),
          _field("Severely Underweight", su),
          _field("Underweight", uw),
          _field("Normal", nw),
          _field("Severely Wasted", sw),
          _field("Wasted", w),
          _field("Overweight", ow),
          _field("Obese", ob),
          _field("Severely Stunted", ss),
          _field("Stunted", st),

          const Text("Facilities"),
          _drop("Toilet Type", toilet,
              ["Water Sealed", "Antipolo", "Open Pit", "Shared", "No Toilet"],
              (v) => setState(() => toilet = v)),
          _drop("Garbage Disposal", garbage,
              ["Barangay Collector", "Compost Pit", "Burning", "Dumping"],
              (v) => setState(() => garbage = v)),
          _drop("Water Source", water,
              ["Pipe Water", "Deep Well", "Purified", "Shallow Well", "Artesian", "Spring"],
              (v) => setState(() => water = v)),
          _drop("Food Production", food,
              ["Vegetable Garden", "Poultry", "Fishpond", "No Garden"],
              (v) => setState(() => food = v)),
          _drop("Dwelling Type", dwellingType,
              ["Semi Concrete", "Wooden", "Nipa", "Barong", "Makeshift"],
              (v) => setState(() => dwellingType = v)),

          CheckboxListTile(
              value: iodizedSalt,
              onChanged: (v) => setState(() => iodizedSalt = v!),
              title: const Text("Uses Iodized Salt")),

          ElevatedButton(
            onPressed: () async {
              await DBHelper.instance.insertHousehold({
                "householdNo": householdNo,
                "zone": zone.text,
                "barangay": barangay,
                "fourPs": fourPs ? 1 : 0,
                "indigenousPeople": indigenousPeople ? 1 : 0,
                "iodizedSalt": iodizedSalt ? 1 : 0,
                "fatherName": father.text,
                "fatherOccupation": fatherOccupation,
                "fatherEducation": fatherEducation,
                "motherName": mother.text,
                "motherOccupation": motherOccupation,
                "motherEducation": motherEducation,
                "male": num(male),
                "female": num(female),
                "total": num(total),
                "families": num(families),
                "fullyImmunized": num(immunized),
                "exclusive": num(exclusive),
                "mixed": num(mixed),
                "bottleFed": num(bottle),
                "complementary": num(complementary),
                "preg19": num(preg19),
                "preg20": num(preg20),
                "lactating": num(lactating),
                "infant0to5": num(i0_5),
                "infant6to11": num(i6_11),
                "child12to23": num(c12_23),
                "child24to59": num(c24_59),
                "age5to9": num(a5_9),
                "age10to19": num(a10_19),
                "age20to59": num(a20_59),
                "age60above": num(a60),
                "pwd": num(pwd),
                "severelyUnderweight": num(su),
                "underweight": num(uw),
                "normal": num(nw),
                "severelyWasted": num(sw),
                "wasted": num(w),
                "overweight": num(ow),
                "obese": num(ob),
                "severelyStunted": num(ss),
                "stunted": num(st),
                "toilet": toilet,
                "garbage": garbage,
                "water": water,
                "food": food,
                "dwellingType": dwellingType,
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Saved Successfully")),
              );

              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ]),
      ),
    );
  }

  Widget _field(String l, TextEditingController c,
      {bool readOnly = false, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        readOnly: readOnly,
        keyboardType: type ?? TextInputType.number,
        decoration: InputDecoration(
          labelText: l,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _drop(String l, String? v, List<String> items,
      void Function(String?)? onChanged,
      {bool disabled = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l,
          border: const OutlineInputBorder(),
          suffixIcon: PopupMenuButton<String>(
            icon: const Icon(Icons.arrow_drop_down),
            enabled: !disabled,
            onSelected: onChanged,
            itemBuilder: (c) =>
                items.map((e) => PopupMenuItem(value: e, child: Text(e))).toList(),
          ),
        ),
        child: Text(v ?? "Select"),
      ),
    );
  }
}