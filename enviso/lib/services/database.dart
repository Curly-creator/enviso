import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enviso/services/transportdata.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final user = FirebaseAuth.instance.currentUser!;

  CollectionReference get transportCollection => FirebaseFirestore.instance
      .collection('user')
      .doc(user.uid)
      .collection('transport');

  Future updateTransportData(TransportData transportData) async {
    return await transportCollection.add({
      //'date': transportData.timestamp,
      'vehicle': transportData.vehicle,
      'distance': transportData.distance! / 1000,
      'co2e': null,
    });
  }
}
