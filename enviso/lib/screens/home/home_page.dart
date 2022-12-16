import 'dart:html';

import 'package:enviso/screens/settings/settings_page.dart';
import 'package:enviso/services/transportapi.dart';
import 'package:enviso/utils/constants.dart';
import 'package:enviso/utils/widget_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:core';
import '../../services/database.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double fly = 10;
  late double bus = 10;
  late double car = 10;
  late double subway = 10;
  late double train = 10;
  late double tram = 10;
  final colorList = <Color>[colorGreen, colorGreen];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    const double padding = 25;
    const sidePadding = EdgeInsets.symmetric(horizontal: padding);
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              addVerticalSpace(padding),
              Padding(
                padding: sidePadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('images/2zero.jpg', scale: 15.0),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: colorGreen,
                      child: IconButton(
                        icon: const Icon(
                          Icons.person,
                          color: colorWhite,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsPage()));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              addVerticalSpace(padding),
              const Padding(
                padding: sidePadding,
                child: Text(
                  'Mein Fußabdruck',
                  style: headline1,
                ),
              ),
              /*addVerticalSpace(padding),
              Padding(padding: sidePadding,
              child: PieChart(
            dataMap: DatabaseService.getCalculationData(),
            animationDuration: const Duration(milliseconds: 800),
            ringStrokeWidth: MediaQuery.of(context).size.width / 8,
          chartRadius: MediaQuery.of(context).size.width / 3.2,
            colorList: colorList,
            initialAngleInDegree: 0,
            chartType: ChartType.ring,
            centerText: "t CO2e / Jahr",
            chartValuesOptions:
            const ChartValuesOptions(showChartValuesOutside: true),
            legendOptions: const LegendOptions(
            showLegendsInRow: false, showLegends: false),
            ),)*/

              addVerticalSpace(padding),
              Padding(
                padding: sidePadding,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: colorGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0))),
                  icon: const Icon(Icons.data_array, size: 32),
                  label: const Text(
                    'Daten abrufen',
                    style: buttonText,
                  ),
                  onPressed: TransportApi.getTransportData,
                ),
              )
            ],
          ),
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
            const SizedBox(height: 200),
            FutureBuilder(
              future: DatabaseService.getCalculationData(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return AspectRatio(
                    aspectRatio: 5,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState((() {
                              Map<String, dynamic> tryData = snapshot.data as Map<String, dynamic>;
                              fly = tryData['FLYING']!;
                              bus = tryData['IN_BUS']!;
                              car = tryData['IN_PASSENGER_VEHICLE']!;
                              subway = tryData['IN_SUBWAY']!;
                              train = tryData['IN_TRAIN']!;
                              tram = tryData['IN_TRAM']!;
                            }));
                          },
                        ),
                        sectionsSpace: 2,
                        centerSpaceRadius: 100,
                        sections: showingSections(),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              }),
            const SizedBox(height: 200),
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

   List<PieChartSectionData> showingSections() {
    return List.generate(6, (i) {
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xff0293ee),
            value: fly,
            title: 'Flieger',
            radius: MediaQuery.of(context).size.width / 5,
            titleStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xffffffff),
            ),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xfff8b250),
            value: bus,
            title: 'Bus',
            radius: MediaQuery.of(context).size.width / 5,
            titleStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xffffffff),
            ),
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xff845bef),
            value: car,
            title: 'Auto',
            radius: MediaQuery.of(context).size.width / 5,
            titleStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xffffffff),
            ),
          );
        case 3:
          return PieChartSectionData(
            color: const Color(0xff13d38e),
            value: subway,
            title: 'U-Bahn',
            radius: MediaQuery.of(context).size.width / 5,
            titleStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xffffffff),
            ),
          );
        case 4:
          return PieChartSectionData(
            color: const Color(0xffee3b3b),
            value: train,
            title: 'Zug',
            radius: MediaQuery.of(context).size.width / 5,
            titleStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xffffffff),
            ),
          );
        case 5:
          return PieChartSectionData(
            color: const Color(0xffff82ab),
            value: tram,
            title: 'Tram',
            radius: MediaQuery.of(context).size.width / 5,
            titleStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xffffffff),
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
