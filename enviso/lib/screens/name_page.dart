import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NamePage extends StatefulWidget {
  @override
  State<NamePage> createState() => _NameSiteState();
}

class _NameSiteState extends State<NamePage> {
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
                setState(() {});
              },
            )
          ],
        ),
        body: Text(name.toString()),
      );
}
