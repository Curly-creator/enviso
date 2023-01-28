import 'dart:core';
import 'package:enviso/utils/constants.dart';
import 'package:enviso/screens/home/trend_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../services/database.dart';

class DatabasePieChart extends StatefulWidget {
  final int time;
  final String category;

  const DatabasePieChart(
      {required this.time, required this.category, super.key});

  @override
  State<DatabasePieChart> createState() => _DatabasePieChartState();

  static final config = {
    "FLYING":
        PieSectionConfig("Flieger", const Color(0xff0293ee), 'assets/images/fly.svg'),
    "IN_BUS":
        PieSectionConfig("Bus", const Color(0xfff8b250), 'assets/images/bus.svg'),
    "IN_PASSENGER_VEHICLE":
        PieSectionConfig("Auto", const Color(0xff13d38e), 'assets/images/car.svg'),
    "IN_SUBWAY": PieSectionConfig(
        "U_Bahn", const Color(0xff0293ee), 'assets/images/subway.svg'),
    "IN_TRAIN":
        PieSectionConfig("Zug", const Color(0xff0293ee), 'assets/images/train.svg'),
    "IN_TRAM":
        PieSectionConfig("Tram", const Color(0xffff82ab), 'assets/images/tram.svg'),
    "transport": PieSectionConfig(
        "Transport", const Color(0xffff82ab), 'assets/images/transport.svg'),
    "consum": PieSectionConfig(
        "Consum", const Color(0xffff82ab), 'assets/images/consum.svg'),
    "Food and Drink": PieSectionConfig(
        "Food and Drink", const Color(0xffff82ab), 'assets/images/food.svg')
  };
}

class _DatabasePieChartState extends State<DatabasePieChart> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
            DatabaseService.getCalculationData(widget.time, widget.category),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, double>> snapshot) {
          if (snapshot.hasError) {
            return Text('Daten konnten nicht geladen werden',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: Colors.black));
          }
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) return const Text("No data");
            return AspectRatio(
              aspectRatio: 5,
              child: PieChart(
                PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 100,
                    sections: showingSections(snapshot.data!, context),
              ),
            ));
          } else {
            return const Text("Loading Data.");
          }
        });
  }

  static final config = {
    "FLYING": PieSectionConfig("Flieger", colorGreen, 'images/fly.svg'),
    "IN_BUS": PieSectionConfig("Bus", colorGreen8, 'images/bus.svg'),
    "IN_PASSENGER_VEHICLE":
        PieSectionConfig("Auto", colorGreen6, 'images/car.svg'),
    "IN_SUBWAY": PieSectionConfig("U_Bahn", colorGreen4, 'images/subway.svg'),
    "IN_TRAIN": PieSectionConfig("Zug", colorGreen2, 'images/train.svg'),
    "IN_TRAM": PieSectionConfig("Tram", colorGreen1, 'images/tram.svg'),
  };

  List<PieChartSectionData> showingSections(
      Map<String, double> data, BuildContext context) {
    return data.entries
        .map((entry) => PieChartSectionData(
              color: DatabasePieChart.config[entry.key]!.color,
              value: entry.value,
              title: DatabasePieChart.config[entry.key]!.name,
              radius: MediaQuery.of(context).size.width / 5,
              titleStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xffffffff),
              ),
              badgeWidget: _Badge(
                DatabasePieChart.config[entry.key]!.picture,
                size: 35,
                borderColor: const Color(0xff34eb8c),
              ),
              badgePositionPercentageOffset: 0.85,
            ))
        .toList();
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.svgAsset, {
    required this.size,
    required this.borderColor,
  });
  final String svgAsset;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: SvgPicture.asset(
          svgAsset,
        ),
      ),
    );
  }
}

class PieSectionConfig {
  String name;
  Color color;
  String picture;

  PieSectionConfig(this.name, this.color, this.picture);
}
