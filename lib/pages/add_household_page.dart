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
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  int _currentPage = 0;

  // CONTROLLERS
  final hhNo = TextEditingController();
  final name = TextEditingController();
  final occupation = TextEditingController();
  String purok = "Purok 1";
  String education = "Elem. undergraduate";

  final male = TextEditingController();
  final female = TextEditingController();
  final pregnant = TextEditingController();
  final lactating = TextEditingController();

  final su = TextEditingController();
  final uw = TextEditingController();
  final nw = TextEditingController();
  final sw = TextEditingController();
  final w = TextEditingController();
  final ow = TextEditingController();
  final ob = TextEditingController();
  final ss = TextEditingController();
  final st = TextEditingController();

  final inf0_5 = TextEditingController();
  final inf6_11 = TextEditingController();
  final pre0_23 = TextEditingController();
  final pre12_59 = TextEditingController();
  final pre24_59 = TextEditingController();
  final breastfed = TextEditingController();
  final dewormed = TextEditingController();
  final fic = TextEditingController();

  String iodized = "Yes";
  String eatery = "No";

  int get total => (int.tryParse(male.text) ?? 0) + (int.tryParse(female.text) ?? 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Household"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [

                  // PAGE 1 – BASIC INFO
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(controller: hhNo, decoration: const InputDecoration(labelText: "Household No"), keyboardType: TextInputType.number),
                        TextFormField(controller: name, decoration: const InputDecoration(labelText: "Household Head")),
                        TextFormField(controller: occupation, decoration: const InputDecoration(labelText: "Occupation")),
                        DropdownButtonFormField(
                          value: purok,
                          items: ["Purok 1","Purok 2","Purok 3"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => purok = v!,
                          decoration: const InputDecoration(labelText: "Purok"),
                        ),
                        DropdownButtonFormField(
                          value: education,
                          items: ["Elem. undergraduate","Elem. Graduate","HU undergraduate","HS Graduate"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => education = v!,
                          decoration: const InputDecoration(labelText: "Education"),
                        ),
                      ],
                    ),
                  ),

                  // PAGE 2 – POPULATION
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(controller: male, decoration: const InputDecoration(labelText: "Male"), keyboardType: TextInputType.number),
                        TextFormField(controller: female, decoration: const InputDecoration(labelText: "Female"), keyboardType: TextInputType.number),
                        Text("Total: $total"),
                        TextFormField(controller: pregnant, decoration: const InputDecoration(labelText: "Pregnant")),
                        TextFormField(controller: lactating, decoration: const InputDecoration(labelText: "Lactating")),
                      ],
                    ),
                  ),

                  // PAGE 3 – NUTRITION
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(controller: su, decoration: const InputDecoration(labelText: "Severely underweight"), keyboardType: TextInputType.number),
                        TextFormField(controller: uw, decoration: const InputDecoration(labelText: "Underweight"), keyboardType: TextInputType.number),
                        TextFormField(controller: nw, decoration: const InputDecoration(labelText: "Normal weight"), keyboardType: TextInputType.number),
                        TextFormField(controller: sw, decoration: const InputDecoration(labelText: "Severely wasted"), keyboardType: TextInputType.number),
                        TextFormField(controller: w, decoration: const InputDecoration(labelText: "Wasted"), keyboardType: TextInputType.number),
                        TextFormField(controller: ow, decoration: const InputDecoration(labelText: "Overweight"), keyboardType: TextInputType.number),
                        TextFormField(controller: ob, decoration: const InputDecoration(labelText: "Obese"), keyboardType: TextInputType.number),
                        TextFormField(controller: ss, decoration: const InputDecoration(labelText: "Severely stunted"), keyboardType: TextInputType.number),
                        TextFormField(controller: st, decoration: const InputDecoration(labelText: "Stunted"), keyboardType: TextInputType.number),
                      ],
                    ),
                  ),

                  // PAGE 4 – INFANTS & CHILDREN
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(controller: inf0_5, decoration: const InputDecoration(labelText: "Infants 0-5 months"), keyboardType: TextInputType.number),
                        TextFormField(controller: inf6_11, decoration: const InputDecoration(labelText: "Infants 6-11 months"), keyboardType: TextInputType.number),
                        TextFormField(controller: pre0_23, decoration: const InputDecoration(labelText: "Preschool 0-23 months"), keyboardType: TextInputType.number),
                        TextFormField(controller: pre12_59, decoration: const InputDecoration(labelText: "Preschool 12-59 months"), keyboardType: TextInputType.number),
                        TextFormField(controller: pre24_59, decoration: const InputDecoration(labelText: "Preschool 24-59 months"), keyboardType: TextInputType.number),
                        TextFormField(controller: breastfed, decoration: const InputDecoration(labelText: "0-5 months exclusively breastfed"), keyboardType: TextInputType.number),
                        TextFormField(controller: dewormed, decoration: const InputDecoration(labelText: "School children dewormed"), keyboardType: TextInputType.number),
                        TextFormField(controller: fic, decoration: const InputDecoration(labelText: "Fully immunized children (FIC)"), keyboardType: TextInputType.number),
                      ],
                    ),
                  ),

                  // PAGE 5 – HOUSEHOLD PRACTICES
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField(
                          value: iodized,
                          items: ["Yes","No"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => iodized = v!,
                          decoration: const InputDecoration(labelText: "Iodized Salt"),
                        ),
                        DropdownButtonFormField(
                          value: eatery,
                          items: ["Yes","No"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => eatery = v!,
                          decoration: const InputDecoration(labelText: "Eatery/Carenderia"),
                        ),
                      ],
                    ),
                  ),

                  // PAGE 6 – REVIEW & SUBMIT
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text("Review your entries", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text("Household No: ${hhNo.text}"),
                        Text("Name: ${name.text}"),
                        Text("Occupation: ${occupation.text}"),
                        Text("Purok: $purok"),
                        Text("Education: $education"),
                        Text("Male: ${male.text}"),
                        Text("Female: ${female.text}"),
                        Text("Total: $total"),
                        Text("Pregnant: ${pregnant.text}"),
                        Text("Lactating: ${lactating.text}"),
                        Text("Severely underweight: ${su.text}"),
                        Text("Underweight: ${uw.text}"),
                        Text("Normal weight: ${nw.text}"),
                        Text("Severely wasted: ${sw.text}"),
                        Text("Wasted: ${w.text}"),
                        Text("Overweight: ${ow.text}"),
                        Text("Obese: ${ob.text}"),
                        Text("Severely stunted: ${ss.text}"),
                        Text("Stunted: ${st.text}"),
                        Text("Infants 0-5 months: ${inf0_5.text}"),
                        Text("Infants 6-11 months: ${inf6_11.text}"),
                        Text("Preschool 0-23 months: ${pre0_23.text}"),
                        Text("Preschool 12-59 months: ${pre12_59.text}"),
                        Text("Preschool 24-59 months: ${pre24_59.text}"),
                        Text("Breastfed: ${breastfed.text}"),
                        Text("Dewormed: ${dewormed.text}"),
                        Text("FIC: ${fic.text}"),
                        Text("Iodized Salt: $iodized"),
                        Text("Eatery: $eatery"),

                        const SizedBox(height: 20),
                        ElevatedButton(
                          child: const Text("Submit"),
                          onPressed: () async {
                            await DBHelper.instance.insert(Household(
                              householdNo: int.parse(hhNo.text),
                              name: name.text,
                              purok: purok,
                              occupation: occupation.text,
                              education: education,
                              male: int.parse(male.text),
                              female: int.parse(female.text),
                              total: total,
                              pregnant: int.parse(pregnant.text),
                              lactating: int.parse(lactating.text),

                              su: int.tryParse(su.text) ?? 0,
                              uw: int.tryParse(uw.text) ?? 0,
                              nw: int.tryParse(nw.text) ?? 0,
                              sw: int.tryParse(sw.text) ?? 0,
                              w: int.tryParse(w.text) ?? 0,
                              ow: int.tryParse(ow.text) ?? 0,
                              ob: int.tryParse(ob.text) ?? 0,
                              ss: int.tryParse(ss.text) ?? 0,
                              st: int.tryParse(st.text) ?? 0,

                              inf0_5: int.tryParse(inf0_5.text) ?? 0,
                              inf6_11: int.tryParse(inf6_11.text) ?? 0,
                              pre0_23: int.tryParse(pre0_23.text) ?? 0,
                              pre12_59: int.tryParse(pre12_59.text) ?? 0,
                              pre24_59: int.tryParse(pre24_59.text) ?? 0,
                              breastfed: int.tryParse(breastfed.text) ?? 0,
                              dewormed: int.tryParse(dewormed.text) ?? 0,
                              fic: int.tryParse(fic.text) ?? 0,
                              iodized: iodized,
                              eatery: eatery,
                            ));
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                  )

                ],
              ),
            ),

            // NAVIGATION BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if(_currentPage>0)
                  ElevatedButton(
                    child: const Text("Previous"),
                    onPressed: (){
                      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      setState(()=>_currentPage--);
                    },
                  ),
                ElevatedButton(
                  child: Text(_currentPage==5?"Finish":"Next"),
                  onPressed: (){
                    if(_currentPage<5){
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      setState(()=>_currentPage++);
                    }
                  },
                )
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}