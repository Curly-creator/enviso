import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enviso/services/userdata.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataBaseFireStore {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user');

  Future updateUserData(UserData user) async {
    return await userCollection.doc(user.uid).set({"name": user.name});
  }

  Future getUserName(uid) async {
    final ref = userCollection.doc(uid).withConverter(
        fromFirestore: UserData.fromFireStore,
        toFirestore: (UserData userData, _) => userData.toFirestore());
    final docSnap = await ref.get();
    final user = docSnap.data();
    if (user != null) {
      return user.name;
    } else {
      return 'Error';
    }
  }
}
