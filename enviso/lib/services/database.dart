import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enviso/services/transportdata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class QueryResult {
  String collectionName;
  QuerySnapshot<Map<String, dynamic>> queryResult;

  QueryResult(this.collectionName, this.queryResult);
}

class DatabaseService {
  static final user = FirebaseAuth.instance.currentUser!;

  static CollectionReference get transportCollection =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transport');

  static final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  static Future createUser() async {
    return await userCollection.doc(user.uid).set({
      'user_name': 'username',
      'engine_size': 'medium',
      'fuel_type': 'petrol',
      'access_token': '',
      'filepath': ''
    });
  }

  static Future updateFilePath(String filePath) async {
    return await userCollection.doc(user.uid).update({'filepath': filePath});
  }

  static Future updateTokenPlaid(String token) async {
    return await userCollection.doc(user.uid).update({'access_token': token});
  }

  static Future updateTransportData(TransportData transportData) async {
    return await transportCollection.add({
      'timestamp': transportData.timestamp,
      'vehicle': transportData.vehicle,
      'distance': transportData.distance! / 1000,
      'co2e': null,
    });
  }

  static Future updateEngineSize(int index) async {
    var engineSize = convEngineSize(index);
    return await userCollection
        .doc(user.uid)
        .update({'engine_size': engineSize});
  }

  static Future updateFuelType(int index) async {
    var fuelType = convFuelType(index);
    return await userCollection.doc(user.uid).update({'fuel_type': fuelType});
  }

  static Future updateUsername(String username) async {
    return await userCollection.doc(user.uid).update({'user_name': username});
  }

  static Future<Map<String, double>> getCalculationData(
      int chosenTime, String chosenCategory) async {
    Map<String, double> pieChartData = {};
    Timestamp now = Timestamp.now();
    var startTime = Timestamp.fromMillisecondsSinceEpoch(
        now.millisecondsSinceEpoch - chosenTime);

    if (chosenCategory == 'All') {
      var categories = ["transport", "consum"];
      var queryResults = await Future.wait(categories.map((c) => userCollection
          .doc(user.uid)
          .collection(c)
          .where("timestamp", isGreaterThanOrEqualTo: startTime)
          .where("timestamp", isLessThanOrEqualTo: now)
          .get()
          .then((res) => QueryResult(c, res))));
      for (var result in queryResults) {
        for (var doc in result.queryResult.docs) {
          var data = doc.data();
          pieChartData.update(
              result.collectionName, (value) => value + data["co2e"],
              ifAbsent: () => data["co2e"]);
        }
      }
    } else {
      final categoryRef = userCollection
          .doc(user.uid)
          .collection(chosenCategory)
          .where("timestamp", isGreaterThanOrEqualTo: startTime)
          .where("timestamp", isLessThanOrEqualTo: now);
      //timestamp und await future
      var queryResult = await categoryRef.get();
      for (var doc in queryResult.docs) {
        var data = doc.data();
        pieChartData.update(data["vehicle"], (value) => value + data["co2e"],
            ifAbsent: () => data["co2e"]);
      }
    }
    print(pieChartData);
    return pieChartData;
  }

  static Future deleteuser() async {
    return await userCollection.doc(user.uid).delete();
  }

  static String convEngineSize(index) {
    switch (index) {
      case 1:
        return 'small';
      case 2:
        return 'medium';
      case 3:
        return 'large';
      default:
        return 'medium';
    }
  }

  static String convFuelType(index) {
    switch (index) {
      case 1:
        return 'diesel';
      case 2:
        return 'petrol';
      case 3:
        return 'cng';
      case 4:
        return 'fcev';
      case 5:
        return 'bev';
      default:
        return 'petrol';
    }
  }
}
