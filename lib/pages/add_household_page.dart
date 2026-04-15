// lib/pages/add_household_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/config.dart';

class AddHouseholdPage extends StatefulWidget {
  const AddHouseholdPage({super.key});

  @override
  State<AddHouseholdPage> createState() => _AddHouseholdPageState();
}

class _AddHouseholdPageState extends State<AddHouseholdPage> {
  int householdNo = 1;

  // Dropdowns / Selections
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

  late final TextEditingController barangayController;

  @override
  void initState() {
    super.initState();
    barangayController = TextEditingController();
    _loadUserBarangay();
    male.addListener(_calculateTotal);
    female.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    total.text =
        ((int.tryParse(male.text) ?? 0) + (int.tryParse(female.text) ?? 0))
            .toString();
  }

  Future<void> _loadUserBarangay() async {
    final prefs = await SharedPreferences.getInstance();
    final int? storedUserId = prefs.getInt('userId');
    if (storedUserId == null) return;

    userId = storedUserId;

    final user = await DBHelper.instance.getUserById(userId!);
    if (user != null) {
      setState(() {
        barangay = user['barangay'];
        barangayController.text = barangay ?? "";
      });
    }

    await _loadHouseholdNo();
  }

  Future<void> _loadHouseholdNo() async {
    if (userId == null) return;
    final lastNo = await DBHelper.instance.getLastHouseholdNoByUser(userId!);
    setState(() => householdNo = (lastNo ?? 0) + 1);
  }

  int? _parseInt(TextEditingController c) =>
      c.text.isEmpty ? null : int.tryParse(c.text);

  @override
  Widget build(BuildContext context) {
    final occupations = [
      "Private Employee",
      "Government Employee",
      "Self-Employed/Business Owner",
      "Farmer/Fisherfolk",
      "Overseas Filipino Worker",
      "Skilled Laborer",
      "Unemployed",
      "Housewife/Househusband",
      "Others",
      "None"
    ];

    final educ = [
      "Elementary Level",
      "Elementary Graduate",
      "High School Level",
      "High School Graduate",
      "College Level",
      "Graduate",
      "Vocational",
      "Others"
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Family Profiling Form")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
Center(
  child: Text(
    "Household No.: $householdNo",
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    textAlign: TextAlign.center,
  ),
),
const SizedBox(height: 12),

            _field("Zone / Purok", zone),
            _field("Barangay", barangayController, readOnly: true),

            CheckboxListTile(
              value: fourPs,
              onChanged: (v) => setState(() => fourPs = v!),
              title: const Text("4Ps"),
            ),
            CheckboxListTile(
              value: indigenousPeople,
              onChanged: (v) => setState(() => indigenousPeople = v!),
              title: const Text("Indigenous People"),
            ),

const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text(
    "Father",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  ),
),            CheckboxListTile(
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

const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text(
    "Mother",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  ),
),            CheckboxListTile(
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

const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text(
    "Household Members",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  ),
),            _field("Male", male),
            _field("Female", female),
            _field("Total", total, readOnly: true),
            _field("Families", families),
            _field("Fully Immunized Children", immunized),

const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text(
    "IYCF",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  ),
),            _field("Exclusive", exclusive),
            _field("Mixed", mixed),
            _field("Bottle Fed", bottle),
            _field("Complementary Feeding", complementary),

const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text(
    "Women Status",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  ),
),            _field("Pregnant Below 19", preg19),
            _field("Pregnant 20+", preg20),
            _field("Lactating", lactating),

const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text(
    "Age Group",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  ),
),            _field("0-5 months", i0_5),
            _field("6-11 months", i6_11),
            _field("12-23 months", c12_23),
            _field("24-59 months", c24_59),
            _field("5-9", a5_9),
            _field("10-19", a10_19),
            _field("20-59", a20_59),
            _field("60+", a60),
            _field("PWD", pwd),

const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text(
    "Nutritional Status",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  ),
),            _field("Severely Underweight", su),
            _field("Underweight", uw),
            _field("Normal", nw),
            _field("Severely Wasted", sw),
            _field("Wasted", w),
            _field("Overweight", ow),
            _field("Obese", ob),
            _field("Severely Stunted", ss),
            _field("Stunted", st),

const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text(
    "Facilities",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  ),
),            _drop("Toilet Type", toilet,
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
                ["Concrete","Semi Concrete", "Wooden", "Nipa", "Barong", "Makeshift"],
                (v) => setState(() => dwellingType = v)),

            CheckboxListTile(
                value: iodizedSalt,
                onChanged: (v) => setState(() => iodizedSalt = v!),
                title: const Text("Uses Iodized Salt")),

            // Extra spacing before button
            const SizedBox(height: 20),

            // Full-width Save button
Center(
  child: SizedBox(
              width: 220,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // ✅ transparent
                      foregroundColor: Colors.black,       // text color
        elevation: 6, // ✅ black shadow strength
        shadowColor: Colors.black,            
                      side: const BorderSide(color: Colors.black),   
                      
                      shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(5), // 👈 THIS controls curve
),
                               // remove shadow
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, ),

                ),
                onPressed: () async {
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User not loaded.")),
                    );
                    return;
                  }

                  _calculateTotal();
                  String createdAt = DateTime.now().toIso8601String();

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
                    "male": _parseInt(male),
                    "female": _parseInt(female),
                    "total": _parseInt(total),
                    "families": _parseInt(families),
                    "fullyImmunized": _parseInt(immunized),
                    "exclusive": _parseInt(exclusive),
                    "mixed": _parseInt(mixed),
                    "bottleFed": _parseInt(bottle),
                    "complementary": _parseInt(complementary),
                    "preg19": _parseInt(preg19),
                    "preg20": _parseInt(preg20),
                    "lactating": _parseInt(lactating),
                    "infant0to5": _parseInt(i0_5),
                    "infant6to11": _parseInt(i6_11),
                    "child12to23": _parseInt(c12_23),
                    "child24to59": _parseInt(c24_59),
                    "age5to9": _parseInt(a5_9),
                    "age10to19": _parseInt(a10_19),
                    "age20to59": _parseInt(a20_59),
                    "age60above": _parseInt(a60),
                    "pwd": _parseInt(pwd),
                    "severelyUnderweight": _parseInt(su),
                    "underweight": _parseInt(uw),
                    "normal": _parseInt(nw),
                    "severelyWasted": _parseInt(sw),
                    "wasted": _parseInt(w),
                    "overweight": _parseInt(ow),
                    "obese": _parseInt(ob),
                    "severelyStunted": _parseInt(ss),
                    "stunted": _parseInt(st),
                    "toilet": toilet,
                    "garbage": garbage,
                    "water": water,
                    "food": food,
                    "dwellingType": dwellingType,
                    "created_at": createdAt,
                  }, userId!);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Saved Successfully")),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ),
),

            const SizedBox(height: 30), // extra padding at the bottom for scroll safety
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller,
      {bool readOnly = false, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: type ?? TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _drop(String label, String? value, List<String> items,
      void Function(String?)? onChanged,
      {bool disabled = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: disabled
              ? null
              : PopupMenuButton<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: onChanged,
                  itemBuilder: (c) =>
                      items.map((e) => PopupMenuItem(value: e, child: Text(e))).toList(),
                ),
        ),
        child: Text(value ?? "Select"),
      ),
    );
  }
}