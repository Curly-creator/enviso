import 'dart:html';

import 'package:enviso/screens/settings/settings_page.dart';
import 'package:enviso/services/transportapi.dart';
import 'package:enviso/utils/constants.dart';
import 'package:enviso/utils/widget_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import '../../services/database.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

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
        ),
      ),
    );
  }
}
