class TransportData {
  late String vehicle;
  late int distance;

  TransportData({required this.vehicle, required this.distance});

  static TransportData fromJson(Map<String, dynamic> json) {
    var data = TransportData(
        vehicle: json['activityType'], distance: json['distance']);
    return data;
  }
}
