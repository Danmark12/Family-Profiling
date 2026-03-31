import 'package:flutter/material.dart';

class BarangayPage extends StatelessWidget {
  const BarangayPage({super.key});

  @override
  Widget build(BuildContext context) {
    const avocado = Color(0xFF568203); // avocado color

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Barangay Page",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: _customButton(
            text: "Consolidated",
            color: avocado,
            onTap: () {
              // Example functionality: show a SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Consolidated button clicked!")),
              );

              // Or navigate to another page
              // Navigator.push(context, MaterialPageRoute(builder: (_) => ConsolidatedPage()));
            },
          ),
        ),
      ),
    );
  }

  Widget _customButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      splashColor: color.withOpacity(0.2),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 60,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}