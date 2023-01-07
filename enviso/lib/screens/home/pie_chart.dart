import 'dart:core';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../services/database.dart';

class PieChartSite extends StatefulWidget {
  const PieChartSite({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<PieChartSite> {
  late double fly = 10;
  late double bus = 10;
  late double car = 10;
  late double subway = 10;
  late double train = 10;
  late double tram = 10;

  String choosenTime = ".calculations";
 
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DatabaseService.getCalculationData("","",""),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return AspectRatio(
                aspectRatio: 5,
                child: BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(
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
                    titlesData: titlesData,
                    borderData: borderData,
                    barGroups: barGroups,
                    gridData: FlGridData(show: false),
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1500,
                  ),
                ));
          } else {
            return Container();
          }
        });
}

List<BarChartGroupData> get barGroups => [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: fly,
            color: const Color(0xff34eb8c),
          )
        ],
        showingTooltipIndicators: [0],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: bus,
            color: const Color(0xff34eb8c),
          )
        ],
        showingTooltipIndicators: [0],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: car,
            color: const Color(0xff34eb8c),
          )
        ],
        showingTooltipIndicators: [0],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: subway,
            color: const Color(0xff34eb8c),
          )
        ],
        showingTooltipIndicators: [0],
      ),
      BarChartGroupData(
        x: 4,
        barRods: [
          BarChartRodData(
            toY: train,
            color: const Color(0xff34eb8c),
          )
        ],
        showingTooltipIndicators: [0],
      ),
      BarChartGroupData(
        x: 5,
        barRods: [
          BarChartRodData(
            toY: tram,
            color: const Color(0xff34eb8c),
          )
        ],
        barsSpace: 1,
        showingTooltipIndicators: [0],
      ),
    ];
}

Widget getTitles(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Color.fromARGB(255, 15, 16, 16),
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );
  String text;
  switch (value.toInt()) {
    case 0:
      text = 'fly';
      break;
    case 1:
      text = 'bus';
      break;
    case 2:
      text = 'car';
      break;
    case 3:
      text = 'subway';
      break;
    case 4:
      text = 'train';
      break;
    case 5:
      text = 'tram';
      break;
    default:
      text = '';
      break;
  }
  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 2,
    child: Text(text, style: style),
  );
}

FlTitlesData get titlesData => FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: getTitles,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );

FlBorderData get borderData => FlBorderData(
      show: false,
    );


