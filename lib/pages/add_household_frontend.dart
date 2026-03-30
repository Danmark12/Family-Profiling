import 'package:flutter/material.dart';
import '../db/config.dart';
import '../models/household.dart';
class AddHouseholdFrontEnd extends StatefulWidget {
  const AddHouseholdFrontEnd({super.key});

  @override
  State<AddHouseholdFrontEnd> createState() => _AddHouseholdFrontEndState();
}

class _AddHouseholdFrontEndState extends State<AddHouseholdFrontEnd> {
  int householdNo = 1;

  String? barangay;
  String? occupation;
  String? education;
  String? toilet;
  String? water;
  String? food;

  bool iodizedSalt = false;
  bool ifr = false;

  final Color borderColor = const Color(0xFFDADCE0);

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

            // ✅ FIX 1: RESPONSIVE WIDTH
            width: screenWidth > 900 ? 800 : screenWidth * 0.95,

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 20)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Center(
                  child: Text(
                    "Add Household",
                    style: TextStyle(fontSize: 22),
                  ),
                ),

                const SizedBox(height: 25),

                _buildNumberField(
                  "Household No.",
                  value: householdNo.toString(),
                  readOnly: true,
                ),

                const SizedBox(height: 20),

                _twoFields(
                  _buildNumberField("Zone / Purok"),
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

                _buildTextField("Name of Household Head / Spouse"),

                const SizedBox(height: 20),

                _twoFields(
                  _buildDropdown(
                    "Occupation",
                    occupation,
                    [
                      "Manager","Professional",
                      "Technician & associate professionals",
                      "Clerical support workers",
                      "Service and sales workers",
                      "Skilled Agricultural, forestry and fishery workers",
                      "Craft and related workers",
                      "Plant and machine operators and assemblers",
                      "Elementary occupations",
                      "Armed Forces occupations",
                      "Others","None"
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
                const Text("Household Members", style: TextStyle(fontSize: 18)),

                const SizedBox(height: 15),

                _twoFields(
                  _buildNumberField("No. of HH members"),
                  _buildNumberField("Male"),
                ),

                const SizedBox(height: 15),

                _twoFields(
                  _buildNumberField("Female"),
                  _buildNumberField("No. of Families"),
                ),

                const SizedBox(height: 25),
                const Text("Infants & Preschool Children", style: TextStyle(fontSize: 18)),

                const SizedBox(height: 15),

                _twoFields(
                  _buildNumberField("0-5 months old"),
                  _buildNumberField("6-11 months old"),
                ),

                const SizedBox(height: 15),

                _twoFields(
                  _buildNumberField("12-23 months old"),
                  _buildNumberField("24-59 months old"),
                ),

                const SizedBox(height: 25),
                const Text("Women Status", style: TextStyle(fontSize: 18)),

                const SizedBox(height: 15),

                _twoFields(
                  _buildNumberField("Pregnant"),
                  _buildNumberField("Lactating"),
                ),

                const SizedBox(height: 25),
                const Text("Nutritional Status", style: TextStyle(fontSize: 18)),

                const SizedBox(height: 15),

                _twoFields(
                  _buildNumberField("Severely Underweight"),
                  _buildNumberField("Underweight"),
                ),

                const SizedBox(height: 15),

                _twoFields(
                  _buildNumberField("Normal weight"),
                  _buildNumberField("Severely Wasted"),
                ),

                const SizedBox(height: 15),

                _twoFields(
                  _buildNumberField("Wasted"),
                  _buildNumberField("Overweight"),
                ),

                const SizedBox(height: 15),

                _twoFields(
                  _buildNumberField("Obese"),
                  _buildNumberField("Severely Stunted"),
                ),

                const SizedBox(height: 15),

                _buildNumberField("Stunted"),

                const SizedBox(height: 25),
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

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
onPressed: () async {
  final household = Household(
    householdNo: householdNo,
    barangay: barangay,
    occupation: occupation,
    education: education,
    toilet: toilet,
    water: water,
    food: food,
    iodizedSalt: iodizedSalt,
    ifr: ifr,
  );

  await DBHelper.instance.insertHousehold(household);

  setState(() => householdNo++);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Saved to SQLite!")),
  );
},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text("Add Household"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ FIX 2: RESPONSIVE ROW (NO OVERFLOW)
  Widget _twoFields(Widget a, Widget b) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              a,
              const SizedBox(height: 15),
              b,
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(child: a),
              const SizedBox(width: 15),
              Expanded(child: b),
            ],
          );
        }
      },
    );
  }

  Widget _buildTextField(String label) {
    return TextField(
      decoration: _inputDecoration(label),
    );
  }

  Widget _buildNumberField(
    String label, {
    String? value,
    bool readOnly = false,
  }) {
    return TextField(
      controller: value != null ? TextEditingController(text: value) : null,
      readOnly: readOnly,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(label),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text("Select $label"),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor),
      ),
    );
  }
}