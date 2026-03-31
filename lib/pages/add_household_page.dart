// lib/pages/add_household_page.dart
import 'package:flutter/material.dart';
import '../db/config.dart';
import '../models/household.dart';

class AddHouseholdPage extends StatefulWidget {
  const AddHouseholdPage({super.key});

  @override
  State<AddHouseholdPage> createState() => _AddHouseholdPageState();
}

class _AddHouseholdPageState extends State<AddHouseholdPage> {
  int householdNo = 1;

  // DROPDOWNS
  String? barangay, occupation, education, toilet, water, food;

  // CHECKBOXES
  bool iodizedSalt = false;
  bool ifr = false;

  // CONTROLLERS
  final hhHeadCtrl = TextEditingController();
  final zoneCtrl = TextEditingController();
  final maleCtrl = TextEditingController();
  final femaleCtrl = TextEditingController();
  final totalCtrl = TextEditingController();
  final familiesCtrl = TextEditingController();
  final infantsComplementaryCtrl = TextEditingController();
  final pregCtrl = TextEditingController();
  final lactatingCtrl = TextEditingController();
  final infant0to5Ctrl = TextEditingController();
  final infant6to11Ctrl = TextEditingController();
  final infant12to23Ctrl = TextEditingController();
  final infant24to59Ctrl = TextEditingController();
  final underweightSevereCtrl = TextEditingController();
  final underweightCtrl = TextEditingController();
  final normalCtrl = TextEditingController();
  final wastedSevereCtrl = TextEditingController();
  final wastedCtrl = TextEditingController();
  final overweightCtrl = TextEditingController();
  final obeseCtrl = TextEditingController();
  final stuntedSevereCtrl = TextEditingController();
  final stuntedCtrl = TextEditingController();

  final Color borderColor = const Color(0xFFDADCE0);

  @override
  void initState() {
    super.initState();
    _getNextHouseholdNo();
  }

  Future<void> _getNextHouseholdNo() async {
    final last = await DBHelper.instance.getLastHouseholdNo();
    setState(() {
      householdNo = (last != null ? last + 1 : 1);
    });
  }

  @override
  void dispose() {
    hhHeadCtrl.dispose();
    zoneCtrl.dispose();
    maleCtrl.dispose();
    femaleCtrl.dispose();
    totalCtrl.dispose();
    familiesCtrl.dispose();
    infantsComplementaryCtrl.dispose();
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
      appBar: AppBar(title: const Text("Add Household")),
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
                  child: Text("Add Household", style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(height: 25),

                // Household Number
                _buildNumberField(
                  "Household No.",
                  value: householdNo.toString(),
                  readOnly: true,
                ),
                const SizedBox(height: 20),

                // Zone & Barangay
                _twoFields(
                  _buildNumberField(
                    "Zone / Purok",
                    controller: zoneCtrl,
                  ),
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

                // Household Head / Spouse
                _buildTextField("Name of Household Head / Spouse", controller: hhHeadCtrl),
                const SizedBox(height: 20),

                // Occupation & Education
                _twoFields(
                  _buildDropdown(
                    "Occupation",
                    occupation,
                    [
                      "Manager",
                      "Professional",
                      "Technician & associate professionals",
                      "Clerical support workers",
                      "Service and sales workers",
                      "Skilled Agricultural, forestry and fishery workers",
                      "Craft and related workers",
                      "Plant and machine operators and assemblers",
                      "Elementary occupations",
                      "Armed Forces occupations",
                      "Others",
                      "None"
                    ],
                    (val) => setState(() => occupation = val),
                  ),
                  _buildDropdown(
                    "Educational Attainment",
                    education,
                    [
                      "EU - Elem. Undergraduate",
                      "EG - Elem. Graduate",
                      "HU - HS Undergraduate",
                      "HG - HS Graduate",
                      "CU - College Undergraduate",
                      "CG - College Graduate",
                      "V - Vocational",
                      "O - Others"
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
                const SizedBox(height: 15),
                _twoFields(
                  _buildNumberField("No. of Infants given complementary foods", controller: infantsComplementaryCtrl),
                  Container(), // Empty placeholder
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
                      // CREATE HOUSEHOLD OBJECT
                      final household = Household(
                        householdNo: householdNo,
                        householdHead: hhHeadCtrl.text,
                        zone: int.tryParse(zoneCtrl.text),
                        barangay: barangay,
                        occupation: occupation,
                        education: education,
                        male: parse(maleCtrl),
                        female: parse(femaleCtrl),
                        total: parse(totalCtrl),
                        families: parse(familiesCtrl),
                        infantsComplementary: parse(infantsComplementaryCtrl), // NEW
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

                      // INSERT TO DB
                      await DBHelper.instance.insertHousehold(household);

                      // INCREMENT HOUSEHOLD NO
                      setState(() => householdNo++);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Saved successfully!")),
                      );

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color.fromARGB(255, 5, 114, 3),
                      side: const BorderSide(color: Color.fromARGB(255, 9, 119, 3)),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text("Save Household"),
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