import 'dart:convert';
import 'package:enviso/services/transportdata.dart';

class TransportApi {
  List<String> months = [
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

  Future<List<TransportData>> getData() async {
    var transportDataList = <TransportData>[];
    for (var month in months) {
      final data = await jsonDecode('transport/2020/2020_$month.json');
      final jsonData = json.decode(data);
      var jsonTimeline = jsonData['timelineObjects'];
      for (var activity in jsonTimeline) {
        if (activity['activitySegment'] != null) {
          TransportData transportData =
              TransportData.fromJson(activity['activitySegment']);
          transportDataList.add(transportData);
        }
      }
    }
    return transportDataList;
  }
}
