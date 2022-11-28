import 'package:enviso/services/database.dart';
import 'package:enviso/services/transportdata.dart';
import 'package:flutter/material.dart';
import 'package:enviso/services/transportapi.dart';

class DataSite extends StatelessWidget {
  const DataSite({super.key});

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
        body: FutureBuilder<List<TransportData>>(
            future: TransportApi.getData(),
            builder: (context, snapshot) {
              final transportData = snapshot.data;
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
