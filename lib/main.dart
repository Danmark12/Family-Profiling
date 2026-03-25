// main.dart

import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/household_page.dart';
import 'pages/barangay_page.dart';

void main() {
  runApp(const CensusApp());
}

class CensusApp extends StatelessWidget {
  const CensusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  final pages = [
    const HomePage(),
    const HouseholdPage(),
    const BarangayPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Household"),
          BottomNavigationBarItem(icon: Icon(Icons.location_city), label: "Barangay"),
        ],
      ),
    );
  }
}