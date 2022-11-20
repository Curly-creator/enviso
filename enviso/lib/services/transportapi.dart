import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:enviso/services/transportdata.dart';

class TransportApi {
  static Future<List<TransportData>> getData(BuildContext context) async {
    var transportDataList = <TransportData>[];
    final assetBundle = DefaultAssetBundle.of(context);
    final data = await assetBundle.loadString('transport/2020/2020_APRIL.json');
    final jsonData = json.decode(data);
    var jsonTimeline = jsonData['timelineObjects'];
    for (var activity in jsonTimeline) {
      if (activity['activitySegment'] != null) {
        TransportData transportData =
            TransportData.fromJson(activity['activitySegment']);
        transportDataList.add(transportData);
      }
    }
    return transportDataList;
  }
}
