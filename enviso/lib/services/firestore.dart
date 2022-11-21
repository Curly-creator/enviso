import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enviso/services/userdata.dart';

class DataBaseFireStore {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user');

  Future updateUserData(UserData user) async {
    return await userCollection.doc(user.uid).set(user.name);
  }
}
