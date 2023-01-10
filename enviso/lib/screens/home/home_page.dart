import 'dart:html';

import 'package:enviso/screens/settings/settings_page.dart';
import 'package:enviso/services/transportapi.dart';
import 'package:enviso/utils/constants.dart';
import 'package:enviso/utils/widget_functions.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:core';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/database.dart';
import '../../screens/home/pie_chart.dart';
import '../plaid.dart';

List<String> items = ['Alle', 'Transport', 'Konsum'];
String? selectedItem = 'Alle';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final colorList = <Color>[colorGreen, colorGreen];

  int chosenTime = DateTime.now().millisecondsSinceEpoch;
  String chosenCategory = "transport";

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
              addVerticalSpace(padding),
              Padding(
                  padding: sidePadding,
                  child: ButtonBar(
                    // ignore: sort_child_properties_last
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () => setState(() {
                          chosenTime = DateTime.now().millisecondsSinceEpoch;
                        }),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colorGreen,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0))),
                        child: const Text(
                          'Alle',
                          style: headline5,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          chosenTime = 604800000;;
                        }),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colorGreen,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0))),
                        child: const Text(
                          'Monat',
                          style: headline5,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          chosenTime = 1000 * 60 * 60 * 24 * 365;
                          chosenCategory = "transport";
                        }),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colorGreen,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0))),
                        child: const Text(
                          'Jahr',
                          style: headline5,
                        ),
                      ),
                      DropdownButtonHideUnderline(
                          child: DropdownButton(
                        value: selectedItem,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        style: headline5,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50.0)),
                        onChanged: (item) =>
                            setState(() => selectedItem = item),
                        items: items
                            .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: headline5,
                                  ),
                                ))
                            .toList(),
                      ))
                    ],
                    alignment: MainAxisAlignment.center,
                  )),
              addVerticalSpace(175),
              Padding(
                  padding: sidePadding,
                  child: DatabasePieChart(
                      time: chosenTime, category: chosenCategory)),
              addVerticalSpace(200),
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
              ),
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
                    'Plaid Link',
                    style: buttonText,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PlaidScreen()));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
