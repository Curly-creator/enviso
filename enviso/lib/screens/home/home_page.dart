import 'package:enviso/screens/settings/settings_page.dart';
import 'package:enviso/services/transportapi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import '../../services/database.dart';

class HomePage extends StatelessWidget {
   HomePage({super.key});

  final colorList = <Color>[
    const Color(0xfffdcb6e),
    const Color(0xff0984e3),
    const Color(0xfffdcb6e),
    const Color(0xff0984e3)
  ];
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SettingsPage()));
          },
        )
      ]),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sign In as',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'your Email',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            PieChart(
              dataMap: DatabaseService.getCalculationData(),
              animationDuration: const Duration(milliseconds: 800),
              ringStrokeWidth: MediaQuery.of(context).size.width/8,
              chartRadius: MediaQuery.of(context).size.width / 3.2,
              colorList: colorList,
              initialAngleInDegree: 0,
              chartType: ChartType.ring,
              centerText: "t CO2e / Jahr",
              chartValuesOptions: const ChartValuesOptions(
                showChartValuesOutside: true),
              legendOptions:
                  const LegendOptions(showLegendsInRow: false, showLegends: false),
            ),   
            const SizedBox(height: 100),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(Icons.data_array, size: 32),
              label: const Text(
                'Get Data',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: TransportApi.getTransportData,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(Icons.arrow_back, size: 32),
              label: const Text(
                'Sign Out',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
          ],
        ),
      ),
    );
  }
}
