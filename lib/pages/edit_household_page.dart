// lib/pages/edit_household_page.dart
import 'package:flutter/material.dart';
import '../db/config.dart';
import '../models/household.dart';

class EditHouseholdPage extends StatefulWidget {
  final Household household;

  const EditHouseholdPage({super.key, required this.household});

  @override
  State<EditHouseholdPage> createState() => _EditHouseholdPageState();
}

class _EditHouseholdPageState extends State<EditHouseholdPage> {
  // DROPDOWNS
  String? barangay, occupation, education, toilet, water, food;

  // CHECKBOXES
  bool iodizedSalt = false;
  bool ifr = false;

  // CONTROLLERS
  late TextEditingController hhHeadCtrl;
  late TextEditingController zoneCtrl;
  late TextEditingController maleCtrl;
  late TextEditingController femaleCtrl;
  late TextEditingController totalCtrl;
  late TextEditingController familiesCtrl;
  late TextEditingController pregCtrl;
  late TextEditingController lactatingCtrl;
  late TextEditingController infant0to5Ctrl;
  late TextEditingController infant6to11Ctrl;
  late TextEditingController infant12to23Ctrl;
  late TextEditingController infant24to59Ctrl;
  late TextEditingController underweightSevereCtrl;
  late TextEditingController underweightCtrl;
  late TextEditingController normalCtrl;
  late TextEditingController wastedSevereCtrl;
  late TextEditingController wastedCtrl;
  late TextEditingController overweightCtrl;
  late TextEditingController obeseCtrl;
  late TextEditingController stuntedSevereCtrl;
  late TextEditingController stuntedCtrl;

  final Color borderColor = const Color(0xFFDADCE0);

  @override
  void initState() {
    super.initState();
    final h = widget.household;

    // Initialize controllers with existing values
    hhHeadCtrl = TextEditingController(text: h.householdHead);
    zoneCtrl = TextEditingController(text: h.zone?.toString());
    maleCtrl = TextEditingController(text: h.male?.toString());
    femaleCtrl = TextEditingController(text: h.female?.toString());
    totalCtrl = TextEditingController(text: h.total?.toString());
    familiesCtrl = TextEditingController(text: h.families?.toString());
    pregCtrl = TextEditingController(text: h.pregnant?.toString());
    lactatingCtrl = TextEditingController(text: h.lactating?.toString());
    infant0to5Ctrl = TextEditingController(text: h.infant0to5?.toString());
    infant6to11Ctrl = TextEditingController(text: h.infant6to11?.toString());
    infant12to23Ctrl = TextEditingController(text: h.infant12to23?.toString());
    infant24to59Ctrl = TextEditingController(text: h.infant24to59?.toString());
    underweightSevereCtrl = TextEditingController(text: h.underweightSevere?.toString());
    underweightCtrl = TextEditingController(text: h.underweight?.toString());
    normalCtrl = TextEditingController(text: h.normal?.toString());
    wastedSevereCtrl = TextEditingController(text: h.wastedSevere?.toString());
    wastedCtrl = TextEditingController(text: h.wasted?.toString());
    overweightCtrl = TextEditingController(text: h.overweight?.toString());
    obeseCtrl = TextEditingController(text: h.obese?.toString());
    stuntedSevereCtrl = TextEditingController(text: h.stuntedSevere?.toString());
    stuntedCtrl = TextEditingController(text: h.stunted?.toString());

    // Initialize dropdowns & checkboxes
    barangay = h.barangay;
    occupation = h.occupation;
    education = h.education;
    toilet = h.toilet;
    water = h.water;
    food = h.food;
    iodizedSalt = h.iodizedSalt ?? false;
    ifr = h.ifr ?? false;
  }

  @override
  void dispose() {
    hhHeadCtrl.dispose();
    zoneCtrl.dispose();
    maleCtrl.dispose();
    femaleCtrl.dispose();
    totalCtrl.dispose();
    familiesCtrl.dispose();
    pregCtrl.dispose();
    lactatingCtrl.dispose();
    infant0to5Ctrl.dispose();
    infant6to11Ctrl.dispose();
    infant12to23Ctrl.dispose();
    infant24to59Ctrl.dispose();
    underweightSevereCtrl.dispose();
    underweightCtrl.dispose();
    normalCtrl.dispose();
    wastedSevereCtrl.dispose();
    wastedCtrl.dispose();
    overweightCtrl.dispose();
    obeseCtrl.dispose();
    stuntedSevereCtrl.dispose();
    stuntedCtrl.dispose();
    super.dispose();
  }

  int? parse(TextEditingController c) => int.tryParse(c.text);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text("Edit Household")),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(30),
            width: screenWidth > 900 ? 800 : screenWidth * 0.95,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text("Edit Household", style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(height: 25),

                // Household Number (read-only)
                _buildNumberField(
                  "Household No.",
                  value: widget.household.householdNo.toString(),
                  readOnly: true,
                ),
                const SizedBox(height: 20),

                // Zone & Barangay
                _twoFields(
                  _buildNumberField("Zone / Purok", controller: zoneCtrl),
                  _buildDropdown(
                    "Barangay",
                    barangay,
                    [
                      "Amoros","Bolisong","Cogon","Himaya","Hinigdaan",
                      "Kalabaylabay","Molugan","Pedro S. Baculio",
                      "Poblacion","Quibonbon","Sambulawan",
                      "San Francisco de Asis","Sinaloc","Taytay","Ulaliman"
                    ],
                    (val) => setState(() => barangay = val),
                  ),
                ),
                const SizedBox(height: 20),

                // Household Head
                _buildTextField("Name of Household Head / Spouse", controller: hhHeadCtrl),
                const SizedBox(height: 20),

                // Occupation & Education
                _twoFields(
                  _buildDropdown(
                    "Occupation",
                    occupation,
                    [
                      "Manager","Professional","Technician & associate professionals",
                      "Clerical support workers","Service and sales workers",
                      "Skilled Agricultural, forestry and fishery workers",
                      "Craft and related workers","Plant and machine operators and assemblers",
                      "Elementary occupations","Armed Forces occupations","Others","None"
                    ],
                    (val) => setState(() => occupation = val),
                  ),
                  _buildDropdown(
                    "Educational Attainment",
                    education,
                    [
                      "EU - Elem. Undergraduate","EG - Elem. Graduate","HU - HS Undergraduate",
                      "HG - HS Graduate","CU - College Undergraduate","CG - College Graduate",
                      "V - Vocational","O - Others"
                    ],
                    (val) => setState(() => education = val),
                  ),
                ),
                const SizedBox(height: 25),

                // Household Members
                const Text("Household Members", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 15),
                _twoFields(
                  _buildNumberField("No. of HH members", controller: totalCtrl),
                  _buildNumberField("Male", controller: maleCtrl),
                ),
                const SizedBox(height: 15),
                _twoFields(
                  _buildNumberField("Female", controller: femaleCtrl),
                  _buildNumberField("No. of Families", controller: familiesCtrl),
                ),
                const SizedBox(height: 25),

                // Infants & Preschool Children
                const Text("Infants & Preschool Children", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 15),
                _twoFields(
                  _buildNumberField("0-5 months old", controller: infant0to5Ctrl),
                  _buildNumberField("6-11 months old", controller: infant6to11Ctrl),
                ),
                const SizedBox(height: 15),
                _twoFields(
                  _buildNumberField("12-23 months old", controller: infant12to23Ctrl),
                  _buildNumberField("24-59 months old", controller: infant24to59Ctrl),
                ),
                const SizedBox(height: 25),

                // Women Status
                const Text("Women Status", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 15),
                _twoFields(
                  _buildNumberField("Pregnant", controller: pregCtrl),
                  _buildNumberField("Lactating", controller: lactatingCtrl),
                ),
                const SizedBox(height: 25),

                // Nutritional Status
                const Text("Nutritional Status", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 15),
                _twoFields(
                  _buildNumberField("Severely Underweight", controller: underweightSevereCtrl),
                  _buildNumberField("Underweight", controller: underweightCtrl),
                ),
                const SizedBox(height: 15),
                _twoFields(
                  _buildNumberField("Normal weight", controller: normalCtrl),
                  _buildNumberField("Severely Wasted", controller: wastedSevereCtrl),
                ),
                const SizedBox(height: 15),
                _twoFields(
                  _buildNumberField("Wasted", controller: wastedCtrl),
                  _buildNumberField("Overweight", controller: overweightCtrl),
                ),
                const SizedBox(height: 15),
                _twoFields(
                  _buildNumberField("Obese", controller: obeseCtrl),
                  _buildNumberField("Severely Stunted", controller: stuntedSevereCtrl),
                ),
                const SizedBox(height: 15),
                _buildNumberField("Stunted", controller: stuntedCtrl),
                const SizedBox(height: 25),

                // Facilities
                const Text("Facilities", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 15),
                _twoFields(
                  _buildDropdown(
                    "Toilet Type",
                    toilet,
                    ["WS - Water Sealed","OP - Open pit","O - Others","N - None"],
                    (val) => setState(() => toilet = val),
                  ),
                  _buildDropdown(
                    "Water Source",
                    water,
                    ["P - Pipe","W - Well","S - Spring"],
                    (val) => setState(() => water = val),
                  ),
                ),
                const SizedBox(height: 15),
                _buildDropdown(
                  "Food Production",
                  food,
                  ["VG - Vegetable garden","P/L - Poultry/Livestock","FP - Fishpond"],
                  (val) => setState(() => food = val),
                ),
                const SizedBox(height: 20),

                // Checkboxes
                CheckboxListTile(
                  value: iodizedSalt,
                  onChanged: (val) => setState(() => iodizedSalt = val!),
                  title: const Text("Households using iodized salt"),
                ),
                CheckboxListTile(
                  value: ifr,
                  onChanged: (val) => setState(() => ifr = val!),
                  title: const Text("HH using IFR"),
                ),
                const SizedBox(height: 20),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final updated = Household(
                        id: widget.household.id,
                        householdNo: widget.household.householdNo,
                        householdHead: hhHeadCtrl.text,
                        zone: int.tryParse(zoneCtrl.text),
                        barangay: barangay,
                        occupation: occupation,
                        education: education,
                        male: parse(maleCtrl),
                        female: parse(femaleCtrl),
                        total: parse(totalCtrl),
                        families: parse(familiesCtrl),
                        pregnant: parse(pregCtrl),
                        lactating: parse(lactatingCtrl),
                        infant0to5: parse(infant0to5Ctrl),
                        infant6to11: parse(infant6to11Ctrl),
                        infant12to23: parse(infant12to23Ctrl),
                        infant24to59: parse(infant24to59Ctrl),
                        underweightSevere: parse(underweightSevereCtrl),
                        underweight: parse(underweightCtrl),
                        normal: parse(normalCtrl),
                        wastedSevere: parse(wastedSevereCtrl),
                        wasted: parse(wastedCtrl),
                        overweight: parse(overweightCtrl),
                        obese: parse(obeseCtrl),
                        stuntedSevere: parse(stuntedSevereCtrl),
                        stunted: parse(stuntedCtrl),
                        toilet: toilet,
                        water: water,
                        food: food,
                        iodizedSalt: iodizedSalt,
                        ifr: ifr,
                      );

                      await DBHelper.instance.updateHousehold(updated);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Household updated successfully!")),
                      );

                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color.fromARGB(255, 5, 114, 3),
                      side: const BorderSide(color: Color.fromARGB(255, 9, 119, 3)),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text("Update Household"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _twoFields(Widget a, Widget b) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(children: [a, const SizedBox(height: 15), b]);
        } else {
          return Row(
            children: [
              Flexible(flex: 1, child: a),
              const SizedBox(width: 15),
              Flexible(flex: 1, child: b),
            ],
          );
        }
      },
    );
  }

  Widget _buildTextField(String label, {TextEditingController? controller}) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(label),
    );
  }

  Widget _buildNumberField(String label,
      {TextEditingController? controller, String? value, bool readOnly = false}) {
    return TextField(
      controller: controller ?? (value != null ? TextEditingController(text: value) : null),
      readOnly: readOnly,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(label),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: _inputDecoration(label),
      hint: Text("Select $label", overflow: TextOverflow.ellipsis),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
    );
  }
}