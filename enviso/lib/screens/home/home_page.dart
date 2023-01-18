import 'package:enviso/screens/plaid.dart';
import 'package:enviso/screens/settings/settings_page.dart';
import 'package:enviso/services/transportapi.dart';
import 'package:enviso/utils/constants.dart';
import 'package:enviso/utils/widget_functions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:core';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/database.dart';
import '../../screens/home/pie_chart.dart';
import '../plaid.dart';
import 'package:url_launcher/url_launcher.dart';

List<String> items = ['Alle', 'Transport', 'Konsum'];
String? selectedItem = 'Alle';
const defaultText = TextStyle(color: Colors.white);
const linkText = TextStyle(color: Colors.blue);

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
  final colorList = <Color>[colorGreen, colorGreen];
  final List<bool> _selectedItems = [true, false, false];

  int chosenTime = DateTime.now().millisecondsSinceEpoch;
  String chosenCategory = "transport";

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
          Image.asset('assets/images/2zero.jpg', scale: 15.0),
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
        onPressed: TransportApi.readTransportData,
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
            Padding(
                padding: sidePadding,
                child: DatabasePieChart(
                    time: chosenTime, category: chosenCategory)),
            addVerticalSpace(400),
          ],
        ),
      )),
    );
  }
}
