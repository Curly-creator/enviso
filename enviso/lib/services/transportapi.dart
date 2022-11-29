import 'dart:convert';
import 'package:enviso/services/transportdata.dart';
import 'package:flutter/services.dart';

import 'database.dart';

class TransportApi {
  static List<String> months = [
    'JANUARY',
    'FEBRUARY',
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
  static List<String> years = [
    // '2020',
    // '2021',
    '2022',
  ];

  static Future<List<TransportData>> getTransportData() async {
    var transportDataList = <TransportData>[];

    for (var year in years) {
      for (var month in months) {
        try {
          var jsonString = 'transport/$year/$year' '_$month.json';
          final String response = await rootBundle.loadString(jsonString);
          var data = await jsonDecode(response);
          var jsonTimeline = data['timelineObjects'];
          for (var activity in jsonTimeline) {
            if (activity['activitySegment'] != null) {
              var vehicle = activity['activitySegment']['activityType'];
              if (vehicle == 'IN_BUS' ||
                  vehicle == 'IN_TRAIN' ||
                  vehicle == 'IN_SUBWAY' ||
                  vehicle == 'IN_TRAM' ||
                  vehicle == 'IN_PASSENGER_VEHICLE' ||
                  vehicle == 'IN_VEHICLE' ||
                  vehicle == 'FLYING') {
                TransportData transportData =
                    TransportData.fromJson(activity['activitySegment']);
                transportDataList.add(transportData);
              }
            }
          }
        } catch (e) {
          // JSON not found
        }
      }
    }
    for (var element in transportDataList) {
      DatabaseService().updateTransportData(element);
    }
    return transportDataList;
  }
}
