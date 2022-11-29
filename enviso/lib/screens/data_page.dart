import 'package:enviso/services/transportdata.dart';
import 'package:flutter/material.dart';
import 'package:enviso/services/transportapi.dart';

class DataPage extends StatelessWidget {
  const DataPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Data'),
          actions: [
            IconButton(
              icon: const Icon(Icons.storage),
              onPressed: () {},
            )
          ],
        ),
        body: FutureBuilder(
            future: TransportApi.getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());
                default:
                  if (snapshot.hasError) {
                    return const Center(child: Text('was für ein Bullshit'));
                  } else {
                    return const Center(child: Text('Es lebt!'));
                  }
              }
            }),
      );
}
