import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  late String? uid;
  late String? name;

  UserData({this.uid, this.name});

  factory UserData.fromFireStore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? option) {
    final data = snapshot.data();

    return UserData(name: data?['name']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
    };
  }
}
