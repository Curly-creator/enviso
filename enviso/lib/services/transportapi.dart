import 'dart:convert';
import 'package:enviso/services/transportdata.dart';
import 'package:file_picker/file_picker.dart';

import 'database.dart';

class TransportApi {
  static Future<List<TransportData>> getTransportData() async {
    var transportDataList = <TransportData>[];
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        final fileBytes = result.files.first.bytes;

        var data = await jsonDecode(utf8.decode(fileBytes as List<int>));
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
      }
    } catch (e) {
      // JSON not found
    }
    for (var element in transportDataList) {
      DatabaseService().updateTransportData(element);
    }

    return transportDataList;
  }
}
