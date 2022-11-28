import 'package:cloud_firestore/cloud_firestore.dart';

class TransportData {
  late Timestamp? timestamp;
  late String? vehicle;
  late int? distance;
  late int? co2e;

  TransportData({this.timestamp, this.vehicle, this.distance});

  factory TransportData.fromJson(Map<String, dynamic> json) {
    return TransportData(
      //timestamp: json['duration']['startTimestamp'],
      vehicle: json['activityType'],
      distance: json['distance'],
    );
  }

  Map<String, dynamic> toJson() =>
      {'timestamp': timestamp, 'vehicle': vehicle, 'distance': distance};
}
