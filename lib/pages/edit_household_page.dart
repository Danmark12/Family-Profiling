// lib/pages/edit_household_page.dart
import 'package:flutter/material.dart';
import '../db/config.dart';
import '../models/household.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class EditHouseholdPage extends StatefulWidget {
  final Household household;

  const EditHouseholdPage({super.key, required this.household});

  @override
  State<EditHouseholdPage> createState() => _EditHouseholdPageState();
}

class _EditHouseholdPageState extends State<EditHouseholdPage> {
  // Dropdowns
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
  late final zone = TextEditingController();
  late final father = TextEditingController();
  late final mother = TextEditingController();

  late final male = TextEditingController();
  late final female = TextEditingController();
  late final total = TextEditingController();
  late final families = TextEditingController();
  late final immunized = TextEditingController();

  late final exclusive = TextEditingController();
  late final mixed = TextEditingController();
  late final bottle = TextEditingController();
  late final complementary = TextEditingController();

  late final preg19 = TextEditingController();
  late final preg20 = TextEditingController();
  late final lactating = TextEditingController();

  late final i0_5 = TextEditingController();
  late final i6_11 = TextEditingController();
  late final c12_23 = TextEditingController();
  late final c24_59 = TextEditingController();
  late final a5_9 = TextEditingController();
  late final a10_19 = TextEditingController();
  late final a20_59 = TextEditingController();
  late final a60 = TextEditingController();
  late final pwd = TextEditingController();

  late final su = TextEditingController();
  late final uw = TextEditingController();
  late final nw = TextEditingController();
  late final sw = TextEditingController();
  late final w = TextEditingController();
  late final ow = TextEditingController();
  late final ob = TextEditingController();
  late final ss = TextEditingController();
  late final st = TextEditingController();

  late final TextEditingController barangayController;

  String get formattedDate {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _loadHouseholdData();

    male.addListener(_updateTotal);
    female.addListener(_updateTotal);
  }

  void _updateTotal() {
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

  if (currentTotal >= totalMembers &&
      (int.tryParse(controller.text) ?? 0) == 0) {
    return true;
  }

  return false;
}

bool _isAgeGroupValid() {
  int totalMembers = int.tryParse(total.text) ?? 0;
  int ageTotal = _getAgeGroupTotal();

  return totalMembers == ageTotal;
}

  void _loadHouseholdData() {
    final hh = widget.household;

    zone.text = hh.zone ?? "";
    father.text = hh.fatherName ?? "";
    mother.text = hh.motherName ?? "";
    male.text = hh.male?.toString() ?? "";
    female.text = hh.female?.toString() ?? "";
    total.text = hh.total?.toString() ?? "";
    families.text = hh.families?.toString() ?? "";
    immunized.text = hh.fullyImmunized?.toString() ?? "";

    exclusive.text = hh.exclusive?.toString() ?? "";
    mixed.text = hh.mixed?.toString() ?? "";
    bottle.text = hh.bottleFed?.toString() ?? "";
    complementary.text = hh.complementary?.toString() ?? "";

    preg19.text = hh.preg19?.toString() ?? "";
    preg20.text = hh.preg20?.toString() ?? "";
    lactating.text = hh.lactating?.toString() ?? "";

    i0_5.text = hh.infant0to5?.toString() ?? "";
    i6_11.text = hh.infant6to11?.toString() ?? "";
    c12_23.text = hh.child12to23?.toString() ?? "";
    c24_59.text = hh.child24to59?.toString() ?? "";
    a5_9.text = hh.age5to9?.toString() ?? "";
    a10_19.text = hh.age10to19?.toString() ?? "";
    a20_59.text = hh.age20to59?.toString() ?? "";
    a60.text = hh.age60above?.toString() ?? "";
    pwd.text = hh.pwd?.toString() ?? "";

    su.text = hh.severelyUnderweight?.toString() ?? "";
    uw.text = hh.underweight?.toString() ?? "";
    nw.text = hh.normal?.toString() ?? "";
    sw.text = hh.severelyWasted?.toString() ?? "";
    w.text = hh.wasted?.toString() ?? "";
    ow.text = hh.overweight?.toString() ?? "";
    ob.text = hh.obese?.toString() ?? "";
    ss.text = hh.severelyStunted?.toString() ?? "";
    st.text = hh.stunted?.toString() ?? "";

    barangay = hh.barangay;
    toilet = hh.toilet;

    water = hh.water;

    dwellingType = hh.dwellingType;
    garbage = hh.garbage == null || hh.garbage!.isEmpty
    ? []
    : hh.garbage!.split(", ").map((e) => e.trim()).toList();

food = hh.food == null || hh.food!.isEmpty
    ? []
    : hh.food!.split(", ").map((e) => e.trim()).toList();
    

    fatherOccupation = hh.fatherOccupation;
    fatherEducation = hh.fatherEducation;
    motherOccupation = hh.motherOccupation;
    motherEducation = hh.motherEducation;

    fourPs = hh.fourPs == 1;
    indigenousPeople = hh.indigenousPeople == 1;
    iodizedSalt = hh.iodizedSalt == 1;
    noFather = hh.fatherOccupation == null || hh.fatherOccupation == "None";
    noMother = hh.motherOccupation == null || hh.motherOccupation == "None";

    barangayController = TextEditingController(text: barangay ?? "");
  }

  int? _num(TextEditingController c) =>
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
      appBar: AppBar(title: const Text("Edit Household")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
Center(
  child: Text(
    "Household No.: ${widget.household.householdNo}",
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),
),
const SizedBox(height: 12),

            _field("Zone / Purok", zone),
            _field("Barangay", barangayController, readOnly: true),

            CheckboxListTile(
                value: fourPs,
                onChanged: (v) => setState(() => fourPs = v!),
                title: const Text("4Ps")),
            CheckboxListTile(
                value: indigenousPeople,
                onChanged: (v) => setState(() => indigenousPeople = v!),
                title: const Text("Indigenous People")),

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
            _field("Total", total, readOnly: true),
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
    "Preschool children nutritional Status",
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
                ["Water Sealed","Antipolo","Open Pit","Shared","No Toilet"],
                (v) => setState(() => toilet = v)),

            _drop("Water Source", water,
                ["Pipe Water","Deep Well","Purified","Shallow Well","Artesian","Spring"],
                (v) => setState(() => water = v)),

            _drop("Dwelling Type", dwellingType,
                ["Concrete","Semi Concrete","Wooden","Nipa Bamboo House","Barong-Barong","Makeshift"],
                (v) => setState(() => dwellingType = v)),

                _multiSelectDrop(
  "Garbage Disposal",
  garbage,
  [
    "City Garbage Collector",
    "Barangay Garbage Collector",
    "Compost Pit",
    "Burning",
    "Dumping"
  ],
  (v) => setState(() => garbage = v),
),

_multiSelectDrop(
  "Food Production",
  food,
  [
    "Vegetable Garden",
    "Poultry",
    "Livestock",
    "Fishpond",
    "No Garden"
  ],
  (v) => setState(() => food = v),
),

            CheckboxListTile(
                value: iodizedSalt,
                onChanged: (v) => setState(() => iodizedSalt = v!),
                title: const Text("Uses Iodized Salt")),

            const SizedBox(height: 20),

            // ✅ UPDATED BUTTON
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: SizedBox(
                  width: 220,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.05),
                      elevation: 10,
                      // shadowColor: Colors.green.withOpacity(0.4),
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {

  // ❗ ADD VALIDATION FIRST
  if (!_isAgeGroupValid()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Age group total must equal total members"),
      ),
    );
    return;
  }

                      await DBHelper.instance.updateHousehold(
                        widget.household.id!,
                        {
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
                          "male": _num(male),
                          "female": _num(female),
                          "total": _num(total),
                          "families": _num(families),
                          "fullyImmunized": _num(immunized),
                          "exclusive": _num(exclusive),
                          "mixed": _num(mixed),
                          "bottleFed": _num(bottle),
                          "complementary": _num(complementary),
                          "preg19": _num(preg19),
                          "preg20": _num(preg20),
                          "lactating": _num(lactating),
                          "infant0to5": _num(i0_5),
                          "infant6to11": _num(i6_11),
                          "child12to23": _num(c12_23),
                          "child24to59": _num(c24_59),
                          "age5to9": _num(a5_9),
                          "age10to19": _num(a10_19),
                          "age20to59": _num(a20_59),
                          "age60above": _num(a60),
                          "pwd": _num(pwd),
                          "severelyUnderweight": _num(su),
                          "underweight": _num(uw),
                          "normal": _num(nw),
                          "severelyWasted": _num(sw),
                          "wasted": _num(w),
                          "overweight": _num(ow),
                          "obese": _num(ob),
                          "severelyStunted": _num(ss),
                          "stunted": _num(st),
                          "toilet": toilet,
                         
                          "water": water,
                      
                          "dwellingType": dwellingType,
                    "garbage": garbage.join(", "),
                    "food": food.join(", "),
                          "updated_at": formattedDate,
                        },
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Updated Successfully")),
                      );

                      Navigator.pop(context);
                    },
                    child: const Text(
                      "UPDATE",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
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
        _limitAgeInput(controller); // ✅ ADD THIS
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
          suffixIcon: PopupMenuButton<String>(
            icon: const Icon(Icons.arrow_drop_down),
            enabled: !disabled,
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
}