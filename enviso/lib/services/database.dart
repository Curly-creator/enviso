import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enviso/services/transportdata.dart';
import 'package:enviso/services/userdata.dart';

class DatabaseService {
  late UserData user;

  CollectionReference get transportCollection => FirebaseFirestore.instance
      .collection('user')
      .doc(user.uid)
      .collection('transport');

  Future updateTransportData(TransportData transportData) async {
    return await transportCollection.add({
      'date': transportData.date,
      'vehicle': transportData.vehicle,
      'distance': transportData.distance,
      'co2e' : null,
    });
  }

  Future getTransportData(TransportData transportData, uid) async {
    final ref = transportCollection.doc(uid).withConverter(
         toFirestore: TransportData.getJsonData(),
        //: (TransportData transportData, _) => transportData.toJson());
    //final docSnap = await ref.get();
    //final user = docSnap.data();
    
  }
}
