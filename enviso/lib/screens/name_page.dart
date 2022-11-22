import 'package:enviso/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NameSite extends StatefulWidget {
  @override
  State<NameSite> createState() => _NameSiteState();
}

class _NameSiteState extends State<NameSite> {
  late dynamic name = 'Das ist ein Test';
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Name'),
          actions: [
            IconButton(
              icon: const Icon(Icons.storage),
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser!;
                DataBaseFireStore().getUserName(user.uid);
                setState(() {});
              },
            )
          ],
        ),
        body: Text(name.toString()),
      );
}
