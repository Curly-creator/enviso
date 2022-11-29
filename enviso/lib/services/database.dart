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
    return await userCollection
        .doc(user.uid)
        .set({'user_name': 'username', 'car_size': 1, 'fuel_type': 1});
  }

  Future updateTransportData(TransportData transportData) async {
    return await transportCollection.add({
      'timestamp': transportData.timestamp,
      'vehicle': transportData.vehicle,
      'distance': transportData.distance! / 1000,
      'co2e': null,
    });
  }

  Future updateCarSize(int carSize) async {
    return await userCollection.doc(user.uid).update({'car_size': carSize});
  }

  Future updateFuelType(int fuelType) async {
    return await userCollection.doc(user.uid).update({'fuel_type': fuelType});
  }

  Future updateUsername(String username) async {
    return await userCollection.doc(user.uid).update({'user_name': username});
  }

  Future deleteuser() async {
    return await userCollection.doc(user.uid).delete();
  }
}
