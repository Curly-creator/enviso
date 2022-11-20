import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});
  // colection reference
  final CollectionReference transportCollection =
      FirebaseFirestore.instance.collection('transport');

  Future updateUserData(String vehicle, int distance) async { 
    return await transportCollection.doc(uid).set({
      'vehicle': vehicle,
      'disctance': distance,
    });
  }
}
