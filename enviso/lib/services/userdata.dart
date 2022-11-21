import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String uid;
  late String? name;

  UserData({required this.uid, this.name});

  factory UserData.fromFireStore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? option) {
    final data = snapshot.data();

    return UserData(uid: data?['uid'], name: data?['name']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (uid != null) "uid": uid,
      if (name != null) "name": name,
    };
  }
}
