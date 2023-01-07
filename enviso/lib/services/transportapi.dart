import 'dart:convert';
import 'package:enviso/services/transportdata.dart';
import 'package:file_picker/file_picker.dart';

import 'database.dart';

class TransportApi {
  /*static List<String> months = [
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
  ];*/

  /*static _pickfile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;

    final file = result.files.first;

    return file.path;
  }*/

  static Future<List<TransportData>> getTransportData() async {
    var transportDataList = <TransportData>[];
    try {
      //var jsonString = 'transport/$year/$year' '_$month.json';
      //var jsonString = _pickfile();
      //final String response = await rootBundle.loadString(jsonString);

      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        final fileBytes = result.files.first.bytes;
        //final fileName = result.files.first.name;

        // Upload file
        /*TaskSnapshot response = await FirebaseStorage.instance
            .ref('uploads/$fileName')
            .putData(fileBytes!);*/
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
