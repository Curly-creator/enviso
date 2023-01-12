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

const List<Widget> buttonItems = <Widget>[
  Text('Gesamt'),
  Text('Monat'),
  Text('Jahr')
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
  final List<bool> _selectedItems = [true, false, false];

  Widget buildToggleButton() => SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ToggleButtons(
              onPressed: (index) {
                setState(() {
                  for (int i = 0; i < _selectedItems.length; i++) {
                    _selectedItems[i] = i == index;
                  }
                });
              },
              borderRadius: const BorderRadius.all(Radius.circular(50)),
              selectedBorderColor: colorGreen,
              selectedColor: colorBlack,
              fillColor: colorGreen,
              textStyle: headline5,
              constraints: const BoxConstraints(
                minHeight: 30.0,
                minWidth: 60.0,
              ),
              isSelected: _selectedItems,
              children: buttonItems,
            ),
          ],
        ),
      );

  Widget buildDropDown() => DropdownButtonHideUnderline(
          child: DropdownButton(
        value: selectedItem,
        icon: const Icon(Icons.arrow_drop_down),
        elevation: 16,
        borderRadius: const BorderRadius.all(Radius.circular(50.0)),
        onChanged: (item) => setState(() => selectedItem = item),
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: headline5,
                  ),
                ))
            .toList(),
      ));

  Widget buildstartLine() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
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
      );

  Widget buildheadline() => const Text(
        'Mein Fußabdruck',
        style: headline1,
      );

  Widget buildGetData() {
    return ElevatedButton(
        onPressed: TransportApi.getTransportData,
        style: ElevatedButton.styleFrom(
            backgroundColor: colorGreen,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0))),
        child: const Text(
          'Daten abrufen',
          style: buttonText,
          textAlign: TextAlign.center,
        ));
  }

  Widget buildFutureBuilder() {
    return FutureBuilder(
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
        });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    const double padding = 25;
    const sidePadding = EdgeInsets.symmetric(horizontal: padding);
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            addVerticalSpace(padding),
            //Menü Linie
            Padding(padding: sidePadding, child: buildstartLine()),
            addVerticalSpace(padding),
            //Home Page Ueberschrift
            Padding(
              padding: sidePadding,
              child: buildheadline(),
            ),
            addVerticalSpace(padding),
            //ToggleButtonnBar
            Padding(
              padding: sidePadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildToggleButton(),
                  addHorizontalSpace(20),
                  buildDropDown(),
                ],
              ),
            ),
            addVerticalSpace(20),
            Padding(
                padding: sidePadding,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [buildGetData()])),
            addVerticalSpace(300),
            //PieChart
            Padding(padding: sidePadding, child: buildFutureBuilder()),
            addVerticalSpace(400),
          ],
        ),
      )),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(6, (i) {
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: colorGreen,
            value: fly,
            title: 'Flieger',
            radius: MediaQuery.of(context).size.width / 5,
            titleStyle: headline4,
          );
        case 1:
          return PieChartSectionData(
            color: colorGreen8,
            value: bus,
            title: 'Bus',
            radius: MediaQuery.of(context).size.width / 5,
            titleStyle: headline4,
          );
        case 2:
          return PieChartSectionData(
            color: colorGreen6,
            value: car,
            title: 'Auto',
            radius: MediaQuery.of(context).size.width / 5,
            titleStyle: headline4,
          );
        case 3:
          return PieChartSectionData(
            color: colorGreen4,
            value: subway,
            title: 'U-Bahn',
            radius: MediaQuery.of(context).size.width / 5,
            titleStyle: headline4,
          );
        case 4:
          return PieChartSectionData(
            color: colorGreen2,
            value: train,
            title: 'Zug',
            radius: MediaQuery.of(context).size.width / 5,
            titleStyle: headline4,
          );
        case 5:
          return PieChartSectionData(
            color: colorGreen1,
            value: tram,
            title: 'Tram',
            radius: MediaQuery.of(context).size.width / 5,
            titleStyle: headline4,
          );
        default:
          throw Error();
      }
    });
  }
}
