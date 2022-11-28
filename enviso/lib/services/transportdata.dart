import 'dart:convert';
import 'dart:async' show Future;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/cupertino.dart';

class TransportData {
  late String? date;
  late String? vehicle;
  late int? distance;
  late int? co2e;

  TransportData({this.date, this.vehicle, this.distance});

  List<String> month = [
    'JANUARY',
    'FEBURARY',
    'MARCH',
    'APRIL',
    'JULY',
    'JUNE',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER'
  ];

  factory TransportData.fromJson(Map<String, dynamic> json) {
    return TransportData(
      date: json['date'],
      vehicle: json['vehicle'],
      distance: json['distance'],
    );
  }

  Map<String, dynamic> toJson() =>
      {'date': date, 'vehicle': vehicle, 'distance': distance};

  Future getJsonData() async {
    Map<String, dynamic> data = await jsonDecode('assets/transport/2022/bla.json');
    var transport = TransportData.fromJson(data);
    print(transport);
    // month.forEach((element) => {
    //   Future<String> loadAsset() async {
    //     return await rootBundle.loadString('assets/transport/2022/2022_$element.json');
    //   DocumentSnapshotMap<String, dynamic> transportData =
    //       jsonEncode(loadAsset()) as DocumentSnapshot<Map<String, dynamic>,
    //   }
    // }
  }
}
