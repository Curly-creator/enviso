import 'dart:convert';
import 'package:enviso/services/transportdata.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

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
    '2020',
    '2021',
    '2022',
    '2023',
  ];

  static Future<File> _localFile(year, month, path) async {
    final String name = '$path/$year/$year' '_$month.json';
    return File(name);
  }

  static Future readTransportData() async {
    final path = await FilePicker.platform.getDirectoryPath();
    for (var year in years) {
      for (var month in months) {
        try {
          final file = await _localFile(year, month, path);
          final content = await file.readAsString();
          var data = jsonDecode(content);
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
                DatabaseService.updateTransportData(
                    TransportData.fromJson(activity['activitySegment']));

              }
            }
          }
        } catch (e) {
          print(e);
        }

      }
    }
  }
}
