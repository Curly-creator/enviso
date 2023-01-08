import 'dart:html';

import 'package:enviso/screens/settings/settings_page.dart';
import 'package:enviso/services/transportapi.dart';
import 'package:enviso/utils/constants.dart';
import 'package:enviso/utils/widget_functions.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:core';
import '../../services/database.dart';

List<String> items = ['Alle', 'Transport', 'Konsum'];
String? selectedItem = 'Alle';

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
              addVerticalSpace(padding),
              //ButtonBar
              Padding(
                  padding: sidePadding,
                  child: ButtonBar(
                    // ignore: sort_child_properties_last
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colorGreen,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0))),
                        child: const Text(
                          'Heute',
                          style: headline5,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colorGreen,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0))),
                        child: const Text(
                          'Jahr',
                          style: headline5,
                        ),
                      ),
                      //DropdownButton
                      DropdownButtonHideUnderline(
                          child: DropdownButton(
                        value: selectedItem,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        //style: headline5,
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
              addVerticalSpace(300),
              //PieChart
              Padding(
                  padding: sidePadding,
                  child: FutureBuilder(
                      future: DatabaseService.getCalculationData(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          return AspectRatio(
                            aspectRatio: 5,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {
                                    setState((() {
                                      Map<String, dynamic> tryData =
                                          snapshot.data as Map<String, dynamic>;
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
                      })),
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
              )
            ],
          ),
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
