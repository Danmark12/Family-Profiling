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
    
    // PWD is required
    if (pwd.text.trim().isEmpty) return false;

    // WOMEN STATUS - all required
    if (preg19.text.trim().isEmpty) return false;
    if (preg20.text.trim().isEmpty) return false;
    if (lactating.text.trim().isEmpty) return false;

    // IYCF - all required
    if (exclusive.text.trim().isEmpty) return false;
    if (mixed.text.trim().isEmpty) return false;
    if (bottle.text.trim().isEmpty) return false;
    if (complementary.text.trim().isEmpty) return false;

    // NUTRITIONAL STATUS - all required
    if (su.text.trim().isEmpty) return false;
    if (uw.text.trim().isEmpty) return false;
    if (nw.text.trim().isEmpty) return false;
    if (sw.text.trim().isEmpty) return false;
    if (w.text.trim().isEmpty) return false;
    if (ow.text.trim().isEmpty) return false;
    if (ob.text.trim().isEmpty) return false;
    if (ss.text.trim().isEmpty) return false;
    if (st.text.trim().isEmpty) return false;

    // Father / Mother conditional validation (including occupation & education)
    if (!noFather) {
      if (father.text.trim().isEmpty) return false;
      if (fatherOccupation == null) return false;
      if (fatherEducation == null) return false;
    }

    if (!noMother) {
      if (mother.text.trim().isEmpty) return false;
      if (motherOccupation == null) return false;
      if (motherEducation == null) return false;
    }

    // DROPDOWNS (REQUIRED)
    if (toilet == null) return false;
    if (garbage.isEmpty) return false;
    if (water == null) return false;
    if (food.isEmpty) return false;
    if (dwellingType == null) return false;
    
    // AGE GROUP VALIDATION - total must equal total members
    if (!_isAgeGroupValid()) return false;

    return true;
  }

  void _calculateTotal() {
    total.text = ((int.tryParse(male.text) ?? 0) + (int.tryParse(female.text) ?? 0)).toString();
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
    int othersTotal = _getAgeGroupTotal() - (int.tryParse(currentController.text) ?? 0);
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
  
  bool _isAgeGroupTotalMismatch() {
    if (!_submitted) return false;
    int totalMembers = int.tryParse(total.text) ?? 0;
    int ageTotal = _getAgeGroupTotal();
    return totalMembers != ageTotal;
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

  int? _parseInt(TextEditingController c) => c.text.isEmpty ? null : int.tryParse(c.text);

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

            _field("Zone / Purok", zone, keyName: "zone", required: true),
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
                type: TextInputType.text, readOnly: noFather, keyName: "father_name", required: !noFather),

            _drop("Occupation", fatherOccupation, occupations,
                noFather ? null : (v) => setState(() => fatherOccupation = v),
                disabled: noFather, keyName: "father_occupation", required: !noFather),

            _drop("Educational Attainment", fatherEducation, educ,
                noFather ? null : (v) => setState(() => fatherEducation = v),
                disabled: noFather, keyName: "father_education", required: !noFather),

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
                type: TextInputType.text, readOnly: noMother, keyName: "mother_name", required: !noMother),

            _drop("Occupation", motherOccupation, occupations,
                noMother ? null : (v) => setState(() => motherOccupation = v),
                disabled: noMother, keyName: "mother_occupation", required: !noMother),

            _drop("Educational Attainment", motherEducation, educ,
                noMother ? null : (v) => setState(() => motherEducation = v),
                disabled: noMother, keyName: "mother_education", required: !noMother),

            // ======================= HOUSEHOLD MEMBERS =======================
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text("Household Members",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),

            _field("Male", male, keyName: "male", required: true),
            _field("Female", female, keyName: "female", required: true),
            _field("Total members", total, readOnly: true, keyName: "total"),
            _field("No. of families", families, keyName: "families", required: true),
            _field("Fully immunized children", immunized, keyName: "immunized", required: true),

            // ======================= AGE GROUP =======================
            Container(
              key: _fieldKeys.putIfAbsent('age_group_section', () => GlobalKey()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text("Age Group",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  _ageGroupField("Infants 0-5 months old", i0_5, keyName: "i0_5",
                      disabled: _shouldDisableField(i0_5)),
                  _ageGroupField("Infants 6-11 months old", i6_11, keyName: "i6_11",
                      disabled: _shouldDisableField(i6_11)),
                  _ageGroupField("Preschool 12-23 months old", c12_23, keyName: "c12_23",
                      disabled: _shouldDisableField(c12_23)),
                  _ageGroupField("Preschool 24-59 months old", c24_59, keyName: "c24_59",
                      disabled: _shouldDisableField(c24_59)),
                  _ageGroupField("5-9 years old", a5_9, keyName: "a5_9",
                      disabled: _shouldDisableField(a5_9)),
                  _ageGroupField("10-19 years old", a10_19, keyName: "a10_19",
                      disabled: _shouldDisableField(a10_19)),
                  _ageGroupField("20-59 years old", a20_59, keyName: "a20_59",
                      disabled: _shouldDisableField(a20_59)),
                  _ageGroupField("60 years old and above", a60, keyName: "a60",
                      disabled: _shouldDisableField(a60)),
                  _field("PWD", pwd, keyName: "pwd", required: true),
                ],
              ),
            ),

            // ======================= WOMEN =======================
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text("Women Status",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),

            _field("Pregnant 19 below", preg19, keyName: "preg19", required: true),
            _field("Pregnant 20 above", preg20, keyName: "preg20", required: true),
            _field("Lactating", lactating, keyName: "lactating", required: true),

            // ======================= IYCF =======================
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text("IYCF",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),

            _field("0-5 months exclusive breastfeeding", exclusive, keyName: "exclusive", required: true),
            _field("0-5 months mixed feeding", mixed, keyName: "mixed", required: true),
            _field("0-5 months bottle feeding", bottle, keyName: "bottle", required: true),
            _field("6-12 complementary feeding", complementary, keyName: "complementary", required: true),

            // ======================= NUTRITION =======================
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text("Preschool children nutritional status",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),

            _field("Severely Underweight", su, keyName: "su", required: true),
            _field("Underweight", uw, keyName: "uw", required: true),
            _field("Normal", nw, keyName: "nw", required: true),
            _field("Severely Wasted", sw, keyName: "sw", required: true),
            _field("Wasted", w, keyName: "w", required: true),
            _field("Overweight", ow, keyName: "ow", required: true),
            _field("Obese", ob, keyName: "ob", required: true),
            _field("Severely Stunted", ss, keyName: "ss", required: true),
            _field("Stunted", st, keyName: "st", required: true),

            // ======================= FACILITIES =======================
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text("Facilities",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),

            _drop("Toilet Type", toilet,
                ["Water Sealed", "Antipolo", "Open Pit", "Shared", "No Toilet"],
                (v) => setState(() => toilet = v),
                keyName: "toilet", required: true),

            _drop("Water Source", water,
                ["Pipe Water", "Deep Well", "Purified", "Shallow Well", "Artesian", "Spring"],
                (v) => setState(() => water = v),
                keyName: "water", required: true),

            _drop("Dwelling Type", dwellingType,
                ["Concrete", "Semi Concrete", "Wooden", "Nipa Bamboo House", "Barong-Barong", "Makeshift"],
                (v) => setState(() => dwellingType = v),
                keyName: "dwelling_type", required: true),

            _multiSelectDrop(
              "Garbage Disposal",
              garbage,
              ["City Garbage Collector", "Barangay Garbage Collector", "Compost Pit", "Burning", "Dumping"],
              (v) => setState(() => garbage = v),
              keyName: "garbage", required: true,
            ),

            _multiSelectDrop(
              "Food Production",
              food,
              ["Vegetable Garden", "Poultry", "Livestock", "Fishpond", "No Garden"],
              (v) => setState(() => food = v),
              keyName: "food", required: true,
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
                    backgroundColor: _isFormValid ? Colors.transparent : Colors.grey.shade300,
                    foregroundColor: Colors.black,
                    elevation: 6,
                    shadowColor: Colors.black,
                    side: BorderSide(
                      color: _isFormValid ? Colors.black : Colors.grey,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () async {
                    setState(() => _submitted = true);

                    if (!_isFormValid) {
                      _scrollToFirstInvalid();
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
            const SizedBox(height: 30),
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
    bool required = false,
  }) {
    _fieldKeys.putIfAbsent(keyName, () => GlobalKey());

    bool isInvalid = _submitted && required && controller.text.trim().isEmpty;

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
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          errorText: isInvalid ? "This is a required question" : null,
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

  Widget _ageGroupField(
    String label,
    TextEditingController controller, {
    bool disabled = false,
    String keyName = "",
  }) {
    _fieldKeys.putIfAbsent(keyName, () => GlobalKey());

    bool showError = _submitted && _isAgeGroupTotalMismatch();

    return Padding(
      key: _fieldKeys[keyName],
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: disabled,
        keyboardType: TextInputType.number,
        onChanged: (_) {
          _limitAgeInput(controller);
          setState(() {});
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          errorText: showError ? "Age group total must equal total members" : null,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: showError ? Colors.red : Colors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: showError ? Colors.red : Colors.blue,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _drop(
    String label,
    String? value,
    List<String> items,
    void Function(String?)? onChanged, {
    bool disabled = false,
    String? keyName,
    bool required = false,
  }) {
    if (keyName != null && keyName.isNotEmpty) {
      _fieldKeys.putIfAbsent(keyName, () => GlobalKey());
    }

    bool isInvalid = _submitted && required && value == null;

    return Padding(
      key: keyName != null ? _fieldKeys[keyName] : null,
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              errorText: isInvalid ? "This is a required question" : null,
              suffixIcon: disabled
                  ? null
                  : PopupMenuButton<String>(
                      icon: const Icon(Icons.arrow_drop_down),
                      onSelected: onChanged,
                      itemBuilder: (c) => items.map((e) => PopupMenuItem(value: e, child: Text(e))).toList(),
                    ),
            ),
            child: Text(value ?? "Select"),
          ),
        ],
      ),
    );
  }

  Widget _multiSelectDrop(
    String label,
    List<String> selected,
    List<String> items,
    void Function(List<String>) onChanged, {
    String? keyName,
    bool required = false,
  }) {
    if (keyName != null && keyName.isNotEmpty) {
      _fieldKeys.putIfAbsent(keyName, () => GlobalKey());
    }

    bool isInvalid = _submitted && required && selected.isEmpty;

    return Padding(
      key: keyName != null ? _fieldKeys[keyName] : null,
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
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
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                errorText: isInvalid ? "This is a required question" : null,
              ),
              child: Text(
                selected.isEmpty ? "Select $label" : selected.join(", "),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToFirstInvalid() {
    // Check text fields first (required fields)
    final requiredTextFields = [
      'zone', 'male', 'female', 'families', 'immunized', 'pwd',
      'preg19', 'preg20', 'lactating',
      'exclusive', 'mixed', 'bottle', 'complementary',
      'su', 'uw', 'nw', 'sw', 'w', 'ow', 'ob', 'ss', 'st'
    ];
    
    for (var key in requiredTextFields) {
      final controller = _getControllerForKey(key);
      if (controller != null && controller.text.trim().isEmpty) {
        _scrollToWidgetByKey(key);
        return;
      }
    }

    // Check father/mother conditional fields
    if (!noFather) {
      if (father.text.trim().isEmpty) {
        _scrollToWidgetByKey('father_name');
        return;
      }
      if (fatherOccupation == null) {
        _scrollToWidgetByKey('father_occupation');
        return;
      }
      if (fatherEducation == null) {
        _scrollToWidgetByKey('father_education');
        return;
      }
    }

    if (!noMother) {
      if (mother.text.trim().isEmpty) {
        _scrollToWidgetByKey('mother_name');
        return;
      }
      if (motherOccupation == null) {
        _scrollToWidgetByKey('mother_occupation');
        return;
      }
      if (motherEducation == null) {
        _scrollToWidgetByKey('mother_education');
        return;
      }
    }

    // Check dropdowns
    if (toilet == null) {
      _scrollToWidgetByKey('toilet');
      return;
    }
    if (water == null) {
      _scrollToWidgetByKey('water');
      return;
    }
    if (dwellingType == null) {
      _scrollToWidgetByKey('dwelling_type');
      return;
    }
    if (garbage.isEmpty) {
      _scrollToWidgetByKey('garbage');
      return;
    }
    if (food.isEmpty) {
      _scrollToWidgetByKey('food');
      return;
    }

    // Check age group mismatch
    if (!_isAgeGroupValid()) {
      _scrollToWidgetByKey('age_group_section');
      return;
    }
  }

  TextEditingController? _getControllerForKey(String key) {
    switch (key) {
      case 'zone': return zone;
      case 'male': return male;
      case 'female': return female;
      case 'families': return families;
      case 'immunized': return immunized;
      case 'pwd': return pwd;
      case 'preg19': return preg19;
      case 'preg20': return preg20;
      case 'lactating': return lactating;
      case 'exclusive': return exclusive;
      case 'mixed': return mixed;
      case 'bottle': return bottle;
      case 'complementary': return complementary;
      case 'su': return su;
      case 'uw': return uw;
      case 'nw': return nw;
      case 'sw': return sw;
      case 'w': return w;
      case 'ow': return ow;
      case 'ob': return ob;
      case 'ss': return ss;
      case 'st': return st;
      case 'father_name': return father;
      case 'mother_name': return mother;
      default: return null;
    }
  }

  void _scrollToWidgetByKey(String key) {
    final keyObj = _fieldKeys[key];
    final context = keyObj?.currentContext;
    if (context != null) {
      _scrollToContext(context);
    }
  }

  void _scrollToContext(BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    _scrollController.animateTo(
      (pos.dy + _scrollController.offset) - 120,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}