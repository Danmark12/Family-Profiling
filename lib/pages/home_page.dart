// home_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int male = 0;
  int female = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    final data = await DBHelper.instance.getAll();
    int m = 0, f = 0;
    for (var hh in data) {
      m += hh.male;
      f += hh.female;
    }
    setState(() {
      male = m;
      female = f;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: male.toDouble(), title: "Male"),
            PieChartSectionData(value: female.toDouble(), title: "Female"),
          ],
        ),
      ),
    );
  }
}