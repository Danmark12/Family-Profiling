// lib/pages/barangay_page.dart
import 'package:flutter/material.dart';

class BarangayPage extends StatefulWidget {
  const BarangayPage({super.key});

  @override
  State<BarangayPage> createState() => _BarangayPageState();
}

class _BarangayPageState extends State<BarangayPage> {
  final TextEditingController controller = TextEditingController();
  List<String> barangays = [];

  void addBarangay() {
    if (controller.text.isNotEmpty) {
      setState(() {
        barangays.add(controller.text);
        controller.clear();
      });
    }
  }

  void deleteBarangay(int index) {
    setState(() {
      barangays.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Barangay List"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            
            // Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: "Enter Barangay Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addBarangay,
                  child: const Text("Add"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // List
            Expanded(
              child: barangays.isEmpty
                  ? const Center(child: Text("No Barangay Added"))
                  : ListView.builder(
                      itemCount: barangays.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.location_city),
                            title: Text(barangays[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteBarangay(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}