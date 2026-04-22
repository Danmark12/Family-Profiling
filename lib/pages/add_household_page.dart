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

bool get _isFormValid {
  // REQUIRED TEXT FIELDS
  if (zone.text.trim().isEmpty) return false;
  if (male.text.trim().isEmpty) return false;
  if (female.text.trim().isEmpty) return false;
  if (families.text.trim().isEmpty) return false;
  if (immunized.text.trim().isEmpty) return false;

  // Father / Mother conditional validation
  if (!noFather && father.text.trim().isEmpty) return false;
  if (!noMother && mother.text.trim().isEmpty) return false;

  // DROPDOWNS (IMPORTANT)
  if (toilet == null) return false;
  if (garbage == null) return false;
  if (water == null) return false;
  if (food == null) return false;
  if (dwellingType == null) return false;

  return true;
}


  void _calculateTotal() {
    total.text =
        ((int.tryParse(male.text) ?? 0) + (int.tryParse(female.text) ?? 0))
            .toString();
  }

  int _getAgeGroupTotal() {
  return (int.tryParse(i0_5.text) ?? 0) +
      (int.tryParse(i6_11.text) ?? 0) +
      (int.tryParse(c12_23.text) ?? 0) +
      (int.tryParse(c24_59.text) ?? 0) +
      (int.tryParse(a5_9.text) ?? 0) +
      (int.tryParse(a10_19.text) ?? 0) +
      (int.tryParse(a20_59.text) ?? 0) +
      (int.tryParse(a60.text) ?? 0);
}

void _limitAgeInput(TextEditingController currentController) {
  int totalMembers = int.tryParse(total.text) ?? 0;

  // Get total EXCEPT current field
  int othersTotal =
      _getAgeGroupTotal() - (int.tryParse(currentController.text) ?? 0);

  int allowed = totalMembers - othersTotal;

  int currentValue = int.tryParse(currentController.text) ?? 0;

  if (currentValue > allowed) {
    currentController.text = allowed < 0 ? "0" : allowed.toString();
    currentController.selection = TextSelection.fromPosition(
      TextPosition(offset: currentController.text.length),
    );
  }
}

bool _shouldDisableField(TextEditingController controller) {
  int totalMembers = int.tryParse(total.text) ?? 0;
  int currentTotal = _getAgeGroupTotal();

  // If total already reached AND this field is empty → disable
  if (currentTotal >= totalMembers && (int.tryParse(controller.text) ?? 0) == 0) {
    return true;
  }

  return false;
}

bool _isAgeGroupValid() {
  int totalMembers = int.tryParse(total.text) ?? 0;
  int ageTotal = _getAgeGroupTotal();

  return totalMembers == ageTotal;
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
      "College Graduate",
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
    "Household No.  $householdNo",
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
              title: const Text("IPs"),
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
            _field("Name of father", father,
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
            _field("Name of mother", mother,
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
            _field("Total members", total, readOnly: true),
            _field("No. of families", families),
            _field("No. of fully immunized children", immunized),

            const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text(
    "Age Group",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  ),
),           
_field("Infants 0-5 months old", i0_5,
    disabled: _shouldDisableField(i0_5)),

_field("Infants 6-11 months old", i6_11,
    disabled: _shouldDisableField(i6_11)),

_field("Preschool 12-23 months old", c12_23,
    disabled: _shouldDisableField(c12_23)),

_field("Preschool 24-59 months old", c24_59,
    disabled: _shouldDisableField(c24_59)),

_field("5-9 years old", a5_9,
    disabled: _shouldDisableField(a5_9)),

_field("10-19 years old", a10_19,
    disabled: _shouldDisableField(a10_19)),

_field("20-59 years old", a20_59,
    disabled: _shouldDisableField(a20_59)),

_field("60 years old and above", a60,
    disabled: _shouldDisableField(a60)),
            _field("PWD", pwd),

const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text(
    "Women Status",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  ),
),            _field("Pregnant 19 bellow", preg19),
            _field("Pregnant 20 above", preg20),
            _field("Lactating", lactating),

const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text(
    "IYCF",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  ),
),            _field("0-5 months exclusive breastfeeding", exclusive),
            _field("0-5 months mixed feeding", mixed),
            _field("0-5 months bottle feeding", bottle),
            _field("6-12 complementary feeding", complementary),

const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text(
    "Preschool children nutritional status",
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
                ["Concrete","Semi Concrete", "Wooden", "Nipa Bamboo House", "Barong-Barong", "Makeshift"],
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
backgroundColor: _isFormValid
    ? Colors.transparent
    : Colors.grey.shade300,
    

                          foregroundColor: Colors.black,       // text color
        elevation: 6, // ✅ black shadow strength
        shadowColor: Colors.black,            
side: BorderSide(
  color: _isFormValid ? Colors.black : Colors.grey,
), 
                      
                      shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(5), // 👈 THIS controls curve
),
                               // remove shadow
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, ),

                ),
onPressed: _isFormValid
    ? () async {
if (!_isFormValid) return;

if (!_isAgeGroupValid()) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Age group total must equal total members"),
    ),
  );
  return;
}

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
                }
                    : null,    
  
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
    {bool readOnly = false, TextInputType? type, bool disabled = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      readOnly: readOnly || disabled,
      keyboardType: type ?? TextInputType.number,
      onChanged: (_) {
        _limitAgeInput(controller); // ✅ ADD THIS LINE
        setState(() {});
      },
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