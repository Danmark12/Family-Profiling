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



  
  final ScrollController _scrollController = ScrollController();
final Map<String, GlobalKey> _fieldKeys = {};

bool _submitted = false;

// Father/Mother error tracking
bool get _fatherValid {
  if (noFather) return true;

  return father.text.trim().isNotEmpty &&
      fatherOccupation != null &&
      fatherEducation != null;
}

bool get _motherValid {
  if (noMother) return true;

  return mother.text.trim().isNotEmpty &&
      motherOccupation != null &&
      motherEducation != null;
}
  int householdNo = 1;

  // Dropdowns / Selections
  String? barangay, toilet, water, dwellingType;
  List<String> garbage = [];
List<String> food = [];
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
if (garbage.isEmpty) return false;
  if (water == null) return false;
if (food.isEmpty) return false;
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
  controller: _scrollController,
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

_field("Zone / Purok", zone, keyName: "zone"),
_field("Barangay", barangayController, readOnly: true, keyName: "barangay"),

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

// ======================= FATHER =======================
const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text("Father",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
),

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

_field("Name of father", father,
    type: TextInputType.text,
    readOnly: noFather,
    keyName: "father_name"),

_drop("Occupation", fatherOccupation, occupations,
    noFather ? null : (v) => setState(() => fatherOccupation = v),
    disabled: noFather),

_drop("Educational Attainment", fatherEducation, educ,
    noFather ? null : (v) => setState(() => fatherEducation = v),
    disabled: noFather),

// ======================= MOTHER =======================
const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text("Mother",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
),

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

_field("Name of mother", mother,
    type: TextInputType.text,
    readOnly: noMother,
    keyName: "mother_name"),

_drop("Occupation", motherOccupation, occupations,
    noMother ? null : (v) => setState(() => motherOccupation = v),
    disabled: noMother),

_drop("Educational Attainment", motherEducation, educ,
    noMother ? null : (v) => setState(() => motherEducation = v),
    disabled: noMother),

// ======================= HOUSEHOLD MEMBERS =======================
const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text("Household Members",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
),

_field("Male", male, keyName: "male"),
_field("Female", female, keyName: "female"),
_field("Total members", total, readOnly: true, keyName: "total"),
_field("No. of families", families, keyName: "families"),
_field("Fully immunized children", immunized, keyName: "immunized"),

// ======================= AGE GROUP =======================
const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text("Age Group",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
),

_field("Infants 0-5 months old", i0_5, keyName: "i0_5",
    disabled: _shouldDisableField(i0_5)),

_field("Infants 6-11 months old", i6_11, keyName: "i6_11",
    disabled: _shouldDisableField(i6_11)),

_field("Preschool 12-23 months old", c12_23, keyName: "c12_23",
    disabled: _shouldDisableField(c12_23)),

_field("Preschool 24-59 months old", c24_59, keyName: "c24_59",
    disabled: _shouldDisableField(c24_59)),

_field("5-9 years old", a5_9, keyName: "a5_9",
    disabled: _shouldDisableField(a5_9)),

_field("10-19 years old", a10_19, keyName: "a10_19",
    disabled: _shouldDisableField(a10_19)),

_field("20-59 years old", a20_59, keyName: "a20_59",
    disabled: _shouldDisableField(a20_59)),

_field("60 years old and above", a60, keyName: "a60",
    disabled: _shouldDisableField(a60)),

_field("PWD", pwd, keyName: "pwd"),

// ======================= WOMEN =======================
const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text("Women Status",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
),

_field("Pregnant 19 below", preg19, keyName: "preg19"),
_field("Pregnant 20 above", preg20, keyName: "preg20"),
_field("Lactating", lactating, keyName: "lactating"),

// ======================= IYCF =======================
const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text("IYCF",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
),

_field("0-5 months exclusive breastfeeding", exclusive, keyName: "exclusive"),
_field("0-5 months mixed feeding", mixed, keyName: "mixed"),
_field("0-5 months bottle feeding", bottle, keyName: "bottle"),
_field("6-12 complementary feeding", complementary, keyName: "complementary"),

// ======================= NUTRITION =======================
const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text("Preschool children nutritional status",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
),

_field("Severely Underweight", su, keyName: "su"),
_field("Underweight", uw, keyName: "uw"),
_field("Normal", nw, keyName: "nw"),
_field("Severely Wasted", sw, keyName: "sw"),
_field("Wasted", w, keyName: "w"),
_field("Overweight", ow, keyName: "ow"),
_field("Obese", ob, keyName: "ob"),
_field("Severely Stunted", ss, keyName: "ss"),
_field("Stunted", st, keyName: "st"),

// ======================= FACILITIES =======================
const Padding(
  padding: EdgeInsets.only(bottom: 8),
  child: Text("Facilities",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
),

_drop("Toilet Type", toilet,
    ["Water Sealed", "Antipolo", "Open Pit", "Shared", "No Toilet"],
    (v) => setState(() => toilet = v)),

_drop("Water Source", water,
    ["Pipe Water", "Deep Well", "Purified", "Shallow Well", "Artesian", "Spring"],
    (v) => setState(() => water = v)),

_drop("Dwelling Type", dwellingType,
    ["Concrete", "Semi Concrete", "Wooden", "Nipa Bamboo House", "Barong-Barong", "Makeshift"],
    (v) => setState(() => dwellingType = v)),

_multiSelectDrop(
  "Garbage Disposal",
  garbage,
  ["City Garbage Collector", "Barangay Garbage Collector", "Compost Pit", "Burning", "Dumping"],
  (v) => setState(() => garbage = v),
),

_multiSelectDrop(
  "Food Production",
  food,
  ["Vegetable Garden", "Poultry", "Livestock", "Fishpond", "No Garden"],
  (v) => setState(() => food = v),
),

CheckboxListTile(
  value: iodizedSalt,
  onChanged: (v) => setState(() => iodizedSalt = v!),
  title: const Text("Uses Iodized Salt"),
),

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
onPressed: () async {
  setState(() => _submitted = true);

  if (!_isFormValid) {
    _scrollToFirstInvalid();
    return;
  }
      
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
                    "garbage": garbage.join(", "),
                    "water": water,
                    "food": food.join(", "),
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

Widget _field(
  String label,
  TextEditingController controller, {
  bool readOnly = false,
  TextInputType? type,
  bool disabled = false,
  String keyName = "",
}) {
  _fieldKeys.putIfAbsent(keyName, () => GlobalKey());

  bool isInvalid = _submitted && controller.text.trim().isEmpty;

  return Padding(
    key: _fieldKeys[keyName],
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      readOnly: readOnly || disabled,
      keyboardType: type ?? TextInputType.number,
      onChanged: (_) {
        _limitAgeInput(controller);
        setState(() {});
      },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),

        // 🔴 RED BORDER WHEN INVALID
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isInvalid ? Colors.red : Colors.grey,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isInvalid ? Colors.red : Colors.blue,
            width: 2,
          ),
        ),
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

  Widget _multiSelectDrop(
  String label,
  List<String> selected,
  List<String> items,
  void Function(List<String>) onChanged,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      onTap: () async {
        final result = await showDialog<List<String>>(
          context: context,
          builder: (context) {
            List<String> tempSelected = List.from(selected);

            return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  title: Text(label),
                  content: SingleChildScrollView(
                    child: Column(
                      children: items.map((item) {
                        return CheckboxListTile(
                          value: tempSelected.contains(item),
                          title: Text(item),
                          onChanged: (val) {
                            setStateDialog(() {
                              if (val == true) {
                                tempSelected.add(item);
                              } else {
                                tempSelected.remove(item);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, tempSelected),
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
            );
          },
        );

        if (result != null) {
          onChanged(result);
          setState(() {});
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: "",
          border: OutlineInputBorder(),
        ),
        child: Text(
          selected.isEmpty ? "Select $label" : selected.join(", "),
        ),
      ),
    ),
  );
}

void _scrollToFirstInvalid() {
  for (var entry in _fieldKeys.entries) {
    final context = entry.value.currentContext;

    if (context != null) {
      final box = context.findRenderObject() as RenderBox;
      final pos = box.localToGlobal(Offset.zero);

      _scrollController.animateTo(
        pos.dy + _scrollController.offset - 120,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      break;
    }
  }
}


}