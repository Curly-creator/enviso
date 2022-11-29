import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enviso/services/transportdata.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final user = FirebaseAuth.instance.currentUser!;

  CollectionReference get transportCollection => FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('transport');

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future createUser() async {
    return await userCollection.doc(user.uid).set({
      'user_name': 'username',
      'engine_size': 'medium',
      'fuel_type': 'Petrol'
    });
  }

  Future updateTransportData(TransportData transportData) async {
    return await transportCollection.add({
      'timestamp': transportData.timestamp,
      'vehicle': transportData.vehicle,
      'distance': transportData.distance! / 1000,
      'co2e': null,
    });
  }

  Future updateEngineSize(int index) async {
    var engineSize = convEngineSize(index);
    return await userCollection
        .doc(user.uid)
        .update({'engine_size': engineSize});
  }

  Future updateFuelType(int index) async {
    var fuelType = convFuelType(index);
    return await userCollection.doc(user.uid).update({'fuel_type': fuelType});
  }

  Future updateUsername(String username) async {
    return await userCollection.doc(user.uid).update({'user_name': username});
  }

  Future deleteuser() async {
    return await userCollection.doc(user.uid).delete();
  }

  String convEngineSize(index) {
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

  String convFuelType(index) {
    switch (index) {
      case 1:
        return 'diesel';
      case 2:
        return 'petrol';
      case 3:
        return 'cng';
      case 4:
        return 'fcew';
      case 5:
        return 'bev';
      default:
        return 'petrol';
    }
  }
}
