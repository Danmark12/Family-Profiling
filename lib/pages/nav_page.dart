import 'package:flutter/material.dart';
import 'home_page.dart';
import 'household_page.dart';

class HomeNavPage extends StatefulWidget {
  const HomeNavPage({super.key});

  @override
  State<HomeNavPage> createState() => _HomeNavPageState();
}

class _HomeNavPageState extends State<HomeNavPage> {
  int index = 0;

  final pages = [
    const HomePage(),
    const HouseholdPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index], // Render page content
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: const Color(0xFF568203),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Household"),
        ],
      ),
    );
  }
}